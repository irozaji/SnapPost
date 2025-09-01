import CoreImage
import Foundation
import UIKit
import Vision

final class ImageProcessor {

  struct Config {
    var recognitionLanguages: [String] = ["en-US"]
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    var usesLanguageCorrection: Bool = true
    var rectangleMinAspectRatio: Float = 0.5
    var rectangleMinimumSize: Float = 0.2
    var rectangleQuadratureTolerance: Float = 20.0
    var rectangleMinimumConfidence: VNConfidence = 0.5
    var yTolerancePixels: CGFloat = 18.0  // used in ordering rows
    var maxImageWidthForProcessing: CGFloat = 1500  // scale down high-res images
  }

  enum Error: Swift.Error, LocalizedError {
    case invalidImage
    case visionFailed

    var errorDescription: String? {
      switch self {
      case .invalidImage:
        return "The image cannot be processed. Please try with a different image."
      case .visionFailed:
        return "Failed to process the image. Please try again with a clearer photo."
      }
    }
  }

  private struct OCRLine {
    let text: String
    let boundingBox: CGRect
  }

  private let config: Config

  init(config: Config = Config()) {
    self.config = config
  }

  func process(image: UIImage) async throws -> ExcerptCapture {
    guard let cgImage = image.cgImage else {
      throw Error.invalidImage
    }

    // Step 1: Normalize image (scale down if needed)
    let normalizedImage = try normalizeImage(cgImage)

    // Step 2: Run rectangle detection
    let detectedRectangle = try await detectRectangle(in: normalizedImage)

    // Step 3: Apply perspective correction if rectangle found
    let correctedImage = try applePerspectiveCorrection(
      to: normalizedImage, rectangle: detectedRectangle)

    // Step 4: Optional contrast enhancement
    let enhancedImage = try applyContrastEnhancement(to: correctedImage)

    // Step 5: Run OCR
    let ocrLines = try await performOCR(on: enhancedImage)

    // Step 6-8: Order lines and extract text
    let orderedLines = orderAndExtractLines(from: ocrLines, yTolerance: config.yTolerancePixels)

    // Step 9: Remove page numbers and headers
    let filteredLines = TextCleaner.removePageNumbers(from: orderedLines)

    // Step 10: Clean final text
    let joinedText = filteredLines.joined(separator: " ")
    let cleanedText = TextCleaner.clean(joinedText)

    // Step 11: Return ExcerptCapture
    return ExcerptCapture(text: cleanedText)
  }

  // MARK: - Private Methods

  private func normalizeImage(_ cgImage: CGImage) throws -> CGImage {
    let imageWidth = CGFloat(cgImage.width)

    // If image is already small enough, return as-is
    if imageWidth <= config.maxImageWidthForProcessing {
      return cgImage
    }

    // Calculate scale factor to fit within maxImageWidthForProcessing
    let scaleFactor = config.maxImageWidthForProcessing / imageWidth
    let newWidth = Int(imageWidth * scaleFactor)
    let newHeight = Int(CGFloat(cgImage.height) * scaleFactor)

    // Create a new context and draw the scaled image
    guard
      let context = CGContext(
        data: nil,
        width: newWidth,
        height: newHeight,
        bitsPerComponent: cgImage.bitsPerComponent,
        bytesPerRow: 0,
        space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: cgImage.bitmapInfo.rawValue
      )
    else {
      throw Error.invalidImage
    }

    context.interpolationQuality = .high
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

    guard let scaledImage = context.makeImage() else {
      throw Error.invalidImage
    }

    return scaledImage
  }

  private func detectRectangle(in cgImage: CGImage) async throws -> VNRectangleObservation? {
    return try await withCheckedThrowingContinuation { continuation in
      let request = VNDetectRectanglesRequest { request, error in
        if error != nil {
          continuation.resume(throwing: Error.visionFailed)
          return
        }

        guard let observations = request.results as? [VNRectangleObservation] else {
          continuation.resume(returning: nil)
          return
        }

        // Find the rectangle with highest confidence that meets our criteria
        let validRectangles = observations.filter { observation in
          observation.confidence >= self.config.rectangleMinimumConfidence
            && self.isValidRectangle(observation)
        }

        let bestRectangle = validRectangles.max(by: { $0.confidence < $1.confidence })
        continuation.resume(returning: bestRectangle)
      }

      request.minimumAspectRatio = config.rectangleMinAspectRatio
      request.minimumSize = config.rectangleMinimumSize
      request.quadratureTolerance = config.rectangleQuadratureTolerance
      request.minimumConfidence = config.rectangleMinimumConfidence

      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

      do {
        try handler.perform([request])
      } catch {
        continuation.resume(throwing: Error.visionFailed)
      }
    }
  }

  private func isValidRectangle(_ rectangle: VNRectangleObservation) -> Bool {
    let boundingBox = rectangle.boundingBox
    let aspectRatio = boundingBox.width / boundingBox.height

    // Check if aspect ratio is reasonable for a page
    return aspectRatio >= CGFloat(config.rectangleMinAspectRatio)
      && boundingBox.width >= CGFloat(config.rectangleMinimumSize)
      && boundingBox.height >= CGFloat(config.rectangleMinimumSize)
  }

  private func applePerspectiveCorrection(to cgImage: CGImage, rectangle: VNRectangleObservation?)
    throws -> CGImage
  {
    guard let rectangle = rectangle else {
      // No rectangle detected, return original image
      return cgImage
    }

    let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

    // Convert normalized coordinates to image coordinates
    let topLeft = CGPoint(
      x: rectangle.topLeft.x * imageSize.width,
      y: (1 - rectangle.topLeft.y) * imageSize.height
    )
    let topRight = CGPoint(
      x: rectangle.topRight.x * imageSize.width,
      y: (1 - rectangle.topRight.y) * imageSize.height
    )
    let bottomLeft = CGPoint(
      x: rectangle.bottomLeft.x * imageSize.width,
      y: (1 - rectangle.bottomLeft.y) * imageSize.height
    )
    let bottomRight = CGPoint(
      x: rectangle.bottomRight.x * imageSize.width,
      y: (1 - rectangle.bottomRight.y) * imageSize.height
    )

    // Create CIImage from CGImage
    let ciImage = CIImage(cgImage: cgImage)

    // Apply perspective correction filter
    guard let filter = CIFilter(name: "CIPerspectiveCorrection") else {
      throw Error.visionFailed
    }

    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
    filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
    filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
    filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")

    guard let outputImage = filter.outputImage else {
      throw Error.visionFailed
    }

    // Convert back to CGImage
    let context = CIContext()
    guard let correctedCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
      throw Error.visionFailed
    }

    return correctedCGImage
  }

  private func applyContrastEnhancement(to cgImage: CGImage) throws -> CGImage {
    let ciImage = CIImage(cgImage: cgImage)

    guard let filter = CIFilter(name: "CIColorControls") else {
      // If filter is not available, return original image
      return cgImage
    }

    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(1.1, forKey: kCIInputContrastKey)  // Small contrast boost

    guard let outputImage = filter.outputImage else {
      return cgImage
    }

    let context = CIContext()
    guard let enhancedCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
      return cgImage
    }

    return enhancedCGImage
  }

  private func performOCR(on cgImage: CGImage) async throws -> [OCRLine] {
    return try await withCheckedThrowingContinuation { continuation in
      let request = VNRecognizeTextRequest { request, error in
        if error != nil {
          continuation.resume(throwing: Error.visionFailed)
          return
        }

        guard let observations = request.results as? [VNRecognizedTextObservation] else {
          continuation.resume(returning: [])
          return
        }

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        var ocrLines: [OCRLine] = []

        for observation in observations {
          guard let topCandidate = observation.topCandidates(1).first else { continue }

          let boundingBox = self.rectForBoundingBox(observation.boundingBox, imageSize: imageSize)
          let ocrLine = OCRLine(text: topCandidate.string, boundingBox: boundingBox)
          ocrLines.append(ocrLine)
        }

        continuation.resume(returning: ocrLines)
      }

      request.recognitionLevel = config.recognitionLevel
      request.recognitionLanguages = config.recognitionLanguages
      request.usesLanguageCorrection = config.usesLanguageCorrection

      let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

      do {
        try handler.perform([request])
      } catch {
        continuation.resume(throwing: Error.visionFailed)
      }
    }
  }

  private func rectForBoundingBox(_ normalizedRect: CGRect, imageSize: CGSize) -> CGRect {
    return CGRect(
      x: normalizedRect.minX * imageSize.width,
      y: (1 - normalizedRect.maxY) * imageSize.height,  // Flip Y coordinate
      width: normalizedRect.width * imageSize.width,
      height: normalizedRect.height * imageSize.height
    )
  }

  private func orderAndExtractLines(from lines: [OCRLine], yTolerance: CGFloat) -> [String] {
    if lines.isEmpty { return [] }

    // Group lines by rows based on Y position tolerance
    var rows: [[OCRLine]] = []

    for line in lines {
      let lineY = line.boundingBox.midY

      // Find existing row within tolerance
      var addedToRow = false
      for i in 0..<rows.count {
        let rowY = rows[i].first?.boundingBox.midY ?? 0
        if abs(lineY - rowY) <= yTolerance {
          rows[i].append(line)
          addedToRow = true
          break
        }
      }

      // Create new row if not added to existing row
      if !addedToRow {
        rows.append([line])
      }
    }

    // Sort rows by Y position (top to bottom)
    rows.sort { row1, row2 in
      let y1 = row1.first?.boundingBox.midY ?? 0
      let y2 = row2.first?.boundingBox.midY ?? 0
      return y1 < y2
    }

    // Sort lines within each row by X position (left to right)
    for i in 0..<rows.count {
      rows[i].sort { line1, line2 in
        line1.boundingBox.minX < line2.boundingBox.minX
      }
    }

    // Extract text from ordered lines
    var orderedText: [String] = []
    for row in rows {
      let rowText = row.map { $0.text }.joined(separator: " ")
      if !rowText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        orderedText.append(rowText)
      }
    }

    return orderedText
  }
}

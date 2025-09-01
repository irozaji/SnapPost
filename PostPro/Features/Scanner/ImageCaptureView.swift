//
//  ImageCaptureView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct ImageCaptureView: View {
  @Binding var result: ExcerptCapture?
  @Environment(\.dismiss) private var dismiss

  @State private var selectedImage: UIImage?
  @State private var showingImagePicker = false
  @State private var showingPhotoPicker = false
  @State private var isProcessing = false
  @State private var errorMessage: String?
  @State private var showingError = false
  @State private var didTriggerInitialSource = false

  private let imageProcessor = ImageProcessor()

  enum InitialSource {
    case none
    case camera
    case library
  }

  var initialSource: InitialSource = .none

  var body: some View {
    NavigationView {
      VStack(spacing: 24) {
        // Image Preview or Placeholder
        if let selectedImage = selectedImage {
          VStack(spacing: 16) {
            Image(uiImage: selectedImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxHeight: 300)
              .cornerRadius(12)
              .shadow(radius: 4)

            if isProcessing {
              VStack(spacing: 12) {
                ProgressView()
                  .scaleEffect(1.2)
                Text("Processing image...")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
            } else {
              Button(action: processImage) {
                HStack {
                  Image(systemName: "doc.text.viewfinder")
                  Text("Use Image")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
              }
            }
          }
        } else {
          // Placeholder
          VStack(spacing: 16) {
            Image(systemName: "doc.text.viewfinder")
              .font(.system(size: 80))
              .foregroundColor(.secondary)

            Text("No image selected")
              .font(.headline)
              .foregroundColor(.secondary)

            Text("Choose an option below to get started")
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity, minHeight: 200)
          .background(Color(UIColor.systemGray6))
          .cornerRadius(12)
        }

        Spacer()

        // Bottom Action Bar
        VStack(spacing: 12) {
          Button(action: { showingImagePicker = true }) {
            HStack {
              Image(systemName: "camera.fill")
              Text("Take Photo")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
          }
          .disabled(isProcessing)

          Button(action: { showingPhotoPicker = true }) {
            HStack {
              Image(systemName: "photo.fill")
              Text("Choose from Library")
            }
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
          }
          .disabled(isProcessing)
        }
        .padding(.bottom)
      }
      .padding()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
          .disabled(isProcessing)
        }
      }
      .onAppear {
        // Trigger initial source only once
        guard !didTriggerInitialSource else { return }
        didTriggerInitialSource = true
        switch initialSource {
        case .camera:
          showingImagePicker = true
        case .library:
          showingPhotoPicker = true
        case .none:
          break
        }
      }
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker(selectedImage: $selectedImage, isPresented: $showingImagePicker)
    }
    .background(
      PhotoPicker(selectedImage: $selectedImage, isPresented: $showingPhotoPicker)
    )
    .alert("Error", isPresented: $showingError) {
      Button("Retry") {
        processImage()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text(errorMessage ?? "An error occurred while processing the image.")
    }
  }

  private func processImage() {
    guard let selectedImage = selectedImage else { return }

    isProcessing = true
    errorMessage = nil

    Task {
      do {
        let excerpt = try await imageProcessor.process(image: selectedImage)
        await MainActor.run {
          result = excerpt
          isProcessing = false
          dismiss()
        }
      } catch {
        await MainActor.run {
          isProcessing = false
          errorMessage = error.localizedDescription
          showingError = true
        }
      }
    }
  }
}

#Preview {
  ImageCaptureView(result: .constant(nil))
}

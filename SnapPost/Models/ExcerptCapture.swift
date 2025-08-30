import Foundation

struct ExcerptCapture: Identifiable, Codable {
  let id: UUID
  let text: String
  let createdAt: Date
  let sourceHint: String?
  let confidence: Float?

  init(text: String, sourceHint: String? = nil, confidence: Float? = nil) {
    self.id = UUID()
    self.text = text
    self.createdAt = Date()
    self.sourceHint = sourceHint
    self.confidence = confidence
  }
}

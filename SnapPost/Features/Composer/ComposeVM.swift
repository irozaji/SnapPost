//
//  ComposeVM.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import Foundation

@MainActor
final class ComposeVM: ObservableObject {
  @Published var excerpt: String = ""
  @Published var toneHints: [Tone] = [.punchy, .contrarian, .personal, .analytical, .openQuestion]
  @Published var selectedTone: Tone? = nil
  @Published var variants: [Variant] = []
  @Published var isLoading: Bool = false
  @Published var error: String? = nil

  func generate(bookTitle: String? = nil, author: String? = nil) async {
    isLoading = true
    error = nil

    do {
      let generatedVariants = try await AIClient.shared.generateVariants(
        from: excerpt,
        bookTitle: bookTitle,
        author: author
      )
      variants = generatedVariants

      // Check if any variants were truncated
      let truncatedCount = generatedVariants.filter { $0.text.hasSuffix("...") }.count
      if truncatedCount > 0 {
        self.error = "Variant trimmed to meet LinkedIn length."
      }
    } catch {
      self.error = error.localizedDescription
    }

    isLoading = false
  }
}

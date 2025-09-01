//
//  ExtractedTextActionsView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct ExtractedTextActionsView: View {
  let editedText: String
  let isGenerating: Bool
  let onGeneratePosts: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      // Primary action - Generate Posts
      Button(action: onGeneratePosts) {
        HStack {
          if isGenerating {
            ProgressView().scaleEffect(0.9)
          } else {
            Image(systemName: "sparkles")
          }
          Text(isGenerating ? "Generating..." : "Generate Posts")
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(isGenerating ? Color.gray : Color.blue)
        .cornerRadius(16)
      }
      .disabled(
        isGenerating || editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      )
    }
  }
}

#Preview {
  ExtractedTextActionsView(
    editedText: "Sample text",
    isGenerating: false,
    onGeneratePosts: {}
  )
  .padding()
}

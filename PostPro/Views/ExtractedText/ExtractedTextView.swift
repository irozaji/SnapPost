//
//  ExtractedTextView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct ExtractedTextView: View {
  let excerpt: ExcerptCapture
  @Binding var editedText: String
  @FocusState.Binding var isTextEditorFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Extracted Text")
        .font(.headline)
        .foregroundColor(.secondary)

      TextEditor(text: $editedText)
        .font(.body)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .focused($isTextEditorFocused)
        .onAppear { editedText = excerpt.text }
    }
    .padding(.top)
  }
}

#Preview {
  @Previewable @State var editedText = "Sample extracted text from OCR..."
  @Previewable @FocusState var isFocused: Bool

  return ExtractedTextView(
    excerpt: ExcerptCapture(text: "Sample extracted text from OCR..."),
    editedText: $editedText,
    isTextEditorFocused: $isFocused
  )
}

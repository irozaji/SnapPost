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
  @Binding var dynamicHeight: CGFloat

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Extracted Text")
        .font(.headline)
        .foregroundColor(.secondary)

      TextEditor(text: $editedText)
        .font(.body)
        .frame(
          maxWidth: .infinity,
          minHeight: min(dynamicHeight, 120),
          maxHeight: dynamicHeight,
          alignment: .topLeading
        )
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .focused($isTextEditorFocused)
        .onAppear { editedText = excerpt.text }
    }
  }
}

#Preview {
  @Previewable @State var editedText = "Sample extracted text from OCR..."
  @Previewable @FocusState var isFocused: Bool
  @Previewable @State var height: CGFloat = 200

  return ExtractedTextView(
    excerpt: ExcerptCapture(text: "Sample extracted text from OCR..."),
    editedText: $editedText,
    isTextEditorFocused: $isFocused,
    dynamicHeight: $height
  )
}

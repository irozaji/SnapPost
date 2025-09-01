//
//  VariantCard.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import SwiftUI
import UIKit

struct VariantCard: View {
  let variant: Variant
  @State private var isCopied = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(variant.tone.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(toneColor(for: variant.tone))
          .cornerRadius(6)
        Spacer()
        Text("\(variant.text.count)/900")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      Text(variant.text)
        .font(.body)
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
      HStack(spacing: 12) {
        Button(action: copyVariant) {
          HStack {
            Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
            Text(isCopied ? "Copied" : "Copy")
          }
          .font(.subheadline)
          .foregroundColor(isCopied ? .green : .blue)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color(UIColor.systemGray6))
          .cornerRadius(6)
        }
        .disabled(isCopied)
        Button(action: shareVariant) {
          HStack {
            Image(systemName: "square.and.arrow.up")
            Text("Share")
          }
          .font(.subheadline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color.blue)
          .cornerRadius(6)
        }
      }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(12)
    .shadow(radius: 1)
  }

  private func copyVariant() {
    UIPasteboard.general.string = variant.text
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.impactOccurred()
    withAnimation(.easeInOut(duration: 0.2)) { isCopied = true }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      withAnimation(.easeInOut(duration: 0.2)) { isCopied = false }
    }
  }

  private func shareVariant() {
    let activityVC = UIActivityViewController(
      activityItems: [variant.text],
      applicationActivities: nil
    )
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let window = windowScene.windows.first
    {
      window.rootViewController?.present(activityVC, animated: true)
    }
  }

  private func toneColor(for tone: Tone) -> Color {
    switch tone {
    case .punchy: return .orange
    case .contrarian: return .red
    case .personal: return .blue
    case .analytical: return .purple
    case .openQuestion: return .green
    }
  }
}

#Preview {
  VariantCard(
    variant: Variant(
      tone: .punchy,
      text: "This is a sample punchy LinkedIn post that demonstrates the tone and style.")
  )
  .padding()
}

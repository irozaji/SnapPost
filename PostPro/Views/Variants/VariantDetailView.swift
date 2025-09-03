//
//  VariantDetailView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI
import UIKit

struct VariantDetailView: View {
  let variant: Variant
  @State private var isCopied = false
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        // Scrollable content area
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            // Header with tone and character count
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

            // Full post text
            Text(variant.text)
              .font(.body)
              .lineSpacing(4)
              .multilineTextAlignment(.leading)
              .textSelection(.enabled)

            // Spacer to push content up from buttons
            Spacer(minLength: 20)
          }
          .padding()
        }

        // Fixed bottom action bar
        VStack(spacing: 0) {
          Divider()

          HStack(spacing: 12) {
            // Copy button
            Button(action: copyVariant) {
              HStack {
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                Text(isCopied ? "Copied" : "Copy")
              }
              .font(.subheadline)
              .foregroundColor(isCopied ? .green : .blue)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background(Color(UIColor.systemGray6))
              .cornerRadius(8)
            }
            .disabled(isCopied)

            // Share button
            Button(action: shareVariant) {
              HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
              }
              .font(.subheadline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background(Color.blue)
              .cornerRadius(8)
            }
          }
          .padding()
        }
        .background(Color(UIColor.systemBackground))
      }
    }
    .navigationTitle("Post Details")
    .navigationBarTitleDisplayMode(.inline)
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
  NavigationView {
    VariantDetailView(
      variant: Variant(
        tone: .punchy,
        text:
          "🚀 This insight completely changed my perspective on leadership. When we think we know everything, we stop growing. The moment I admitted I didn't have all the answers was the moment real progress began. What's the last thing that made you rethink your approach?"
      )
    )
  }
}

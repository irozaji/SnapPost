//
//  VariantCard.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI
import UIKit

struct VariantCard: View {
  let variant: Variant

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Header with tone badge and character count
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

        HStack(spacing: 8) {
          Text("\(variant.text.count)/900")
            .font(.caption)
            .foregroundColor(.secondary)

          // Chevron to indicate tappability
          Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }

      // Truncated text with fade effect
      ZStack(alignment: .bottomTrailing) {
        Text(variant.text)
          .font(.body)
          .lineLimit(4)
          .multilineTextAlignment(.leading)
          .lineSpacing(2)

        // Fade effect overlay for truncated text
        if variant.text.count > 180 {  // Approximate threshold for 4 lines
          LinearGradient(
            gradient: Gradient(colors: [Color.clear, Color(UIColor.systemBackground)]),
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: 40, height: 20)
          .offset(x: 0, y: -2)
        }
      }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(12)
    .shadow(radius: 1)
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
      text:
        "🚀 This insight completely changed my perspective on leadership. When we think we know everything, we stop growing. The moment I admitted I didn't have all the answers was the moment real progress began. What's the last thing that made you rethink your approach? Sometimes the most powerful thing a leader can do is say 'I don't know' and create space for others to contribute."
    )
  )
  .padding()
}

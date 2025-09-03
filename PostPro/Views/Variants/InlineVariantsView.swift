//
//  InlineVariantsView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct InlineVariantsView: View {
  let variants: [Variant]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Header
      HStack {
        Text("Generated Posts")
          .font(.headline)
          .foregroundColor(.primary)

        Spacer()

        Text("\(variants.count) variants")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      // Variants list
      LazyVStack(spacing: 16) {
        ForEach(variants) { variant in
          NavigationLink(destination: VariantDetailView(variant: variant)) {
            VariantCard(variant: variant)
          }
          .buttonStyle(PlainButtonStyle())  // Prevents default button styling
        }
      }
    }
  }
}

#Preview {
  InlineVariantsView(variants: [
    Variant(
      tone: .punchy,
      text:
        "🚀 This insight completely changed my perspective on leadership. When we think we know everything, we stop growing. The moment I admitted I didn't have all the answers was the moment real progress began. What's the last thing that made you rethink your approach?"
    ),
    Variant(
      tone: .personal,
      text:
        "This passage hit me hard. It reminded me of my own journey from thinking I knew it all to realizing how much I still need to learn. Sometimes the best leaders are those who aren't afraid to say 'I don't know.' What's been your biggest learning moment?"
    ),
    Variant(
      tone: .analytical,
      text:
        "Breaking down this concept: 3 key factors emerge when leaders embrace uncertainty: 1) Increased team trust 2) Better decision-making processes 3) Continuous learning culture. The data shows humble leadership drives 23% better team performance. How do you measure leadership effectiveness?"
    ),
  ])
  .padding()
}

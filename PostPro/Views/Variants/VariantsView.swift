//
//  VariantsView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct VariantsView: View {
  let variants: [Variant]
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      ScrollView {
        LazyVStack(spacing: 16) {
          ForEach(variants) { variant in
            VariantCard(variant: variant)
          }
        }
        .padding()
      }
      .navigationTitle("Generated Posts")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
  }
}

#Preview {
  VariantsView(variants: [
    Variant(tone: .punchy, text: "Sample punchy post text..."),
    Variant(tone: .personal, text: "Sample personal post text..."),
    Variant(tone: .analytical, text: "Sample analytical post text..."),
  ])
}

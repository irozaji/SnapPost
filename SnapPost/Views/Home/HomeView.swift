//
//  HomeView.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct HomeView: View {
  let onScanCamera: () -> Void
  let onChooseFromLibrary: () -> Void

  var body: some View {
    // Home state - Apple-style design
    VStack(spacing: 32) {
      Spacer()

      // Hero section
      VStack(spacing: 16) {
        // Large icon with subtle background
        ZStack {
          Circle()
            .fill(Color.blue.opacity(0.1))
            .frame(width: 120, height: 120)

          Image(systemName: "doc.text.viewfinder")
            .font(.system(size: 48, weight: .light))
            .foregroundColor(.blue)
        }

        // Title and description
        VStack(spacing: 8) {
          Text("SnapPost")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)

          Text("Transform text into LinkedIn posts")
            .font(.title3)
            .fontWeight(.medium)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        }
      }

      Spacer()

      // Feature highlights
      VStack(spacing: 12) {
        FeatureRow(
          icon: "camera.viewfinder",
          title: "Instant Capture",
          description: "Point and scan any text"
        )

        FeatureRow(
          icon: "sparkles",
          title: "AI Generation",
          description: "Create engaging LinkedIn posts"
        )

        FeatureRow(
          icon: "square.and.arrow.up",
          title: "Quick Share",
          description: "Share directly to LinkedIn"
        )
      }
      .padding(.horizontal)

      Spacer()
    }
  }
}

#Preview {
  HomeView(
    onScanCamera: {},
    onChooseFromLibrary: {}
  )
}

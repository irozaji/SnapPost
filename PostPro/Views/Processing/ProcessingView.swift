//
//  ProcessingView.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct ProcessingView: View {
  let isProcessing: Bool

  var body: some View {
    // Processing state - smooth loading UI
    VStack(spacing: 32) {
      Spacer()

      VStack(spacing: 24) {
        // Animated processing icon
        ZStack {
          Circle()
            .fill(Color.blue.opacity(0.1))
            .frame(width: 120, height: 120)

          Image(systemName: "doc.text.viewfinder")
            .font(.system(size: 48, weight: .light))
            .foregroundColor(.blue)
            .scaleEffect(isProcessing ? 1.1 : 1.0)
            .animation(
              .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
              value: isProcessing
            )
        }

        // Processing text with animation
        VStack(spacing: 12) {
          Text("Processing Image")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)

          Text("Extracting text with OCR...")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }

        // Progress indicator
        ProgressView()
          .scaleEffect(1.2)
          .progressViewStyle(CircularProgressViewStyle(tint: .blue))
      }

      Spacer()
    }
    .transition(.opacity.combined(with: .scale(scale: 0.95)))
  }
}

#Preview {
  ProcessingView(isProcessing: true)
}

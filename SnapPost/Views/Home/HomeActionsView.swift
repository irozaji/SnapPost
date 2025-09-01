//
//  HomeActionsView.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct HomeActionsView: View {
  let onScanCamera: () -> Void
  let onChooseFromLibrary: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Button(action: onScanCamera) {
        HStack(spacing: 12) {
          Image(systemName: "camera.viewfinder")
            .font(.title2)
            .fontWeight(.medium)
          Text("Scan Text")
            .font(.title3)
            .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
          LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .cornerRadius(16)
        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
      }

      Button(action: onChooseFromLibrary) {
        HStack(spacing: 12) {
          Image(systemName: "photo.on.rectangle")
            .font(.title2)
            .fontWeight(.medium)
          Text("Choose from Library")
            .font(.title3)
            .fontWeight(.medium)
        }
        .foregroundColor(.blue)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
      }
    }
  }
}

#Preview {
  HomeActionsView(
    onScanCamera: {},
    onChooseFromLibrary: {}
  )
  .padding()
}

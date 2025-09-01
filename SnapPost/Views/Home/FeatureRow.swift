//
//  FeatureRow.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct FeatureRow: View {
  let icon: String
  let title: String
  let description: String

  var body: some View {
    HStack(spacing: 16) {
      // Icon with background
      ZStack {
        Circle()
          .fill(Color.blue.opacity(0.1))
          .frame(width: 44, height: 44)

        Image(systemName: icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(.blue)
      }

      // Text content
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.primary)

        Text(description)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding(.vertical, 8)
  }
}

#Preview {
  FeatureRow(
    icon: "camera.viewfinder",
    title: "Instant Capture",
    description: "Point and scan any text"
  )
}

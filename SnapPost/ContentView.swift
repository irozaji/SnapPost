//
//  ContentView.swift
//  SnapPost
//
//  Created by Ilzat Rozaji on 8/27/25.
//

import SwiftUI

struct ContentView: View {
  @State private var excerptCapture: ExcerptCapture?
  @State private var showingScanner = false
  @State private var showingComposer = false

  var body: some View {
    NavigationView {
      VStack(spacing: 24) {
        // App Header
        VStack(spacing: 8) {
          Image(systemName: "doc.text.viewfinder")
            .font(.system(size: 64))
            .foregroundColor(.blue)

          Text("SnapPost")
            .font(.largeTitle)
            .fontWeight(.bold)

          Text("Transform text into LinkedIn posts")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.top)

        // Extracted Text Display
        if let excerpt = excerptCapture {
          VStack(alignment: .leading, spacing: 12) {
            Text("Extracted Text")
              .font(.headline)
              .foregroundColor(.secondary)

            ScrollView {
              Text(excerpt.text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            }
            .frame(maxHeight: 200)

            HStack {
              Button("Copy Text") {
                UIPasteboard.general.string = excerpt.text
              }
              .font(.subheadline)
              .foregroundColor(.blue)

              Button("Compose Posts") {
                showingComposer = true
              }
              .font(.subheadline)
              .foregroundColor(.white)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.blue)
              .cornerRadius(6)

              Spacer()

              Text("Captured \(timeAgo(from: excerpt.createdAt))")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .padding()
          .background(Color(UIColor.systemBackground))
          .cornerRadius(16)
          .shadow(radius: 2)
        } else {
          // Placeholder
          VStack(spacing: 16) {
            Image(systemName: "doc.text")
              .font(.system(size: 48))
              .foregroundColor(.secondary)

            Text("No text captured yet")
              .font(.headline)
              .foregroundColor(.secondary)

            Text("Tap the scan button to capture text from an image")
              .font(.subheadline)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
          }
          .frame(maxWidth: .infinity, minHeight: 150)
          .background(Color(UIColor.systemGray6))
          .cornerRadius(16)
        }

        Spacer()

        // Main Action Button
        Button(action: { showingScanner = true }) {
          HStack {
            Image(systemName: "camera.viewfinder")
            Text("Scan Text")
          }
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .cornerRadius(16)
        }

        // Secondary Action (if text exists)
        if excerptCapture != nil {
          Button("Scan New Text") {
            showingScanner = true
          }
          .font(.subheadline)
          .foregroundColor(.blue)
        }
      }
      .padding()
      .navigationBarTitleDisplayMode(.inline)
    }
    .sheet(isPresented: $showingScanner) {
      ImageCaptureView(result: $excerptCapture)
    }
    .sheet(isPresented: $showingComposer) {
      if let excerpt = excerptCapture {
        ComposerView(excerptCapture: excerpt)
      }
    }
  }

  private func timeAgo(from date: Date) -> String {
    let now = Date()
    let interval = now.timeIntervalSince(date)

    if interval < 60 {
      return "just now"
    } else if interval < 3600 {
      let minutes = Int(interval / 60)
      return "\(minutes)m ago"
    } else if interval < 86400 {
      let hours = Int(interval / 3600)
      return "\(hours)h ago"
    } else {
      let days = Int(interval / 86400)
      return "\(days)d ago"
    }
  }
}

#Preview {
  ContentView()
}

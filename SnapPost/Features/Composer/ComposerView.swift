//
//  ComposerView.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import SwiftUI

struct ComposerView: View {
  @StateObject private var viewModel = ComposeVM()
  @Environment(\.dismiss) private var dismiss

  let excerptCapture: ExcerptCapture
  @State private var bookTitle: String = ""
  @State private var author: String = ""
  @State private var showingShareSheet = false
  @State private var selectedVariantText: String = ""

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 20) {
          // Mock mode indicator (only shown in mock mode)
          if AIClient.shared.isUsingMockMode() {
            mockModeIndicator
          }

          // Excerpt Card
          excerptCard

          // Book Details (Optional)
          bookDetailsSection

          // Generate Button
          generateButton

          // Variants Section
          if viewModel.isLoading {
            loadingView
          } else if !viewModel.variants.isEmpty {
            variantsSection
          }

          // Error Message
          if let error = viewModel.error {
            errorView(error)
          }
        }
        .padding()
      }
      .navigationTitle("Compose Post")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
    .onAppear {
      viewModel.excerpt = excerptCapture.text
    }
    .sheet(isPresented: $showingShareSheet) {
      ShareSheet(
        text: selectedVariantText,
        onComplete: { completed, activityType in
          if completed {
            logShare(selectedVariantText)
          }
        })
    }
  }

  private var excerptCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Extracted Text")
        .font(.headline)
        .foregroundColor(.secondary)

      ScrollView {
        Text(excerptCapture.text)
          .font(.body)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxHeight: 150)
      .padding()
      .background(Color(UIColor.systemGray6))
      .cornerRadius(12)

      Text("\(excerptCapture.text.count) characters")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
    .shadow(radius: 2)
  }

  private var bookDetailsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Book Details (Optional)")
        .font(.headline)
        .foregroundColor(.secondary)

      VStack(spacing: 8) {
        TextField("Book Title", text: $bookTitle)
          .textFieldStyle(RoundedBorderTextFieldStyle())

        TextField("Author", text: $author)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
    .shadow(radius: 2)
  }

  private var generateButton: some View {
    Button(action: {
      Task {
        await viewModel.generate(
          bookTitle: bookTitle.isEmpty ? nil : bookTitle,
          author: author.isEmpty ? nil : author
        )
      }
    }) {
      HStack {
        Image(systemName: "sparkles")
        Text("Generate LinkedIn Posts")
      }
      .font(.headline)
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding()
      .background(viewModel.isLoading ? Color.gray : Color.blue)
      .cornerRadius(16)
    }
    .disabled(viewModel.isLoading || excerptCapture.text.isEmpty)
  }

  private var loadingView: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)

      Text("Generating LinkedIn posts...")
        .font(.subheadline)
        .foregroundColor(.secondary)

      Text("This may take a few seconds")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
  }

  private var variantsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("\(viewModel.variants.count) Post Variants")
        .font(.title2)
        .fontWeight(.semibold)

      LazyVStack(spacing: 12) {
        ForEach(viewModel.variants) { variant in
          VariantCard(
            variant: variant,
            onCopy: {
              UIPasteboard.general.string = variant.text
            },
            onShare: {
              selectedVariantText = variant.text
              showingShareSheet = true
            }
          )
        }
      }
    }
  }

  private var mockModeIndicator: some View {
    HStack {
      Image(systemName: "theatermasks")
        .foregroundColor(.orange)

      VStack(alignment: .leading, spacing: 2) {
        Text("Development Mode")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.primary)

        Text("Using mock data - no API calls")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()
    }
    .padding()
    .background(Color.orange.opacity(0.1))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
    )
  }

  private func errorView(_ errorMessage: String) -> some View {
    VStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 24))
        .foregroundColor(.orange)

      Text("Generation Failed")
        .font(.headline)
        .foregroundColor(.primary)

      Text(errorMessage)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

      Button("Try Again") {
        Task {
          await viewModel.generate(
            bookTitle: bookTitle.isEmpty ? nil : bookTitle,
            author: author.isEmpty ? nil : author
          )
        }
      }
      .font(.headline)
      .foregroundColor(.white)
      .padding(.horizontal, 24)
      .padding(.vertical, 8)
      .background(Color.blue)
      .cornerRadius(8)
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
    .shadow(radius: 2)
  }
}

struct VariantCard: View {
  let variant: Variant
  let onCopy: () -> Void
  let onShare: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Tone Badge
      HStack {
        Text(variant.tone.displayName)
          .font(.caption)
          .fontWeight(.medium)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(toneColor.opacity(0.2))
          .foregroundColor(toneColor)
          .cornerRadius(6)

        Spacer()

        Text("\(variant.text.count)/900")
          .font(.caption)
          .foregroundColor(variant.text.count > 900 ? .red : .secondary)
      }

      // Post Text
      Text(variant.text)
        .font(.body)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Action Buttons
      HStack(spacing: 12) {
        Button(action: onCopy) {
          HStack {
            Image(systemName: "doc.on.doc")
            Text("Copy")
          }
          .font(.subheadline)
          .foregroundColor(.blue)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(8)
        }

        Button(action: onShare) {
          HStack {
            Image(systemName: "square.and.arrow.up")
            Text("Share")
          }
          .font(.subheadline)
          .foregroundColor(.white)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(Color.blue)
          .cornerRadius(8)
        }

        Spacer()
      }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(16)
    .shadow(radius: 2)
  }

  private var toneColor: Color {
    switch variant.tone {
    case .punchy:
      return .red
    case .contrarian:
      return .orange
    case .personal:
      return .green
    case .analytical:
      return .blue
    case .openQuestion:
      return .purple
    }
  }
}

struct ShareSheet: UIViewControllerRepresentable {
  let text: String
  var onComplete: ((Bool, UIActivity.ActivityType?) -> Void)? = nil

  func makeUIViewController(context: Context) -> UIActivityViewController {
    let activityController = UIActivityViewController(
      activityItems: [text],
      applicationActivities: nil
    )
    activityController.completionWithItemsHandler = { activityType, completed, _, _ in
      onComplete?(completed, activityType)
    }
    return activityController
  }

  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension ComposerView {
  fileprivate func logShare(_ text: String) {
    let formatter = ISO8601DateFormatter()
    let entry: [String: Any] = [
      "text": text,
      "date": formatter.string(from: Date()),
    ]
    let defaults = UserDefaults.standard
    var history = defaults.array(forKey: "shareHistory") as? [[String: Any]] ?? []
    history.insert(entry, at: 0)
    defaults.set(history, forKey: "shareHistory")
  }
}

#Preview {
  ComposerView(
    excerptCapture: ExcerptCapture(
      text:
        "This is a sample excerpt from a book that demonstrates the OCR functionality. It contains enough text to show how the composer would work with real extracted content from an image."
    ))
}

//
//  ContentView.swift
//  SnapPost
//
//  Created by Ilzat Rozaji on 8/27/25.
//

import SwiftUI

struct ContentView: View {
  @State private var excerptCapture: ExcerptCapture?
  @State private var showingCamera = false
  @State private var showingPhotoPicker = false
  @State private var selectedImage: UIImage?
  @State private var isProcessing = false
  @State private var editedText: String = ""
  @State private var isCopied = false
  @State private var isGenerating = false
  @State private var generatedVariants: [Variant] = []
  @State private var showingVariants = false
  @State private var generationError: String?
  @State private var processingError: String?
  @FocusState private var isTextEditorFocused: Bool

  private let imageProcessor = ImageProcessor()

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        // Content Area
        if isProcessing {
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
                    .easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isProcessing
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
        } else if let excerpt = excerptCapture {
          // Results state
          VStack(alignment: .leading, spacing: 12) {
            Text("Extracted Text")
              .font(.headline)
              .foregroundColor(.secondary)

            TextEditor(text: $editedText)
              .font(.body)
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
              .background(Color(UIColor.systemGray6))
              .cornerRadius(12)
              .focused($isTextEditorFocused)
              .onAppear { editedText = excerpt.text }
              .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                  Button("Copy") {
                    copyText()
                  }
                  .foregroundColor(.blue)

                  Spacer()

                  Button("Done") {
                    isTextEditorFocused = false
                  }
                  .foregroundColor(.blue)
                  .fontWeight(.semibold)
                }
              }
          }
          .padding(.top)
        } else {
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

        // Bottom Action Bar
        VStack(spacing: 12) {
          if excerptCapture == nil {
            // Home actions - Apple style
            VStack(spacing: 16) {
              Button(action: {
                showingCamera = true
              }) {
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

              Button(action: {
                showingPhotoPicker = true
              }) {
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
          } else {
            // Results actions - hide when keyboard is active
            if !isTextEditorFocused {
              // Primary action when not editing
              Button(action: generatePosts) {
                HStack {
                  if isGenerating {
                    ProgressView().scaleEffect(0.9)
                  } else {
                    Image(systemName: "sparkles")
                  }
                  Text(isGenerating ? "Generating..." : "Generate 3 Posts")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isGenerating ? Color.gray : Color.blue)
                .cornerRadius(16)
              }
              .disabled(
                isGenerating || editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

              // Secondary action when not editing
              Button(action: copyText) {
                HStack {
                  Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                  Text(isCopied ? "Copied" : "Copy")
                }
                .font(.headline)
                .foregroundColor(isCopied ? .green : .blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
              }
              .disabled(isCopied)

              // Navigation actions
              HStack {
                Button("Scan New") {
                  editedText = ""
                  excerptCapture = nil
                  showingCamera = true
                }
                .foregroundColor(.blue)

                Spacer()

                Button("Back to Home") {
                  editedText = ""
                  excerptCapture = nil
                }
                .foregroundColor(.secondary)
              }
              .padding(.top, 4)
            }
          }
        }
      }
      .padding()
      .navigationBarTitleDisplayMode(.inline)
    }
    .fullScreenCover(isPresented: $showingCamera) {
      ImagePicker(selectedImage: $selectedImage, isPresented: $showingCamera)
    }
    .background(
      PhotoPicker(selectedImage: $selectedImage, isPresented: $showingPhotoPicker)
    )
    .sheet(isPresented: $showingVariants) {
      VariantsView(variants: generatedVariants)
    }
    .alert("Generation Error", isPresented: .constant(generationError != nil)) {
      Button("OK") { generationError = nil }
    } message: {
      Text(generationError ?? "")
    }
    .alert("Processing Error", isPresented: .constant(processingError != nil)) {
      Button("OK") { processingError = nil }
    } message: {
      Text(processingError ?? "")
    }
    .onChange(of: selectedImage) { oldValue, newValue in
      if let image = newValue {
        processImage(image)
      }
    }
  }

  private func copyText() {
    UIPasteboard.general.string = editedText
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.impactOccurred()
    withAnimation(.easeInOut(duration: 0.2)) { isCopied = true }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      withAnimation(.easeInOut(duration: 0.2)) { isCopied = false }
    }
  }

  private func processImage(_ image: UIImage) {
    // Start processing with smooth animation
    withAnimation(.easeInOut(duration: 0.3)) {
      isProcessing = true
    }
    processingError = nil

    Task {
      do {
        // Add slight delay to show loading state (remove in production if not needed)
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

        let excerpt = try await imageProcessor.process(image: image)

        await MainActor.run {
          // Smooth transition to results
          withAnimation(.easeInOut(duration: 0.5)) {
            isProcessing = false
            excerptCapture = excerpt
            editedText = excerpt.text
          }
          selectedImage = nil  // Reset for next use
        }
      } catch {
        await MainActor.run {
          withAnimation(.easeInOut(duration: 0.3)) {
            isProcessing = false
          }
          processingError = error.localizedDescription
          selectedImage = nil  // Reset on error
        }
      }
    }
  }

  private func generatePosts() {
    guard !editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
    isGenerating = true
    generationError = nil
    Task {
      do {
        let variants = try await AIClient.shared.generateVariants(
          from: editedText, bookTitle: nil, author: nil)
        await MainActor.run {
          generatedVariants = variants
          isGenerating = false
          showingVariants = true
        }
      } catch {
        await MainActor.run {
          isGenerating = false
          generationError = error.localizedDescription
        }
      }
    }
  }
}

// MARK: - Variants View
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

// MARK: - Variant Card
struct VariantCard: View {
  let variant: Variant
  @State private var isCopied = false

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
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
      Text(variant.text)
        .font(.body)
        .lineLimit(nil)
        .multilineTextAlignment(.leading)
      HStack(spacing: 12) {
        Button(action: copyVariant) {
          HStack {
            Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
            Text(isCopied ? "Copied" : "Copy")
          }
          .font(.subheadline)
          .foregroundColor(isCopied ? .green : .blue)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color(UIColor.systemGray6))
          .cornerRadius(6)
        }
        .disabled(isCopied)
        Button(action: shareVariant) {
          HStack {
            Image(systemName: "square.and.arrow.up")
            Text("Share")
          }
          .font(.subheadline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 8)
          .background(Color.blue)
          .cornerRadius(6)
        }
      }
    }
    .padding()
    .background(Color(UIColor.systemBackground))
    .cornerRadius(12)
    .shadow(radius: 1)
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

// MARK: - Feature Row Component
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

#Preview { ContentView() }

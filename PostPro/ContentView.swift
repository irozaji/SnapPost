//
//  ContentView.swift
//  PostPro
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
  @State private var previousExcerpt: ExcerptCapture?  // Track previous state for "Scan New"
  @FocusState private var isTextEditorFocused: Bool

  private let imageProcessor = ImageProcessor()

  var body: some View {
    NavigationView {
      VStack(spacing: 16) {
        // Content Area
        if isProcessing {
          ProcessingView(isProcessing: isProcessing)
        } else if let excerpt = excerptCapture {
          ExtractedTextView(
            excerpt: excerpt,
            editedText: $editedText,
            isTextEditorFocused: $isTextEditorFocused
          )
        } else {
          HomeView(
            onScanCamera: { showingCamera = true },
            onChooseFromLibrary: { showingPhotoPicker = true }
          )
        }

        // Bottom Action Bar
        VStack(spacing: 12) {
          if excerptCapture == nil {
            HomeActionsView(
              onScanCamera: { showingCamera = true },
              onChooseFromLibrary: { showingPhotoPicker = true }
            )
          } else {
            // Results actions - hide when keyboard is active
            if !isTextEditorFocused {
              ExtractedTextActionsView(
                editedText: editedText,
                isGenerating: isGenerating,
                onGeneratePosts: generatePosts
              )
            }
          }
        }
      }
      .padding()
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if excerptCapture != nil {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Home") {
              // Reset selectedImage immediately to clear PhotoPicker state
              selectedImage = nil
              withAnimation(.easeInOut(duration: 0.3)) {
                editedText = ""
                excerptCapture = nil
                previousExcerpt = nil  // Clear saved state when explicitly going home
              }
            }
            .foregroundColor(.blue)
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
              // Actions menu
              Menu {
                Button(action: {
                  // Save current state before opening camera
                  previousExcerpt = excerptCapture
                  showingCamera = true
                }) {
                  Label("Scan New", systemImage: "camera.viewfinder")
                }

                Button(action: {
                  showingPhotoPicker = true
                }) {
                  Label("Choose from Library", systemImage: "photo.on.rectangle")
                }
              } label: {
                Image(systemName: "ellipsis.circle")
                  .font(.title2)
                  .foregroundColor(.blue)
              }

              // Done button (only when editing)
              if isTextEditorFocused {
                Button("Done") {
                  isTextEditorFocused = false
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
              }
            }
          }
        }
      }
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
        // Reset previous state before processing new image
        editedText = ""
        excerptCapture = nil
        previousExcerpt = nil  // Clear saved state since we're processing new image
        processImage(image)
      }
    }
    .onChange(of: showingCamera) { oldValue, newValue in
      // Handle camera dismissal
      if !newValue && selectedImage == nil {
        // If we had a previous excerpt (from "Scan New"), restore it
        if let previous = previousExcerpt {
          excerptCapture = previous
          editedText = previous.text
          previousExcerpt = nil  // Clear after restoring
        } else {
          // Otherwise, reset to home (this was a fresh camera open)
          editedText = ""
          excerptCapture = nil
          selectedImage = nil  // Also clear selectedImage when going to home
        }
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
          // Reset selectedImage after a brief delay to ensure UI updates properly
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedImage = nil
          }
        }
      } catch {
        await MainActor.run {
          withAnimation(.easeInOut(duration: 0.3)) {
            isProcessing = false
          }
          processingError = error.localizedDescription
          // Reset selectedImage after error
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedImage = nil
          }
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

#Preview { ContentView() }

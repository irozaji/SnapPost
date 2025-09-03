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
  @State private var generationError: String?
  @State private var processingError: String?
  @State private var previousExcerpt: ExcerptCapture?  // Track previous state for "Scan New"
  @FocusState private var isTextEditorFocused: Bool

  // Dynamic layout state
  @State private var textEditorHeight: CGFloat = 200
  @State private var scrollPosition: CGFloat = 0

  private let imageProcessor = ImageProcessor()

  // MARK: - Computed Properties

  @ViewBuilder
  private var mainContent: some View {
    if isProcessing {
      processingView
    } else if excerptCapture != nil {
      resultsView
    } else {
      homeView
    }
  }

  private var processingView: some View {
    VStack(spacing: 16) {
      ProcessingView(isProcessing: isProcessing)
    }
    .padding()
    .navigationBarTitleDisplayMode(.inline)
  }

  private var resultsView: some View {
    GeometryReader { geometry in
      VStack(spacing: 0) {
        // Dynamic text editor at top
        let buttonHeight: CGFloat = (!isTextEditorFocused && generatedVariants.isEmpty) ? 100 : 0
        let availableHeight = geometry.size.height - buttonHeight - 40  // 40 for padding

        VStack(spacing: 12) {
          ExtractedTextView(
            excerpt: excerptCapture!,
            editedText: $editedText,
            isTextEditorFocused: $isTextEditorFocused,
            dynamicHeight: .constant(generatedVariants.isEmpty ? availableHeight : textEditorHeight)
          )
        }
        .padding(.horizontal)
        .padding(.top)

        // Scrollable variants area (if variants exist)
        if !generatedVariants.isEmpty {
          ScrollViewReader { proxy in
            ScrollView {
              LazyVStack(spacing: 16) {
                InlineVariantsView(variants: generatedVariants)
                  .id("variants")
              }
              .padding(.horizontal)
              .padding(.top, 16)
            }
            .onAppear {
              // Auto-scroll to show variants immediately after generation
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                  proxy.scrollTo("variants", anchor: .top)
                }
              }
            }
          }
        } else {
          // Spacer to push button to bottom when no variants
          Spacer()
        }

        // Fixed bottom button area
        VStack(spacing: 0) {
          if !isTextEditorFocused && generatedVariants.isEmpty {
            ExtractedTextActionsView(
              editedText: editedText,
              isGenerating: isGenerating,
              onGeneratePosts: generatePosts
            )
            .padding(.horizontal)
            .padding(.top, 16)
          }
        }
        .padding(.bottom)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      updateTextEditorHeight()
    }
    .onChange(of: isTextEditorFocused) { _, focused in
      withAnimation(.easeInOut(duration: 0.3)) {
        updateTextEditorHeight()
      }
    }
    .onChange(of: generatedVariants.isEmpty) { _, isEmpty in
      withAnimation(.easeInOut(duration: 0.3)) {
        updateTextEditorHeight()
      }
    }
  }

  private var homeView: some View {
    VStack(spacing: 16) {
      HomeView(
        onScanCamera: { showingCamera = true },
        onChooseFromLibrary: { showingPhotoPicker = true }
      )

      HomeActionsView(
        onScanCamera: { showingCamera = true },
        onChooseFromLibrary: { showingPhotoPicker = true }
      )
    }
    .padding()
    .navigationBarTitleDisplayMode(.inline)
  }

  private var homeButton: some View {
    Button("Home") {
      // Reset selectedImage immediately to clear PhotoPicker state
      selectedImage = nil
      withAnimation(.easeInOut(duration: 0.3)) {
        editedText = ""
        excerptCapture = nil
        previousExcerpt = nil  // Clear saved state when explicitly going home
        generatedVariants = []  // Clear variants when going home
        updateTextEditorHeight()  // Reset using dynamic calculation
      }
    }
    .foregroundColor(.blue)
  }

  private var trailingToolbarContent: some View {
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

  var body: some View {
    NavigationView {
      mainContent
        .toolbar {
          if excerptCapture != nil {
            ToolbarItem(placement: .navigationBarLeading) {
              homeButton
            }

            ToolbarItem(placement: .navigationBarTrailing) {
              trailingToolbarContent
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
      handleImageSelection(newValue)
    }
    .onChange(of: showingCamera) { oldValue, newValue in
      handleCameraDismissal(newValue)
    }
  }

  // MARK: - Helper Functions

  private func updateTextEditorHeight() {
    if isTextEditorFocused {
      // Expanded mode when focused
      textEditorHeight = generatedVariants.isEmpty ? 500 : 250
    } else if generatedVariants.isEmpty {
      // Use a large height that will be constrained by the available space in GeometryReader
      textEditorHeight = 1000  // This will be constrained by the actual available space
    } else {
      // Compact mode when variants are present and not focused
      textEditorHeight = 120
    }
  }

  private func handleImageSelection(_ image: UIImage?) {
    if let image = image {
      // Reset previous state before processing new image
      editedText = ""
      excerptCapture = nil
      previousExcerpt = nil  // Clear saved state since we're processing new image
      generatedVariants = []  // Clear variants when processing new image
      updateTextEditorHeight()  // Reset using dynamic calculation
      processImage(image)
    }
  }

  private func handleCameraDismissal(_ isShowing: Bool) {
    // Handle camera dismissal
    if !isShowing && selectedImage == nil {
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
          // Animate text editor to compact size after generation
          withAnimation(.easeInOut(duration: 0.3)) {
            updateTextEditorHeight()
          }
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

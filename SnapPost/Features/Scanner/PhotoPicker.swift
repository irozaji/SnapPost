//
//  PhotoPicker.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import PhotosUI
import SwiftUI

struct PhotoPicker: View {
  @Binding var selectedImage: UIImage?
  @Binding var isPresented: Bool

  @State private var selectedItem: PhotosPickerItem?

  var body: some View {
    PhotosPicker(
      selection: $selectedItem,
      matching: .images,
      preferredItemEncoding: .automatic
    ) {
      // This will never be shown since we're using it programmatically
      EmptyView()
    }
    .photosPicker(isPresented: $isPresented, selection: $selectedItem, matching: .images)
    .onChange(of: selectedItem) { _, newItem in
      Task {
        if let data = try? await newItem?.loadTransferable(type: Data.self),
          let image = UIImage(data: data)
        {
          await MainActor.run {
            selectedImage = image
          }
        }
      }
    }
  }
}

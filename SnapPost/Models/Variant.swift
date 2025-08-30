//
//  Variant.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import Foundation

struct Variant: Identifiable, Codable {
  let id: UUID
  let tone: Tone
  let text: String

  init(tone: Tone, text: String) {
    self.id = UUID()
    self.tone = tone
    self.text = text
  }
}

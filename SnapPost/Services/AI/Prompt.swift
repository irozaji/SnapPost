//
//  Prompt.swift
//  SnapPost
//
//  Created by AI Assistant.
//

import Foundation

enum Prompt {
  static let system = """
    You write short LinkedIn posts under 900 characters.
    Start with a strong hook line.
    Add 1 to 2 crisp supporting lines.
    End with a question to invite comments.
    Do not add hashtags unless explicitly requested.
    """

  static func user(excerpt: String, book: String?, author: String?) -> String {
    return """
      Source excerpt: "\(excerpt)"
      Book: \(book ?? "Unknown")
      Author: \(author ?? "Unknown")
      Generate 5 variants with tones: punchy, contrarian, personal, analytical, open-question.
      Return JSON array where each item is: {"tone":"<tone>", "text":"<post>"}
      """
  }
}

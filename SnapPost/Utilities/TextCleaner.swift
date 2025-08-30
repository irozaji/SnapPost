//
//  TextCleaner.swift
//  SnapPost
//
//  Created by AI Assistant on $(date).
//

import Foundation

struct TextCleaner {

  /// Removes text that looks like page numbers or repeated headers
  static func removePageNumbers(from lines: [String]) -> [String] {
    return lines.filter { line in
      let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

      // Skip empty lines
      if trimmed.isEmpty { return false }

      // Skip lines that are just numbers (page numbers)
      if trimmed.allSatisfy({ $0.isNumber }) { return false }

      // Skip very short lines that might be headers/footers
      if trimmed.count <= 2 { return false }

      // Skip lines that look like page headers (all caps, short)
      if trimmed.count < 30 && trimmed == trimmed.uppercased() { return false }

      return true
    }
  }

  /// Cleans the final text by removing hyphen line breaks, collapsing newlines, etc.
  static func clean(_ text: String) -> String {
    var cleaned = text

    // Remove hyphen line breaks "-\n" patterns
    cleaned = cleaned.replacingOccurrences(of: "-\n", with: "")
    cleaned = cleaned.replacingOccurrences(of: "-\r\n", with: "")

    // Replace newlines with spaces (preserve paragraph breaks if needed)
    cleaned = cleaned.replacingOccurrences(of: "\n", with: " ")
    cleaned = cleaned.replacingOccurrences(of: "\r", with: " ")

    // Collapse multiple spaces into single spaces
    while cleaned.contains("  ") {
      cleaned = cleaned.replacingOccurrences(of: "  ", with: " ")
    }

    // Trim leading and trailing whitespace
    cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

    return cleaned
  }
}

//
//  TextCleanerTests.swift
//  PostProTests
//
//  Created by AI Assistant on $(date).
//

import XCTest

@testable import PostPro

final class TextCleanerTests: XCTestCase {

  func testRemovePageNumbers() {
    let lines = [
      "This is a regular line of text",
      "42",  // Page number
      "Another line of text here",
      "123",  // Another page number
      "",  // Empty line
      "CH",  // Very short line (likely header)
      "CHAPTER ONE",  // All caps header
      "This is a longer line that should be kept",
      "5",  // Another page number
    ]

    let filtered = TextCleaner.removePageNumbers(from: lines)

    XCTAssertEqual(filtered.count, 2)
    XCTAssertEqual(filtered[0], "This is a regular line of text")
    XCTAssertEqual(filtered[1], "This is a longer line that should be kept")
  }

  func testCleanText() {
    let dirtyText = """
      This is a line with a hyphen-
      break that should be fixed.

      Multiple    spaces   should    be   collapsed.


      Multiple newlines should become single spaces.

         Leading and trailing whitespace should be removed.   
      """

    let cleanedText = TextCleaner.clean(dirtyText)
    let expectedText =
      "This is a line with a hyphenbreak that should be fixed. Multiple spaces should be collapsed. Multiple newlines should become single spaces. Leading and trailing whitespace should be removed."

    XCTAssertEqual(cleanedText, expectedText)
  }

  func testCleanTextWithHyphenLineBreaks() {
    let text = "This is a sen-\ntence that was broken across lines."
    let cleaned = TextCleaner.clean(text)

    XCTAssertEqual(cleaned, "This is a sentence that was broken across lines.")
  }

  func testCleanTextWithWindowsLineBreaks() {
    let text = "This is a sen-\r\ntence with Windows line breaks."
    let cleaned = TextCleaner.clean(text)

    XCTAssertEqual(cleaned, "This is a sentence with Windows line breaks.")
  }

  func testCleanEmptyText() {
    let emptyText = ""
    let cleaned = TextCleaner.clean(emptyText)

    XCTAssertEqual(cleaned, "")
  }

  func testCleanWhitespaceOnlyText() {
    let whitespaceText = "   \n\n   \r\n   "
    let cleaned = TextCleaner.clean(whitespaceText)

    XCTAssertEqual(cleaned, "")
  }
}

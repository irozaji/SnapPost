//
//  AIClientTests.swift
//  SnapPostTests
//
//  Created by AI Assistant.
//

import XCTest

@testable import SnapPost

final class AIClientTests: XCTestCase {

  func testAPIKeyConfiguration() {
    // Test if API key configuration check works
    let isConfigured = AIClient.shared.isConfigured()
    // This will be false with the default placeholder value
    XCTAssertFalse(isConfigured, "API key should not be configured with placeholder value")
  }

  func testEmptyExcerptHandling() async throws {
    do {
      _ = try await AIClient.shared.generateVariants(from: "", bookTitle: nil, author: nil)
      XCTFail("Should have thrown an error for empty excerpt")
    } catch AIClient.AIError.invalidResponse {
      // Expected error
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testNotConfiguredError() async throws {
    // With the default placeholder API key, should throw notConfigured error
    do {
      _ = try await AIClient.shared.generateVariants(
        from: "test excerpt", bookTitle: nil, author: nil)
      XCTFail("Should have thrown an error for not configured API key")
    } catch AIClient.AIError.notConfigured {
      // Expected error
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func testPromptGeneration() {
    let excerpt = "This is a test excerpt from a book."
    let bookTitle = "Test Book"
    let author = "Test Author"

    let userPrompt = Prompt.user(excerpt: excerpt, book: bookTitle, author: author)

    XCTAssertTrue(userPrompt.contains(excerpt))
    XCTAssertTrue(userPrompt.contains(bookTitle))
    XCTAssertTrue(userPrompt.contains(author))
    XCTAssertTrue(userPrompt.contains("Generate 5 variants"))
  }

  func testMockModeGeneration() async throws {
    // Mock mode should work regardless of API key configuration
    let excerpt = "This is a test excerpt about leadership and innovation."

    do {
      let variants = try await AIClient.shared.generateVariants(
        from: excerpt, bookTitle: "Test Book", author: "Test Author")

      // Should return exactly 5 variants
      XCTAssertEqual(variants.count, 5)

      // Should have all expected tones
      let tones = Set(variants.map { $0.tone })
      let expectedTones: Set<Tone> = [.punchy, .contrarian, .personal, .analytical, .openQuestion]
      XCTAssertEqual(tones, expectedTones)

      // All variants should contain part of the excerpt
      for variant in variants {
        XCTAssertFalse(variant.text.isEmpty)
        XCTAssertLessThanOrEqual(variant.text.count, 900)
      }
    } catch {
      XCTFail("Mock mode should not throw errors: \(error)")
    }
  }

  func testMockModeConfiguration() {
    // Test mock mode detection
    let isUsingMockMode = AIClient.shared.isUsingMockMode()

    #if DEBUG
      XCTAssertTrue(isUsingMockMode, "Should use mock mode in DEBUG builds")
    #else
      XCTAssertFalse(isUsingMockMode, "Should use real API in RELEASE builds")
    #endif
  }

  func testMockDataGeneration() {
    let excerpt = "Innovation requires courage to challenge the status quo."
    let mockData = AIConfig.generateMockVariants(from: excerpt)

    XCTAssertEqual(mockData.count, 5)

    let tones = mockData.map { $0.tone }
    XCTAssertEqual(tones, ["punchy", "contrarian", "personal", "analytical", "openQuestion"])

    // All mock variants should be non-empty and contain excerpt
    for mockVariant in mockData {
      XCTAssertFalse(mockVariant.text.isEmpty)
      XCTAssertTrue(mockVariant.text.contains("Innovation requires courage"))
    }
  }
}

//
//  AIConfig.swift
//  SnapPost
//
//  Created by AI Assistant.
//

import Foundation

enum AIConfig {
  static let maxTokens = 1600
  static let temperature = 0.8
  static let topP = 0.9
  static let requestTimeout: TimeInterval = 8

  // MARK: - API Key Configuration for v1 Personal Use
  // TODO: Replace with your OpenAI API key
  static let openAIAPIKey = "your-openai-api-key-here"

  // Helper to check if API key is configured
  static var isAPIKeyConfigured: Bool {
    return !openAIAPIKey.isEmpty && openAIAPIKey != "your-openai-api-key-here"
  }

  // MARK: - Mock Mode Configuration
  #if DEBUG
    static let useMockMode = true  // Automatic mock mode in DEBUG builds
  #else
    static let useMockMode = false  // Real API in RELEASE builds
  #endif

  // Manual override for testing (can override build configuration)
  static let forceMockMode: Bool? = nil  // Set to true/false to override, nil to use build config

  // Mock response delay simulation
  static let mockResponseDelaySeconds: Double = 1.5  // Realistic delay simulation

  // Final mock mode determination
  static var isUsingMockMode: Bool {
    return forceMockMode ?? useMockMode
  }

  // MARK: - Mock Data Generation
  static func generateMockVariants(from excerpt: String) -> [MockVariantData] {
    let shortExcerpt = String(excerpt.prefix(50))

    return [
      MockVariantData(
        tone: "punchy",
        text:
          "🚀 Just discovered this game-changing insight: \"\(shortExcerpt)...\" This completely shifts how I think about success. The implications for our industry are massive. What's your take on this perspective?"
      ),
      MockVariantData(
        tone: "contrarian",
        text:
          "Unpopular opinion: \"\(shortExcerpt)...\" Everyone's jumping on this bandwagon, but are we missing the bigger picture? Sometimes conventional wisdom needs challenging. What if we're all wrong about this?"
      ),
      MockVariantData(
        tone: "personal",
        text:
          "This passage stopped me in my tracks: \"\(shortExcerpt)...\" It reminded me of my own journey and the mistakes I've made along the way. Growth comes from embracing these uncomfortable truths. How has this resonated with your experience?"
      ),
      MockVariantData(
        tone: "analytical",
        text:
          "Breaking down this insight: \"\(shortExcerpt)...\" Three key factors emerge that could reshape our approach: 1) mindset shift 2) practical application 3) long-term impact. Which factor resonates most with your situation?"
      ),
      MockVariantData(
        tone: "openQuestion",
        text:
          "Fascinating perspective: \"\(shortExcerpt)...\" This raises so many questions about our current methods and assumptions. What would happen if we applied this thinking to your field? I'm curious about your thoughts."
      ),
    ]
  }

  struct MockVariantData {
    let tone: String
    let text: String
  }
}

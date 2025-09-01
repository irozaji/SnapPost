//
//  AIClient.swift
//  PostPro
//
//  Created by AI Assistant.
//

import Foundation

protocol PostGenerator {
  func generateVariants(
    from excerpt: String,
    bookTitle: String?,
    author: String?
  ) async throws -> [Variant]
}

final class AIClient: PostGenerator {
  static let shared = AIClient()

  private let urlSession: URLSession

  enum AIError: Error, LocalizedError {
    case invalidAPIKey
    case timeout
    case rateLimit
    case contentPolicy
    case invalidResponse
    case notConfigured

    var errorDescription: String? {
      switch self {
      case .invalidAPIKey:
        return "AI key is invalid. Please check your API key configuration."
      case .timeout:
        return "Request timed out. Please try again."
      case .rateLimit:
        return "Rate limit exceeded. Please wait and try again."
      case .contentPolicy:
        return "Content could not be processed by AI service."
      case .invalidResponse:
        return "Invalid response from AI service. Please try again."
      case .notConfigured:
        return "OpenAI API key not configured. Please add your API key to AIConfig.swift"
      }
    }
  }

  private struct APIRequest: Codable {
    let model: String
    let temperature: Double
    let topP: Double
    let maxTokens: Int
    let responseFormat: ResponseFormat
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
      case model, temperature, messages
      case topP = "top_p"
      case maxTokens = "max_tokens"
      case responseFormat = "response_format"
    }

    struct ResponseFormat: Codable {
      let type: String
    }

    struct Message: Codable {
      let role: String
      let content: String
    }
  }

  private struct APIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
      let message: Message

      struct Message: Codable {
        let content: String
      }
    }
  }

  private struct VariantResponse: Codable {
    let tone: String
    let text: String
  }

  private init() {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = AIConfig.requestTimeout
    config.timeoutIntervalForResource = AIConfig.requestTimeout
    self.urlSession = URLSession(configuration: config)
  }

  func generateVariants(from excerpt: String, bookTitle: String?, author: String?) async throws
    -> [Variant]
  {
    guard !excerpt.isEmpty else {
      throw AIError.invalidResponse
    }

    // Check if we should use mock mode
    if AIConfig.isUsingMockMode {
      return try await generateMockVariants(from: excerpt)
    }

    // Real API mode - check if API key is configured
    guard AIConfig.isAPIKeyConfigured else {
      throw AIError.notConfigured
    }

    let apiKey = AIConfig.openAIAPIKey

    // Prepare request
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let apiRequest = APIRequest(
      model: "gpt-4o-mini",
      temperature: AIConfig.temperature,
      topP: AIConfig.topP,
      maxTokens: AIConfig.maxTokens,
      responseFormat: APIRequest.ResponseFormat(type: "json_object"),
      messages: [
        APIRequest.Message(role: "system", content: Prompt.system),
        APIRequest.Message(
          role: "user", content: Prompt.user(excerpt: excerpt, book: bookTitle, author: author)),
      ]
    )

    request.httpBody = try JSONEncoder().encode(apiRequest)

    // Make request
    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await urlSession.data(for: request)
    } catch {
      // Check if it's a timeout
      if let urlError = error as? URLError, urlError.code == .timedOut {
        throw AIError.timeout
      }
      throw AIError.timeout
    }

    // Handle HTTP errors
    if let httpResponse = response as? HTTPURLResponse {
      switch httpResponse.statusCode {
      case 401:
        throw AIError.invalidAPIKey
      case 408:
        throw AIError.timeout
      case 429:
        throw AIError.rateLimit
      case 400...499:
        throw AIError.contentPolicy
      case 500...599:
        throw AIError.invalidResponse
      case 200:
        break
      default:
        throw AIError.invalidResponse
      }
    }

    // Parse response
    let apiResponse: APIResponse
    do {
      apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
    } catch {
      throw AIError.invalidResponse
    }

    guard let content = apiResponse.choices.first?.message.content else {
      throw AIError.invalidResponse
    }

    // Parse variants JSON
    let variantResponses: [VariantResponse]
    do {
      if let jsonData = content.data(using: .utf8) {
        variantResponses = try JSONDecoder().decode([VariantResponse].self, from: jsonData)
      } else {
        throw AIError.invalidResponse
      }
    } catch {
      throw AIError.invalidResponse
    }

    // Convert to Variant objects and validate length
    let variants = variantResponses.compactMap { variantResponse -> Variant? in
      guard
        let tone = Tone(
          rawValue: variantResponse.tone.lowercased().replacingOccurrences(of: "-", with: ""))
      else {
        return nil
      }

      var text = variantResponse.text

      // Truncate if too long (LinkedIn limit is 900 chars)
      if text.count > 900 {
        text = String(text.prefix(897)) + "..."
      }

      return Variant(tone: tone, text: text)
    }

    // Ensure we have variants
    guard !variants.isEmpty else {
      throw AIError.invalidResponse
    }

    return variants
  }

  /// Check if API key is configured for v1 personal use
  func isConfigured() -> Bool {
    return AIConfig.isAPIKeyConfigured
  }

  // MARK: - Mock Mode Implementation

  private func generateMockVariants(from excerpt: String) async throws -> [Variant] {
    // Log mock mode usage
    print("🎭 Using Mock Mode - No API calls made")

    // Simulate realistic network delay
    try await Task.sleep(nanoseconds: UInt64(AIConfig.mockResponseDelaySeconds * 1_000_000_000))

    // Generate mock data based on excerpt
    let mockData = AIConfig.generateMockVariants(from: excerpt)

    // Convert mock data to Variant objects
    let variants = mockData.compactMap { mockVariant -> Variant? in
      guard
        let tone = Tone(
          rawValue: mockVariant.tone.lowercased().replacingOccurrences(of: "-", with: ""))
      else {
        return nil
      }

      var text = mockVariant.text

      // Apply same length validation as real API
      if text.count > 900 {
        text = String(text.prefix(897)) + "..."
      }

      return Variant(tone: tone, text: text)
    }

    // Ensure we have variants (same validation as real API)
    guard !variants.isEmpty else {
      throw AIError.invalidResponse
    }

    return variants
  }

  /// Check if currently using mock mode
  func isUsingMockMode() -> Bool {
    return AIConfig.isUsingMockMode
  }
}

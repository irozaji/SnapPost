//
//  Tone.swift
//  PostPro
//
//  Created by AI Assistant on $(date).
//

import Foundation

enum Tone: String, Codable, CaseIterable {
  case punchy
  case contrarian
  case personal
  case analytical
  case openQuestion

  var displayName: String {
    switch self {
    case .punchy:
      return "Punchy"
    case .contrarian:
      return "Contrarian"
    case .personal:
      return "Personal"
    case .analytical:
      return "Analytical"
    case .openQuestion:
      return "Open Question"
    }
  }
}

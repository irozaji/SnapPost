# PRD: LinkedIn Post Companion (v1)

## Project overview

Build a native iOS app that lets a user capture text from a book in real time, generate 3 to 5 LinkedIn-ready post drafts with AI, then share instantly using the iOS share sheet into the LinkedIn app.  
**No backend in v1.**  
**No LinkedIn API usage.**  
All user data remains on device.

**Success criteria**

- Time from app launch to posting ≤ 20 seconds
- AI round trip ≤ 2.5 s
- Cold start to scanner ≤ 800 ms

**Target devices**

- iPhone, iOS 17+

**Primary frameworks**

- SwiftUI
- VisionKit `DataScannerViewController`
- Vision (fallback OCR)
- UniformTypeIdentifiers
- UserNotifications
- AppIntents

**Swift packages**

- SwiftLint
- SwiftFormat
- KeychainAccess (if API key stored locally)

---

## UX flow

1. **Quick entry**

   - User taps Lock Screen widget or app icon.
   - App opens directly into the Scanner.

2. **Scan**

   - Live text highlights over the page.
   - User taps capture.
   - Recognized text passed to Composer.

3. **Generate**

   - Composer shows excerpt.
   - User taps Generate.
   - AI returns 5 post variants.
   - Variant cards shown with Copy and Share actions.

4. **Post**

   - User taps Share.
   - iOS share sheet opens with LinkedIn target.
   - User posts inside LinkedIn.
   - App shows success toast.

5. **History**
   - List of last 20 items (excerpt, variant, timestamp).
   - Actions: Copy, Share again, Delete.

---

## Features

1. **Scanner**
2. **Composer**
3. **AI generation**
4. **Share to LinkedIn via share sheet**
5. **History**
6. **Quick entry (App Intent + widget)**
7. **Local reminder for “Later”** _(optional v1.1)_

---

## Requirements for each feature

### 1. Scanner

- Present `DataScannerViewController` with `.text()` recognition.
- Properties:

  ```swift
  isHighFrameRateTrackingEnabled = true
  qualityLevel = .accurate
  recognizesMultipleItems = false
  isGuidanceEnabled = true
  ```

- Output model:

  ```swift
  struct ExcerptCapture {
      let text: String
      let createdAt: Date
      let sourceHint: String?
  }
  ```

- Clean text:

  - Remove hyphen line breaks
  - Collapse spaces
  - Trim whitespace

- Info.plist: NSCameraUsageDescription

### 2. Composer

- Shows excerpt, Generate button, segmented tone selector.
- Displays up to 5 VariantCards with Copy and Share.
- Character counter warns > 900 chars.
- ViewModel:

  ```swift
  @MainActor
  final class ComposeVM: ObservableObject {
    @Published var excerpt: String = ""
    @Published var toneHints: [Tone] = [.punchy, .contrarian, .personal, .analytical, .openQuestion]
    @Published var variants: [Variant] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    func generate() async
  }
  ```

### 3. AI Generation

- Single request returns 5 variants.
- Timeout 8s. Show retry on error.
- Prompt constants:

  ```swift
  enum Prompt {
    static let system = "You write short LinkedIn posts under 900 characters. ..."
    static func user(excerpt: String, book: String?, author: String?) -> String { ... }
  }
  ```

- Config:

  ```swift
  enum AIConfig {
  static let maxTokens = 1600
  static let temperature = 0.8
  static let topP = 0.9
  static let requestTimeout: TimeInterval = 8
  }
  ```

- Security: API key in Keychain.

### 4. Share to LinkedIn

- Use UIActivityViewController with text.
- Completion handler stores history.
- Fallback: if LinkedIn not installed, user can copy.

### 5. History

- Store last 20 posted items in JSON file.
- Model:

  ```swift
  struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let excerpt: String
    let variant: Variant
    let postedAt: Date
  }
  ```

- Store at Application Support/history.json.

### 6. Quick entry

- AppIntent: ScanToDraftIntent.
- WidgetKit lock screen widget opens Scanner.
- Siri phrase: “Scan to Draft”.

### 7. Later reminder (v1.1)

- Optional action “Remind me later”.
- Uses UNUserNotificationCenter.

---

## Data models

```swift
enum Tone: String, Codable { case punchy, contrarian, personal, analytical, openQuestion }

struct Variant: Identifiable, Codable {
    let id: UUID
    let tone: Tone
    let text: String
}

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let excerpt: String
    let variant: Variant
    let postedAt: Date
}
```

---

## API contracts

### AI Provider (OpenAI style)

#### Endpoint

```
POST https://api.openai.com/v1/chat/completions
```

#### Headers

```
Authorization: Bearer <OPENAI_API_KEY>
Content-Type: application/json
```

#### Request body

```json
{
  "model": "gpt-4o-mini",
  "temperature": 0.8,
  "top_p": 0.9,
  "max_tokens": 1600,
  "response_format": { "type": "json_object" },
  "messages": [
    {
      "role": "system",
      "content": "You write short LinkedIn posts under 900 characters. ..."
    },
    {
      "role": "user",
      "content": "Source excerpt: \"{EXCERPT}\" Book: {BOOK} Author: {AUTHOR} ..."
    }
  ]
}
```

#### Response

```json
{
  "choices": [
    {
      "message": {
        "content": "[{tone: 'punchy', text: '...'}, {tone: 'contrarian', text: '...'}, ...]"
      }
    }
  ]
}
```

#### Error handling

- 401 invalid key → show “AI key invalid”
- Timeout (8s) → show retry
- Content policy error → “Excerpt could not be processed”

---

### Folder structure

```
SparkPost/
├── SparkPostApp.swift         // @main entry
├── Features/
│   ├── Scanner/
│   │   ├── ScannerView.swift
│   │   └── ScannerViewModel.swift
│   ├── Composer/
│   │   ├── ComposerView.swift
│   │   └── ComposeVM.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── HistoryStore.swift
│   └── Share/
│       └── ShareView.swift
├── Models/
│   ├── Variant.swift
│   └── HistoryItem.swift
├── Services/
│   ├── AIClient.swift
│   └── Prompt.swift
├── Utilities/
│   ├── Extensions.swift
│   └── Constants.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Preview Content
└── Info.plist
```

---

### Acceptance criteria

- Cold start to scanner ≤ 800 ms
- OCR to excerpt ≤ 300 ms
- AI generation ≤ 2.5 s
- Share sheet opens LinkedIn reliably
- History shows posted item with timestamp
- App works offline for scanning + history; AI generation requires network

# PRD: LinkedIn Post Companion (v1) — Image-capture OCR

## Project overview

Build a native iOS app for personal productivity that lets you capture an image of book pages or paragraphs, run on-device image preprocessing and OCR to extract clean text, generate 5 LinkedIn-ready post drafts with AI, then share instantly using the iOS share sheet into the LinkedIn app.

**v1 Scope:**

- **Personal productivity app** - designed for individual use
- **Direct OpenAI API integration** - no backend required
- **No user accounts or subscriptions** - single-user app
- **No LinkedIn API usage** - share sheet only
- All user data remains on device

**v2+ Future Plans:**

- User accounts and subscription management
- Backend infrastructure for multi-user support
- Usage analytics and billing

**Success criteria**

- Time from app launch to posting ≤ 20 seconds
- AI round trip ≤ 2.5 s
- Cold start to camera picker ≤ 800 ms
- Image capture → cleaned excerpt ≤ 1.2 s on a modern device (typical page photo, perspective correction + OCR)

**Target devices**

- iPhone, iOS 17+

**Primary frameworks**

- SwiftUI
- Vision (`VNDetectRectanglesRequest`, `VNRecognizeTextRequest`)
- CoreImage (perspective correction and simple enhancement)
- PHPicker / UIImagePickerController
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
   - App opens directly into the Scanner (Image Capture) screen.

2. **Capture**

   - User chooses `Take Photo` or `Choose from Library`.
   - App receives UIImage and shows a preview with a `Use Image` action.

3. **Process**

   - App runs `ImageProcessor.process(image:)`.
   - Steps inside `process`: detect page rectangle, perspective-correct the image, optional enhancement (contrast), run `VNRecognizeTextRequest`, order lines, clean text.
   - Process returns `ExcerptCapture` with cleaned `text`.

4. **Generate Posts**

   - Results screen shows extracted text in an editable TextEditor.
   - User can edit the text before generating posts.
   - User taps "Generate Posts" button.
   - AI returns 5 post variants.
   - Variant cards shown with Copy and Share actions in a sheet.

5. **Post**

   - User taps Share.
   - iOS share sheet opens with LinkedIn target.
   - User posts inside LinkedIn.
   - App shows success toast.

6. **History**

   - List of last 20 items (excerpt, variant, timestamp).
   - Actions: Copy, Share again, Delete.

---

## Features

1. **Image Capture + ImageProcessor (OCR)**
2. **Inline Post Generation** (Integrated into main results screen)
3. **AI generation**
4. **Share to LinkedIn via share sheet**
5. **History**
6. **Quick entry (App Intent + widget)**

---

## Requirements for each feature

### 1. Scanner (ImageCapture)

**High-level**
Scanner is an image-capture UI that returns a `UIImage` to the `ImageProcessor`. It does not run live OCR. It allows the user to take a photo or pick one from the photo library and then confirm before processing.

**Files / Components**

- `Features/Scanner/ImageCaptureView.swift` (SwiftUI)

  - Binding: `@Binding var result: ExcerptCapture?`
  - Buttons: `Take Photo`, `Choose from Library`, `Use Image`, `Cancel`
  - Uses `ImagePicker` (camera) and `PhotoPicker` (PHPicker)

- `Features/Scanner/ImagePicker.swift` and `PhotoPicker.swift` helpers (provided wrappers)

**Behavior**

- After selecting image, show preview and `Use Image` button.
- `Use Image` triggers `ImageProcessor.process(image:)` async and shows `ProgressView`.
- On success, populate `result` with returned `ExcerptCapture`.
- On failure, show friendly error with retry.

**Permissions**

- `NSCameraUsageDescription` required for camera
- `NSPhotoLibraryUsageDescription` required for photo library

---

### 2. ImageProcessor (core OCR + preprocessing)

**Purpose**
Process a captured `UIImage` into a cleaned text excerpt.

**File / Class**

- `Services/ImageOCR/ImageProcessor.swift`
- Public API:

  ```swift
  final class ImageProcessor {
      struct Config { ... }           // see config below
      init(config: Config = Config())
      func process(image: UIImage) async throws -> ExcerptCapture
  }
  ```

**Config (explicit var names)**

```swift
struct Config {
    var recognitionLanguages: [String] = ["en-US"]
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    var usesLanguageCorrection: Bool = true
    var rectangleMinAspectRatio: Float = 0.5
    var rectangleMinimumSize: Float = 0.2
    var rectangleQuadratureTolerance: Float = 20.0
    var rectangleMinimumConfidence: VNConfidence = 0.5
    var yTolerancePixels: CGFloat = 18.0 // used in ordering rows
    var maxImageWidthForProcessing: CGFloat = 1500  // scale down high-res images
}
```

**Processing steps (implementation must follow this order)**

1. Normalize image: scale down if needed to `maxImageWidthForProcessing` while keeping aspect ratio.
2. Run `VNDetectRectanglesRequest` to find page-like rectangle(s).
3. If a rectangle found with `confidence >= rectangleMinimumConfidence` choose highest confidence and apply perspective correction with CoreImage `CIPerspectiveCorrection` using rectangle's `topLeft/topRight/bottomLeft/bottomRight` mapped to image coordinates.
4. Optionally run a contrast filter with `CIColorControls` (small contrast boost).
5. Run `VNRecognizeTextRequest` with `recognitionLevel` and `recognitionLanguages` and `usesLanguageCorrection`.
6. Convert `VNRecognizedTextObservation` bounding boxes to image coordinates with the helper `rectForBoundingBox(_ normalizedRect: CGRect, imageSize: CGSize) -> CGRect`.
7. Build an array of `OCRLine { text:String, boundingBox:CGRect }` from top candidate `.topCandidates(1)`.
8. Order lines with `orderAndExtractLines(from:)` using `yTolerancePixels` to group rows and `minX` to sort left-to-right.
9. Drop lines that look like page numbers or repeated headers using `TextCleaner.removePageNumbers`.
10. Clean final text using `TextCleaner.clean(...)` which:

    - removes hyphen line breaks `"-\n"` patterns
    - collapses newlines into spaces (preserve paragraph breaks if you choose but v1 collapses)
    - collapse multiple spaces
    - trim leading/trailing whitespace

11. Return `ExcerptCapture(text: cleanedText, sourceHint: nil, confidence: nil)`.

**Error handling**

- Throw `ImageProcessor.Error.invalidImage` if input unusable.
- Throw `ImageProcessor.Error.visionFailed` on unexpected Vision errors.
- Caller shows retry UI on error.

**Ordering function signature**

```swift
private func orderAndExtractLines(from lines: [OCRLine], yTolerance: CGFloat) -> [String]
```

**Tuning notes**

- `yTolerancePixels` must be scaled for image resolution if you scale images before processing (e.g., multiply tolerance by scale factor).
- `maxImageWidthForProcessing = 1500` yields good speed/accuracy balance. Tune if device slow.

---

### 3. Inline Post Generation

**Implementation**

- Post generation is now integrated directly into the main results screen (`ContentView.swift`)
- No separate Composer view or view model needed
- Text editing happens inline with the extracted text
- Generation triggered directly from "Generate Posts" button

**UI Components**

- `TextEditor` for editable extracted text (full-height container)
- Two primary action buttons: "Copy" and "Generate Posts"
- Progress indicator during generation
- Variants displayed in a sheet with individual Copy/Share actions
- Error handling with retry functionality

**Data Flow**

- User edits extracted text in `TextEditor`
- "Generate Posts" calls `AIClient.shared.generateVariants(from: editedText, bookTitle: nil, author: nil)`
- Results displayed in `VariantsView` sheet
- Each variant has Copy and Share functionality

---

### 4. AI Generation

**Service interface**
File: `Services/AI/AIClient.swift`

```swift
protocol PostGenerator {
    func generateVariants(from excerpt: String,
                          bookTitle: String?,
                          author: String?) async throws -> [Variant]
}

final class AIClient: PostGenerator {
    static let shared = AIClient()
    // Implementation uses provider with constants below
    func generateVariants(from excerpt: String, bookTitle: String?, author: String?) async throws -> [Variant] { ... }
}
```

**Prompt constants**
File: `Services/AI/Prompt.swift`

```swift
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
```

**AI config constants**
File: `Services/AI/AIConfig.swift`

```swift
enum AIConfig {
    static let maxTokens = 1600
    static let temperature = 0.8
    static let topP = 0.9
    static let requestTimeout: TimeInterval = 8
}
```

**Behavior**

- Single HTTP POST returns a JSON string with 5 variants.
- Parse that JSON into `[Variant]`.
- If a variant >900 chars then truncate/trim and set `error` with message "Variant trimmed to meet LinkedIn length."

**Errors**

- 401 → throw `.invalidAPIKey` and show user-facing message "AI key invalid. Update in Settings."
- 408 / timeout → throw `.timeout` and allow user to retry.
- 429 → surface rate-limit with a retry button but do not auto-retry in v1.

**Storage of API key**

- For v1 (personal productivity use), API key is configured in the app's configuration
- No user-facing API key management in v1
- Direct OpenAI API calls from the app
- Subscription and user management planned for v2
- API key can be stored in app configuration or environment variables for development

---

### 5. Share to LinkedIn

**Implementation**

- Share functionality is now integrated into the `VariantsView` in `ContentView.swift`
- Uses `UIActivityViewController` directly for sharing

**Contract**

- Input: `String` variantText
- Present activity controller:

  ```swift
  let activityVC = UIActivityViewController(
    activityItems: [variantText],
    applicationActivities: nil
  )
  ```

- If LinkedIn not installed, the share sheet still shows "Copy" and "Post to LinkedIn (via web)" might not be available
- Each variant has its own Copy and Share buttons for immediate action

---

### 6. History (local JSON file)

**Implementation**

- File: `Features/History/HistoryStore.swift`
- API:

  ```swift
  final class HistoryStore {
      static let shared = HistoryStore()
      func add(_ item: HistoryItem) throws
      func load() throws -> [HistoryItem]
      func delete(id: UUID) throws
  }
  ```

**Storage**

- Path: `Application Support/SparkPost/history.json`
- Keep last 20 items. Evict oldest when adding the 21st.

**Model**

```swift
struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let excerpt: String
    let variant: Variant
    let postedAt: Date
}
```

---

### 7. Quick entry (App Intent + widget)

**AppIntent**

- File: `Features/Intents/ScanToDraftIntent.swift`
- Intent should deep link to `myapp://scan` or call `ImageCaptureView` directly.

**Widget**

- Lock Screen widget that calls the AppIntent and opens the app directly to Image Capture.

**Siri**

- Intent registered with phrase: "Scan to Draft"

---

## Data models (explicit)

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

struct ExcerptCapture: Identifiable, Codable {
    let id: UUID
    let text: String
    let createdAt: Date
    let sourceHint: String?
    let confidence: Float?
}
```

---

## API contracts

### AI Provider (OpenAI-style example)

**Endpoint**

```
POST https://api.openai.com/v1/chat/completions
```

**Headers**

```
Authorization: Bearer <OPENAI_API_KEY>
Content-Type: application/json
```

**Request body**

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

**Response**

- `choices[0].message.content` contains a JSON array string; parse to `[Variant]`.

**Errors and handling**

- 401 invalid key → show "AI key invalid"
- 408 timeout → show retry
- 429 rate limit → surface message and allow manual retry
- Content policy errors → "Excerpt could not be processed"

---

## Folder structure (updated)

```
SnapPost/
├── SnapPostApp.swift
├── ContentView.swift (main interface with inline generation)
├── Features/
│   ├── Scanner/
│   │   ├── ImageCaptureView.swift
│   │   ├── ImagePicker.swift
│   │   └── PhotoPicker.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── HistoryStore.swift
│   └── Intents/
│       └── ScanToDraftIntent.swift
├── Models/
│   ├── Variant.swift
│   ├── Tone.swift
│   └── ExcerptCapture.swift
├── Services/
│   ├── ImageOCR/
│   │   └── ImageProcessor.swift
│   └── AI/
│       ├── AIClient.swift
│       ├── AIConfig.swift
│       └── Prompt.swift
├── Utilities/
│   └── TextCleaner.swift
├── Assets.xcassets
└── Info.plist
```

---

## Info.plist required keys

Add or verify these keys in `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We use the camera to capture text from your book for composing posts.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We request access so you can pick images to extract text from.</string>

<key>UIApplicationSceneManifest</key>
<dict>
  <key>UIApplicationSupportsMultipleScenes</key>
  <false/>
</dict>
```

---

## Acceptance criteria

- Cold start to camera picker ≤ 800 ms
- Image capture → cleaned excerpt ≤ 1.2 s (typical case)
- AI generation ≤ 2.5 s
- Share sheet opens LinkedIn reliably
- History shows posted item with timestamp
- App works offline for scanning + history; AI generation requires network

---

## Implementation notes for your AI coding assistant

- **Do not** implement the live `DataScannerViewController` flow. The scanner must be image-capture based. The team chose image-capture for robustness and perspective correction.
- **Do** implement `ImageProcessor.process(image:)` exactly as specified: rectangle detection → perspective correction → optional enhancement → `VNRecognizeTextRequest` → ordering → `TextCleaner.clean`.
- **Do** scale down very large images to `maxImageWidthForProcessing` before Vision work to control CPU and memory.
- **Do** expose tuning parameters in `ImageProcessor.Config` so testers can adjust `yTolerancePixels` and `maxImageWidthForProcessing` without code changes.
- **Do** store history in `Application Support/SnapPost/history.json` as a JSON array with max length 20.
- **Do not** call any LinkedIn REST API in v1. Use share sheet only.
- **Do** configure OpenAI API key in app configuration for v1 personal use (no user management)
- **Do** include unit tests for `TextCleaner.clean(...)` and `orderAndExtractLines(...)` using synthetic bounding boxes and example OCR text.
- **Do** show friendly retry UI for AI timeouts and for Vision errors. Surface meaningful messages like "Try again with a clearer photo" or "Check network and retry".
- **✅ COMPLETED**: Post generation is now integrated inline into the main results screen (`ContentView.swift`) - no separate Composer needed
- **✅ COMPLETED**: Text editing happens directly in the extracted text area with full-height `TextEditor`
- **✅ COMPLETED**: Share functionality integrated into variant display with `UIActivityViewController`

---

## Next steps & day-by-day sprint

- Day 1: Project scaffold, ImageCaptureView + image pickers, Info.plist keys
- Day 2: Implement ImageProcessor.process(image:) rectangle detection + perspective correction + CI enhancements
- Day 3: Implement Vision text recognition + ordering + TextCleaner + unit tests
- Day 4: ✅ COMPLETED - Inline generation UI integrated into main ContentView, AIClient integration
- Day 5: Real AI integration, History store, TestFlight build

---

If you want, I can now generate a single file `Services/ImageOCR/ImageProcessor.swift` (complete, compile-ready) and a small unit test file `Tests/TextCleanerTests.swift` that your AI coding assistant can drop into the project and run. Which one should I produce first?

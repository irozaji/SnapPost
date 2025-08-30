# SnapPost Implementation Checklist

## Project Overview

Building a native iOS app for **personal productivity** that captures images of book pages, runs OCR to extract text, generates LinkedIn-ready posts with AI, and shares via iOS share sheet.

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

**Target**: iOS 17+, SwiftUI, No backend in v1

---

## 🎯 Success Criteria

- [ ] Time from app launch to posting ≤ 20 seconds
- [ ] AI round trip ≤ 2.5 s
- [ ] Cold start to camera picker ≤ 800 ms
- [ ] Image capture → cleaned excerpt ≤ 1.2 s on modern device

---

## 📱 Features Implementation Status

### 1. Scanner (Image Capture + ImageProcessor with OCR) ✅ COMPLETED

- [x] **Core Models**
  - [x] `ExcerptCapture.swift` - Data model for captured text
  - [x] `Tone.swift` - Enum for post tones
- [x] **Text Processing Utilities**
  - [x] `TextCleaner.swift` - Text cleaning and filtering utilities
  - [x] Unit tests for `TextCleaner` functionality
- [x] **ImageProcessor Service**
  - [x] `ImageProcessor.swift` - Complete OCR pipeline implementation
  - [x] Rectangle detection with Vision framework
  - [x] Perspective correction with CoreImage
  - [x] Contrast enhancement
  - [x] Text recognition with VNRecognizeTextRequest
  - [x] Line ordering and text extraction
  - [x] Configurable parameters (Config struct)
  - [x] Error handling (invalidImage, visionFailed)
- [x] **Scanner UI Components**
  - [x] `ImagePicker.swift` - Camera capture wrapper (UIKit required for camera)
  - [x] `PhotoPicker.swift` - Pure SwiftUI PhotosPicker implementation
  - [x] `ImageCaptureView.swift` - Main scanner interface
  - [x] Image preview and confirmation UI
  - [x] Processing progress indicator
  - [x] Error handling with retry functionality
- [x] **Integration**
  - [x] Updated `ContentView.swift` with scanner integration
  - [x] Text display and copy functionality
  - [x] Time ago formatting for captured text
- [x] **Permissions**
  - [x] Camera usage description in Info.plist
  - [x] Photo library usage description in Info.plist

### 2. Composer ✅ COMPLETED

- [x] **Data Models**
  - [x] `Variant.swift` - Data model for generated post variants
- [x] **View Model**
  - [x] `ComposeVM.swift` - Observable object for compose state
  - [x] Excerpt binding and display
  - [x] Tone hints (5 variants: punchy, contrarian, personal, analytical, openQuestion)
  - [x] Variants array management
  - [x] Loading and error states
  - [x] AI client integration for generation
- [x] **UI Components**
  - [x] `ComposerView.swift` - Main compose interface
  - [x] Excerpt display card with character count
  - [x] Optional book details input (title and author)
  - [x] Generate button with loading state
  - [x] Variant cards with tone badges and character limits
  - [x] Copy and Share buttons for each variant
  - [x] Progress view during generation
  - [x] Error handling with retry functionality
- [x] **AI Service (Stub)**
  - [x] `AIClient.swift` - Service interface and mock implementation
  - [x] PostGenerator protocol definition
  - [x] Mock variant generation for testing
- [x] **Integration**
  - [x] Navigation from scanner results
  - [x] Sheet presentation from ContentView
  - [x] Compose button in extracted text display

### 3. AI Generation ✅ COMPLETED (v1 Simplified)

- [x] **Service Layer** ✅ COMPLETED
  - [x] `AIClient.swift` - Main AI service interface
  - [x] `PostGenerator` protocol definition
  - [x] HTTP client for OpenAI API calls
  - [x] JSON parsing for variant responses
- [x] **Configuration** ✅ COMPLETED
  - [x] `Prompt.swift` - System and user prompt templates
  - [x] `AIConfig.swift` - API configuration constants
  - [x] ~~Keychain integration for API key storage~~ ❌ REMOVE - Not needed for v1
- [x] **Error Handling** ✅ COMPLETED
  - [x] 401 (Invalid API key) handling
  - [x] 408/timeout handling with retry
  - [x] 429 (Rate limit) handling
  - [x] Content policy error handling
- [x] **Features** ✅ COMPLETED
  - [x] Variant length validation (≤900 chars)
  - [x] Automatic truncation with user notification

**✅ DEVELOPMENT MODE IMPLEMENTATION COMPLETED:**

- [x] **Mock Mode Configuration** ✅ COMPLETED
  - [x] Add `useMockMode` flag to `AIConfig.swift`
  - [x] Add environment detection (DEBUG vs RELEASE)
  - [x] Add mock response delay configuration
  - [x] Add mock mode toggle for easy switching
- [x] **Mock Data Generation** ✅ COMPLETED
  - [x] Create realistic mock variant responses
  - [x] Ensure mock data follows LinkedIn post guidelines
  - [x] Add variety in mock responses for testing
  - [x] Make mock data dynamic based on input excerpt
- [x] **AIClient Mock Integration** ✅ COMPLETED
  - [x] Modify `generateVariants()` to check mock mode
  - [x] Implement mock response logic with realistic delay
  - [x] Maintain same error handling for consistency
  - [x] Add logging to distinguish mock vs real API calls
- [x] **Testing & Validation** ✅ COMPLETED
  - [x] Test mock mode vs real API mode switching
  - [x] Verify UI behavior consistency between modes
  - [x] Add unit tests for mock mode functionality
  - [x] Test error scenarios in mock mode
- [x] **UI Development Tools** ✅ COMPLETED
  - [x] Mock mode status indicator in ComposerView
  - [x] Visual distinction between mock and real modes
  - [x] Console logging for development tracking

**📊 OpenAI Response Data Structure Specification:**

**Expected JSON Response Format:**

```json
[
  {
    "tone": "punchy",
    "text": "🚀 This insight completely changed my perspective on leadership..."
  },
  {
    "tone": "contrarian",
    "text": "Unpopular opinion: What if everything we know about..."
  },
  {
    "tone": "personal",
    "text": "This passage hit me hard. It reminded me of my own journey..."
  },
  {
    "tone": "analytical",
    "text": "Breaking down this concept: 3 key factors emerge..."
  },
  {
    "tone": "openQuestion",
    "text": "Fascinating perspective that raises so many questions..."
  }
]
```

**Data Validation Rules:**

- [ ] **Tone Values**: Must exactly match: `punchy`, `contrarian`, `personal`, `analytical`, `openQuestion`
- [ ] **Text Length**: Each post must be ≤900 characters (LinkedIn limit)
- [ ] **Content Structure**: Hook line + 1-2 supporting lines + engaging question
- [ ] **Response Count**: Exactly 5 variants (one per tone)
- [ ] **JSON Format**: Valid JSON array with consistent structure
- [ ] **Error Handling**: Graceful fallback for malformed responses

**🔄 Data Flow & Parsing:**

- [ ] **OpenAI Response**: Raw JSON string in `choices[0].message.content`
- [ ] **JSON Parsing**: Parse content string to `[VariantResponse]` array
- [ ] **Tone Mapping**: Convert string tones to `Tone` enum values
- [ ] **Length Validation**: Check and truncate posts >900 characters
- [ ] **Final Output**: Convert to `[Variant]` array for UI display
- [ ] **Error Recovery**: Handle parsing failures gracefully with user feedback

### 4. Share to LinkedIn 🚧 NOT STARTED

- [ ] **Share Components**
  - [ ] `ShareView.swift` - UIActivityViewController wrapper
  - [ ] Share sheet presentation
  - [ ] Completion handling
- [ ] **Integration**
  - [ ] Share button in variant cards
  - [ ] History logging on successful share
  - [ ] Fallback copy functionality

### 5. History (Local Storage) 🚧 NOT STARTED

- [ ] **Data Layer**
  - [ ] `HistoryStore.swift` - Local JSON file management
  - [ ] `HistoryItem.swift` - Data model for history entries
  - [ ] File system operations (save/load/delete)
  - [ ] 20-item limit with automatic eviction
- [ ] **UI Components**
  - [ ] `HistoryView.swift` - History list interface
  - [ ] History item cards
  - [ ] Copy, Share again, Delete actions
- [ ] **Storage**
  - [ ] Application Support directory setup
  - [ ] JSON serialization/deserialization

### 6. Quick Entry (App Intent + Widget) 🚧 NOT STARTED

- [ ] **App Intents**
  - [ ] `ScanToDraftIntent.swift` - Intent definition
  - [ ] Deep link handling (`myapp://scan`)
  - [ ] Siri phrase registration: "Scan to Draft"
- [ ] **Widget**
  - [ ] Lock Screen widget configuration
  - [ ] Widget UI implementation
  - [ ] Intent integration
- [ ] **App Integration**
  - [ ] Deep link URL scheme setup
  - [ ] Intent handling in app

---

### 7. Mock Mode Development ✅ COMPLETED

**Purpose**: Enable cost-effective development without OpenAI API calls

**Core Features**

- [ ] **Environment Detection**
  - [ ] DEBUG vs RELEASE build configuration
  - [ ] Automatic mock mode in DEBUG builds
  - [ ] Manual override capability for testing
- [ ] **Mock Response System**
  - [ ] Realistic LinkedIn post templates
  - [ ] Dynamic content based on input excerpt
  - [ ] Configurable response delay simulation
  - [ ] Error scenario simulation
- [ ] **Development Tools**
  - [ ] Mock mode status indicator in UI
  - [ ] Easy switching between mock/real modes
  - [ ] Mock data customization for testing
  - [ ] Performance metrics in mock mode

**Benefits**

- [x] **💰 Cost**: $0 during development
- [x] **⚡ Speed**: Instant responses for UI testing
- [x] **🔄 Reliability**: No network issues or API limits
- [x] **🧪 Testing**: Consistent responses for UI validation
- [x] **🚀 Development**: Focus on app features, not API costs

---

## 🛠 Technical Infrastructure

### Project Structure ✅ COMPLETED

- [x] Models folder with core data structures
- [x] Features folder with organized components
- [x] Services folder for business logic
- [x] Utilities folder for helper functions
- [x] Proper import organization

### Dependencies 🚧 PARTIAL

- [x] SwiftUI (built-in) - Primary UI framework
- [x] Vision framework (built-in) - OCR and image processing
- [x] CoreImage (built-in) - Image perspective correction and enhancement
- [x] PhotosUI (built-in) - Native SwiftUI photo picker
- [x] UIKit (minimal usage) - Only for camera access and clipboard
- [ ] Swift packages to add:
  - [ ] SwiftLint
  - [ ] SwiftFormat
  - [x] ~~KeychainAccess~~ ❌ REMOVED - Not needed for v1 personal use

### Testing 🚧 PARTIAL

- [x] Unit tests for TextCleaner
- [ ] Unit tests for ImageProcessor line ordering
- [ ] Integration tests for OCR pipeline
- [ ] UI tests for scanner flow

---

## 🧪 Testing Checklist

- [ ] Camera permission flow
- [ ] Photo library permission flow
- [ ] Image processing with sample images
- [ ] OCR accuracy with book pages
- [ ] Error handling (invalid images, network issues)
- [ ] Share sheet functionality
- [ ] History persistence
- [ ] Performance benchmarks (meet success criteria)

---

## 📚 PRD Compliance

- [x] Image-capture based (not live DataScannerViewController) ✅
- [x] Rectangle detection → perspective correction → enhancement → OCR ✅
- [x] Image scaling to maxImageWidthForProcessing ✅
- [x] Configurable tuning parameters ✅
- [x] Application Support storage location (planned)
- [x] No LinkedIn REST API usage (share sheet only) ✅
- [x] ~~Keychain for API keys~~ ❌ UPDATED - Direct API key configuration for v1 personal use
- [x] Unit tests for core utilities ✅

---

## ✅ v1 Simplification Status

**Current State**: AI Generation feature simplified for v1 personal use ✅ COMPLETED
**Action Completed**: Removed user-facing complexity, simplified for personal productivity
**Next**: Configure your OpenAI API key in `AIConfig.swift` and test the full flow

---

_Last Updated: August 30, 2025_
_Status: Scanner, Composer, and AI Generation completed. Ready for API key configuration and testing._

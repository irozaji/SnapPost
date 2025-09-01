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

## Planned UI Update: Scanner Results Simplification (✅ COMPLETED)

## Planned UI Update: Navigation & Layout Restructuring (Pending Review)

**Scope**

- Restructure the app to have clear, intuitive navigation between states
- Eliminate confusing duplicate buttons and unclear navigation paths
- Create a proper screen hierarchy with clear user flows
- Implement iOS-standard navigation patterns

**UX Problems Identified**

1. **Confusing duplicate buttons**: "Scan Text" and "Scan New Text" both do the same thing
2. **No way to return home**: Once text is extracted, users are "trapped" in the results view
3. **Unclear navigation flow**: The relationship between scanning, editing, and returning home isn't intuitive
4. **Poor button hierarchy**: No clear distinction between primary actions and navigation actions

**Proposed Solution: Navigation Stack Architecture**

**Screen Structure:**

1. **Home Screen** - Clean, focused design with single "Scan Text" action
2. **Scanner Screen** - Camera/photo picker with preview and confirmation
3. **Results Screen** - Editable extracted text with clear action buttons
4. **Generated Posts Sheet** - Modal presentation of AI-generated variants

**User Flows:**

- **Flow 1**: Home → Scan → Results → Copy → Back to Home
- **Flow 2**: Home → Scan → Results → Generate Posts → View Variants → Share/Copy → Back to Home
- **Flow 3**: Home → Scan → Results → Scan New Image → New Results

**Button Hierarchy & Layout:**

**Home Screen:**

- Single, prominent "Scan Text" button (primary action)
- Clean, app-like design with no extracted text clutter

**Results Screen:**

- **Top section**: Editable extracted text (full height TextEditor)
- **Bottom section**: Action buttons in logical groups
  - **Primary actions** (high visual weight): Copy, Generate Posts
  - **Navigation actions** (medium visual weight): Scan New Image, Back to Home
- **Clear visual separation** between action and navigation buttons

**Navigation Patterns:**

- **iOS standard navigation bar** with back button and clear titles
- **Always provide escape** - users should never feel trapped
- **Clear purpose** for each button
- **Consistent placement** across screens
- **Logical flow** that matches user mental models

**Key UX Decisions:**

1. **Navigation Style**: iOS standard navigation stack (not modal)

   - **Rationale**: Familiar pattern, clear back navigation, natural flow
   - **Implementation**: Standard navigation bar with back button, clear titles

2. **Button Hierarchy**: Most intuitive button hierarchy

   - **Primary Actions**: Copy, Generate Posts (high visual weight, prominent placement)
   - **Secondary Actions**: Scan New Image, Back to Home (medium visual weight, grouped together)
   - **Visual Distinction**: Use iOS button styles (filled vs outlined) to show hierarchy

3. **Screen Transitions**: Navigation stack approach
   - **Flow**: Home → Scanner → Results → Generated Posts (sheet)
   - **Pros**: Familiar iOS pattern, clear back navigation, natural flow
   - **Cons**: More complex state management
   - **Best for**: Users who expect standard app navigation

**HIG-aligned Bottom-first Layout (✅ COMPLETED)**

- Home
  - Bottom Action Bar pinned to safe area:
    - Primary: “Scan Text” (filled, full-width)
    - Secondary: “Choose from Library” (outline, full-width)
  - Optional brief helper text above the bar; no large header/branding.
- Scanner entry
  - Preferred: Tap “Scan Text” opens Camera immediately (no choice screen).
  - Alternative: If source choice is needed, present as a bottom sheet with stacked buttons (Take Photo, Choose from Library), Cancel at bottom.
- Results
  - Content: full-height editable `TextEditor`.
  - Bottom Action Bar pinned to safe area:
    - Primary: “Generate Posts” (filled, full-width)
    - Secondary: “Copy” (outline, full-width)
  - Tertiary: “Scan New” as a link beneath the bar; top-left Back returns to Home.
- Generated Posts
  - Present as a bottom sheet (medium detent; expandable). Dismiss with swipe or “Done”.
  - Variant cards with Copy/Share per card.
- Transitions
  - Home → Camera/Library: system pickers; return to Results.
  - Results → Generated Posts: bottom sheet.
  - Back: nav bar back to Home; swipe-down to dismiss sheet.

**Acceptance Criteria (Bottom-first)** ✅ COMPLETED

- [x] All primary CTAs are bottom-aligned and within safe area.
- [x] Home presents camera directly; source selection (if used) appears as a bottom sheet.
- [x] Results shows "Generate Posts" (primary) and "Copy" (secondary) at the bottom.
- [x] Clear escape paths: Back from Results; swipe-down from Generated Posts.
- [x] Buttons meet 44pt min height and adequate spacing; dynamic type and contrast respected.

**Implementation Plan**

1. **Restructure ContentView** to use proper navigation stack
2. **Create distinct screen states** with clear navigation between them
3. **Implement proper button hierarchy** with visual distinction
4. **Add navigation bar** with back buttons and clear titles
5. **Eliminate duplicate buttons** and confusing navigation paths
6. **Test user flows** to ensure intuitive navigation

**Acceptance Criteria**

- [ ] Clear navigation between Home, Scanner, and Results screens
- [ ] No duplicate or confusing buttons
- [ ] Always provide a way to return home or navigate away
- [ ] Proper button hierarchy with visual distinction
- [ ] iOS-standard navigation patterns
- [ ] Intuitive user flows for all use cases
- [ ] No "trapped" states where users can't navigate away

**Files to Modify**

- `SnapPost/ContentView.swift` - Complete restructuring for navigation stack
- Navigation state management and screen transitions
- Button hierarchy and visual design
- User flow implementation

**Scope**

- Remove the "Captured just now" timestamp label from the results view
- Rename "Copy Text" to "Copy" and add a clear copied state with haptics
- Make the extracted text container take nearly full screen height for comfortable reading
- Remove the dedicated Compose Post view; keep generation inline from the results screen
- After extraction, provide only two primary actions: "Copy" and "Generate Posts"

**Execution Plan**

1. Results Screen UX adjustments (in `SnapPost/ContentView.swift`) ✅ COMPLETED

   - [x] Remove timestamp/"Captured just now" label and any related time-ago helpers
   - [x] Make extracted text editable in place
     - [x] Replace read-only text with `TextEditor` bound to local state initialized from OCR result
     - [x] Ensure edits are preserved while view is active and used by actions
   - [x] Make text container fill available vertical space:
     - [x] Use layout that expands (e.g., `ScrollView` with `frame(maxHeight: .infinity, alignment: .top)` within a flexible container)
     - [x] Ensure safe-area padding and comfortable line spacing
   - [x] Replace "Copy Text" with "Copy" button
     - [x] Copy to clipboard using `UIPasteboard` (use the edited text)
     - [x] Add copied state (label changes to "Copied" for ~1.5s, then reverts)
     - [x] Provide light haptic feedback on success and accessibility announcements
   - [x] Primary actions: show only two buttons — "Copy" and "Generate Posts"
     - [x] Arrange with consistent spacing, min tappable area, and margins

2. Remove Composer view flow ✅ COMPLETED

   - [x] Remove navigation/sheet trigger to `ComposerView`
   - [x] Inline generation entry point from results screen via "Generate Posts"
   - [x] De-register `ComposerView.swift` and `ComposeVM.swift` from the build
   - [x] Update project file references (no dead files in target)

3. Inline Generate Posts flow (no dedicated Composer screen) ✅ COMPLETED

   - [x] On tap "Generate Posts": start generation with existing `AIClient` using the current edited text
   - [x] Show progress indicator while generating
   - [x] Present results inline (e.g., bottom sheet or expandable section within results screen)
     - [x] Display 5 variants with tone badges and length validation (≤900 chars)
     - [x] Each variant provides Copy and Share actions
   - [x] Mirror existing error handling and retry behavior
   - [x] Respect mock mode flag for development

4. Spacing and visual polish ✅ COMPLETED
   - [x] Consistent horizontal padding, vertical spacing between sections, and readable typography
   - [x] Ensure layout adapts well to different Dynamic Type sizes

**Acceptance Criteria** ✅ COMPLETED

- [x] No timestamp text (e.g., "Captured just now") is visible anywhere in the results UI
- [x] The extracted text area is editable, occupies most of the screen height, and is easily scrollable
- [x] Only two primary actions are visible post-extraction: "Copy" and "Generate Posts"
- [x] Copy button copies the edited text, shows a transient "Copied" state, and provides haptic feedback
- [x] Generating posts uses the edited text, does not navigate to a Composer screen, and results are shown within the results context (sheet/inline)
- [x] Proper spacing/margins are applied; UI looks balanced on modern iPhones

**Files Impacted**

- `SnapPost/ContentView.swift` ✅ UPDATED - Complete UI overhaul with editable text, inline generation, and new action buttons
- `SnapPost/Features/Composer/ComposerView.swift` ✅ REMOVED - Deleted from project
- `SnapPost/Features/Composer/ComposeVM.swift` ✅ REMOVED - Deleted from project
- `SnapPost/Services/AI/AIClient.swift` ✅ REUSED - No changes needed, integrated directly
- `SnapPost/Utilities/TextCleaner.swift` ✅ UNCHANGED - No changes needed
- `SnapPost.xcodeproj/project.pbxproj` ✅ UNCHANGED - File system-based project automatically excluded deleted files

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

### 2. Composer ❌ REMOVED - Functionality integrated into main ContentView

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
- [x] **Integration** ❌ REMOVED - No longer needed, functionality integrated into main ContentView
  - [x] ~~Navigation from scanner results~~ ❌ REMOVED
  - [x] ~~Sheet presentation from ContentView~~ ❌ REMOVED
  - [x] ~~Compose button in extracted text display~~ ❌ REMOVED

### 3. AI Generation ✅ COMPLETED

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
  - [x] Mock mode status indicator in main ContentView
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

### 4. Share to LinkedIn ✅ COMPLETED

- [x] **Share Components** ✅ COMPLETED
  - [x] `ShareSheet` wrapper (UIViewControllerRepresentable) implemented inside `VariantsView` in `ContentView.swift`
  - [x] Share sheet presentation from generated variants
  - [x] Completion handling via `UIActivityViewController`
- [x] **Integration**
  - [x] Share button in variant cards
  - [x] Basic history logging on successful share (UserDefaults)
  - [x] Fallback copy functionality (Copy button)

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

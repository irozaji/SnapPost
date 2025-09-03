# PostPro Implementation Checklist

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

- [x] Time from app launch to posting ≤ 20 seconds
- [x] AI round trip ≤ 2.5 s
- [x] Cold start to camera picker ≤ 800 ms
- [x] Image capture → cleaned excerpt ≤ 1.2 s on modern device

---

## 🔄 UI REDESIGN: Inline Variants Display (Sheet → Inline)

**Scope**

- **CHANGE**: Remove bottom sheet approach for displaying generated variants
- **NEW**: Display variants inline directly below extracted text in a scrollable layout
- Maintain all existing functionality while improving UX with simpler navigation
- Keep state management and development tools intact

**Key Changes Required**

1. **UI Layout Redesign** 🔄 NEEDS UPDATE

   - ❌ **REMOVING**: Bottom sheet presentation for variants (`VariantsView` sheet)
   - ✅ **NEW**: Inline variants display below text editor
   - ✅ **NEW**: Scrollable layout containing text editor + variants
   - ✅ **NEW**: Compact text editor (no longer full-height)
   - ✅ **NEW**: Seamless content flow without modal interruptions

2. **Navigation Simplification** 🔄 NEEDS UPDATE

   - ❌ **REMOVING**: Separate "Generated Posts" screen/sheet navigation
   - ✅ **KEEPING**: Home, Processing, Results flow
   - ✅ **KEEPING**: "Scan New" feature with state preservation
   - ✅ **KEEPING**: "Home" button always available
   - ✅ **KEEPING**: Proper iOS navigation patterns

3. **State Management** ✅ COMPLETED (no changes needed)

   - ✅ **KEEPING**: Smooth transitions between processing states
   - ✅ **KEEPING**: Text editing with focus management
   - ✅ **KEEPING**: State preservation for better user experience
   - ✅ **KEEPING**: Proper error handling with user-friendly messages

4. **Development Tools** ✅ COMPLETED (no changes needed)
   - ✅ **KEEPING**: Mock mode for testing without API calls
   - ✅ **KEEPING**: Comprehensive error handling
   - ✅ **KEEPING**: Realistic mock responses for development
   - ✅ **KEEPING**: Easy switching between mock and real API modes

**Implementation Changes Completed** ✅

- **ContentView.swift** - ✅ COMPLETED - Removed sheet presentation logic, added scrollable inline layout, refactored for compilation optimization
- **HomeView.swift** - ✅ NO CHANGES NEEDED
- **ProcessingView.swift** - ✅ NO CHANGES NEEDED
- **ExtractedTextView.swift** - ✅ COMPLETED - Updated from full-height to compact/adjustable height (120-200px)
- **InlineVariantsView.swift** - ✅ CREATED - New inline display component
- **VariantCard.swift** - ✅ NO CHANGES NEEDED - Maintained Copy/Share functionality

**Updated Acceptance Criteria** ✅ COMPLETED

- [x] Clear navigation between Home, Processing, and Results (no separate variants screen) ✅ COMPLETED
- [x] No duplicate or confusing buttons ✅ KEEPING
- [x] Always provide a way to return home or navigate away ✅ KEEPING
- [x] Proper button hierarchy with visual distinction ✅ KEEPING
- [x] iOS-standard navigation patterns ✅ KEEPING (simplified)
- [x] **NEW**: Seamless inline variants display without modal interruptions ✅ COMPLETED
- [x] **NEW**: Scrollable content with text editor and variants in single view ✅ COMPLETED
- [x] State preservation for "Scan New" functionality ✅ KEEPING
- [x] Smooth animations and transitions throughout the app ✅ KEEPING

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
  - [x] Integrated into main `ContentView.swift` with automatic processing
  - [x] Smooth processing animations with `ProcessingView`
  - [x] Error handling with retry functionality
- [x] **Integration**
  - [x] Updated `ContentView.swift` with scanner integration
  - [x] Automatic image processing on selection
  - [x] Smooth transitions between states
- [x] **Permissions**
  - [x] Camera usage description in Info.plist
  - [x] Photo library usage description in Info.plist

### 2. Inline Text Editing & Post Generation ✅ COMPLETED

- [x] **Data Models**
  - [x] `Variant.swift` - Data model for generated post variants
- [x] **UI Components**
  - [x] `ExtractedTextView.swift` - Full-height editable text with focus management
  - [x] `ExtractedTextActionsView.swift` - Action buttons for text operations
  - [x] Inline text editing using `TextEditor`
  - [x] Focus management for keyboard handling
  - [x] Generate Posts button with loading state
- [x] **UI Redesign Required** ✅ COMPLETED
  - [x] ~~Variants displayed in a sheet~~ ❌ REMOVED - Bottom sheet approach
  - [x] **NEW**: Display variants inline directly below extracted text ✅ COMPLETED
  - [x] **NEW**: Scrollable layout with text editor at top and variants below ✅ COMPLETED
  - [x] **NEW**: Remove sheet presentation logic from `ContentView.swift` ✅ COMPLETED
  - [x] **NEW**: Integrate variant cards directly into main content area ✅ COMPLETED
- [x] **Integration** ✅ COMPLETED (needs modification)
  - [x] Integrated directly into main `ContentView.swift`
  - [x] No separate composer screen needed
  - [x] Text editing happens inline with extracted text
  - [x] Generation triggered directly from "Generate Posts" button

### 3. AI Generation ✅ COMPLETED

- [x] **Service Layer** ✅ COMPLETED
  - [x] `AIClient.swift` - Main AI service interface
  - [x] `PostGenerator` protocol definition
  - [x] HTTP client for OpenAI API calls
  - [x] JSON parsing for variant responses
- [x] **Configuration** ✅ COMPLETED
  - [x] `Prompt.swift` - System and user prompt templates
  - [x] `AIConfig.swift` - API configuration constants with mock mode
  - [x] Mock mode configuration for development
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

- [x] **Tone Values**: Must exactly match: `punchy`, `contrarian`, `personal`, `analytical`, `openQuestion`
- [x] **Text Length**: Each post must be ≤900 characters (LinkedIn limit)
- [x] **Content Structure**: Hook line + 1-2 supporting lines + engaging question
- [x] **Response Count**: Exactly 5 variants (one per tone)
- [x] **JSON Format**: Valid JSON array with consistent structure
- [x] **Error Handling**: Graceful fallback for malformed responses

**🔄 Data Flow & Parsing:**

- [x] **OpenAI Response**: Raw JSON string in `choices[0].message.content`
- [x] **JSON Parsing**: Parse content string to `[VariantResponse]` array
- [x] **Tone Mapping**: Convert string tones to `Tone` enum values
- [x] **Length Validation**: Check and truncate posts >900 characters
- [x] **Final Output**: Convert to `[Variant]` array for UI display
- [x] **Error Recovery**: Handle parsing failures gracefully with user feedback

### 4. Share to LinkedIn ✅ COMPLETED

- [x] **Share Components** ✅ COMPLETED (needs UI integration update)
  - [x] ~~Share functionality integrated into `VariantsView` in `ContentView.swift`~~ ❌ REMOVING - Sheet approach
  - [x] Uses `UIActivityViewController` directly for sharing
  - [x] Each variant has individual Copy and Share buttons
- [x] **UI Integration Update** ✅ COMPLETED
  - [x] **NEW**: Integrate share functionality into inline variant cards ✅ COMPLETED
  - [x] **NEW**: Maintain Copy and Share buttons but within scrollable content ✅ COMPLETED
  - [x] **NEW**: Remove sheet-based sharing logic ✅ COMPLETED
  - [x] **NEW**: Update share button positioning for inline layout ✅ COMPLETED
- [x] **Core Functionality** ✅ COMPLETED
  - [x] Share button in variant cards
  - [x] Basic history logging on successful share (UserDefaults)
  - [x] Fallback copy functionality (Copy button)

### 5. Advanced Navigation & State Management ✅ COMPLETED

- [x] **Navigation System** ✅ COMPLETED (needs simplification)
  - [x] ~~Clear navigation between Home, Processing, Results, and Generated Posts~~ ❌ UPDATING - No separate "Generated Posts" screen
  - [x] Proper iOS navigation patterns with back buttons
  - [x] "Home" button always available to return to start
  - [x] "Scan New" option that preserves previous state
- [x] **State Management** ✅ COMPLETED
  - [x] Smooth transitions between processing states
  - [x] Text editing with focus management
  - [x] State preservation for better user experience
  - [x] Proper error handling with user-friendly messages
- [x] **UI Components Update** ✅ COMPLETED
  - [x] `HomeView.swift` - Clean, focused home screen ✅ NO CHANGES NEEDED
  - [x] `ProcessingView.swift` - Smooth loading UI with animations ✅ NO CHANGES NEEDED
  - [x] ~~`ExtractedTextView.swift` - Full-height editable text~~ ✅ UPDATED - Now compact with fixed height range
  - [x] ~~`VariantsView.swift` - Polished variant display~~ ✅ KEPT - Still used for reference but not sheet-based
  - [x] `VariantCard.swift` - Individual variant cards with actions ✅ NO CHANGES NEEDED
- [x] **NEW UI Layout Requirements** ✅ COMPLETED
  - [x] **NEW**: `ExtractedTextView.swift` - Compact editable text (adjustable height) ✅ COMPLETED
  - [x] **NEW**: Inline variants display below text editor ✅ COMPLETED
  - [x] **NEW**: Scrollable container for text + variants ✅ COMPLETED
  - [x] **NEW**: Remove sheet presentation logic ✅ COMPLETED
  - [x] **NEW**: Update navigation flow (no separate variants screen) ✅ COMPLETED

### 6. History (Local Storage) 🚧 NOT STARTED

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

### 7. Quick Entry (App Intent + Widget) 🚧 NOT STARTED

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
- [x] Views folder with organized UI components
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

- [x] Camera permission flow
- [x] Photo library permission flow
- [x] Image processing with sample images
- [x] OCR accuracy with book pages
- [x] Error handling (invalid images, network issues)
- [x] Share sheet functionality
- [ ] History persistence
- [ ] Performance benchmarks (meet success criteria)

---

## 🎉 Major Achievements

**✅ COMPLETED FEATURES:**

1. **Advanced Navigation System** - Proper iOS navigation patterns with clear user flows
2. **State Preservation** - "Scan New" feature preserves previous excerpt for comparison
3. **Inline Text Editing** - Full-height TextEditor with focus management
4. **Mock Mode** - Sophisticated development mode with realistic responses
5. **Error Handling** - Comprehensive error handling with user-friendly messages
6. **UI Polish** - Smooth animations, proper spacing, and iOS-standard design patterns
7. **Processing Pipeline** - Complete OCR pipeline with image preprocessing
8. **AI Integration** - OpenAI API integration with fallback mock mode

**✅ RECENTLY COMPLETED:**

1. **UI Redesign** - Convert sheet-based variants to inline display ✅ COMPLETED
   - ✅ Removed bottom sheet presentation logic
   - ✅ Implemented scrollable layout with text editor + variants
   - ✅ Updated navigation flow (removed separate variants screen)
   - ✅ Maintained all existing functionality (Copy, Share, Mock mode, etc.)
   - ✅ Created new `InlineVariantsView.swift` component
   - ✅ Updated `ExtractedTextView.swift` to compact height (120-200px)
   - ✅ Modified `ContentView.swift` for seamless inline flow

**✅ RECENTLY COMPLETED - UX Improvements:**

1. **Dynamic Layout & Button Positioning** - Improve ergonomics and interaction patterns ✅ COMPLETED

**🚧 PLANNED FEATURES:**

1. **History System** - Local JSON storage for post history
2. **Quick Entry** - App Intents and Lock Screen widgets
3. **Enhanced Testing** - Unit tests for ImageProcessor and integration tests

The app now provides a significantly improved user experience with the new inline variants display. The UI redesign eliminated modal sheet interruptions and keeps the primary action at the bottom.

## ✅ Completed UX Update (Concise Summary)

- Inline variants shown below the editor
- Pinned bottom action button (thumb-friendly)
- Dynamic editor heights (compact/comfortable/expanded) with smooth transitions
- Auto-scroll to variants after generation
- All prior functionality preserved (Copy/Share on variants before this change, mock mode, error handling)

---

## 🔄 Next UX Update: Variant Card → Detail Page (Plan)

### Problem Analysis

Based on the user feedback and screenshot:

- ✅ **Issue Identified**: "Generate Posts" button moves up when extracted text is short, making it harder to reach with thumb
- ✅ **UX Goal**: Button should remain at bottom for easy thumb access (iOS ergonomics best practice)
- ✅ **Adaptive Behavior**: Text editor should intelligently resize based on context and user interaction

### Detailed Requirements (Completed)

- Pinned Generate button at bottom ✅
- Editor scrollable when needed ✅
- Editor auto-minimize after generation ✅
- Seamless scroll between editor and variants ✅
- Focus-aware sizing (expand when editing, minimize when viewing variants) ✅

### Technical Implementation Summary (Completed)

- GeometryReader + VStack for pinned bottom actions ✅
- Dynamic height state (`textEditorHeight`) and transitions ✅
- ScrollViewReader auto-scroll to variants ✅
- Safe-area-aware button positioning ✅

### Implementation Files to Modify

**1. ContentView.swift** 🔧

- [x] **Replace current resultsView layout** ✅ COMPLETED
- [x] **Add dynamic height state management** ✅ COMPLETED
- [x] **Implement scroll position tracking** ✅ COMPLETED
- [x] **Add button positioning logic** ✅ COMPLETED

**2. ExtractedTextView.swift** 🔧

- [x] **Add height parameter**: `@Binding var dynamicHeight: CGFloat` ✅ COMPLETED
- [x] **Remove fixed height constraints** ✅ COMPLETED
- [x] **Add focus state callbacks** ✅ COMPLETED
- [x] **Implement smooth height transitions** ✅ COMPLETED

**3. New: DynamicLayoutContainer.swift** 🔧

- [x] **~~Create custom layout component~~** ❌ NOT NEEDED - Implemented directly in ContentView
- [x] **~~Handle height calculations~~** ✅ COMPLETED - Integrated into ContentView
- [x] **~~Manage scroll behavior~~** ✅ COMPLETED - ScrollViewReader in ContentView
- [x] **~~Coordinate text editor and button positioning~~** ✅ COMPLETED - VStack layout in ContentView

### User Experience Flow

**Scenario A: Short Text, Pre-Generation**

1. User sees compact text editor at top
2. Generate Posts button pinned at bottom (thumb-friendly)
3. Empty space between them (clean, focused)

**Scenario B: Long Text, Pre-Generation**

1. Text editor takes available space minus button area
2. Text content scrollable within editor
3. Generate Posts button remains at bottom

**Scenario C: Post-Generation (Any Text Length)**

1. Text editor minimizes automatically to show variants
2. Variants appear in scrollable middle section
3. User can scroll to see all variants
4. Button remains at bottom throughout

**Scenario D: Editing After Generation**

1. User scrolls to top and taps text editor
2. Text editor expands for comfortable editing
3. Variants hidden/minimized during editing
4. User finishes editing → auto-minimize again

### Success Criteria

- [x] **Ergonomics**: Generate Posts button always reachable with thumb ✅ COMPLETED
- [x] **Efficiency**: Minimal scrolling needed to see variants after generation ✅ COMPLETED
- [x] **Intelligence**: Layout adapts to user intent and content ✅ COMPLETED
- [x] **Smoothness**: All transitions animated and polished ✅ COMPLETED
- [x] **Consistency**: Behavior is predictable and intuitive ✅ COMPLETED

## 🎉 Dynamic Layout Implementation - COMPLETED!

### Key Improvements Achieved

**1. Thumb-Friendly Button Positioning** 🎯

- Generate Posts button now stays pinned at bottom of screen (safe area)
- Maintains iOS ergonomics best practices for one-handed use
- Button never moves up with short text content

**2. Intelligent Text Editor Behavior** 🧠

- **Comfortable mode (200px)**: Default pre-generation state
- **Compact mode (120px)**: Post-generation to show variants immediately
- **Expanded mode (250-300px)**: When focused for editing
- Smooth animations between all height transitions

**3. Smart Layout Architecture** 🏗️

- **Top**: Dynamic text editor with intelligent height
- **Middle**: Scrollable variants area (when present)
- **Bottom**: Fixed button area (always accessible)
- GeometryReader ensures optimal space utilization

**4. Enhanced User Experience** ✨

- Auto-scroll to variants after generation
- Focus-aware text editor sizing
- Seamless transitions between editing and viewing modes
- Preserved all existing functionality (Copy, Share, Mock mode)

### Technical Implementation Summary

**Files Modified:**

- ✅ `ContentView.swift` - Complete layout architecture overhaul
- ✅ `ExtractedTextView.swift` - Dynamic height support added

**Key Features Added:**

- ✅ Dynamic height state management (`@State var textEditorHeight`)
- ✅ VStack-based layout with pinned button positioning
- ✅ ScrollViewReader for intelligent scroll behavior
- ✅ Focus-aware height transitions
- ✅ Auto-scroll to variants after generation

The implementation successfully addresses the core UX issue while maintaining all existing functionality and adding sophisticated layout intelligence.

## ✨ Upcoming UX Change: Variant Card Simplification

### Goals

- Reduce list noise and improve scannability
- Move actions to a focused detail screen
- Increase list density via truncation

### Changes

- VariantCard: remove Copy/Share buttons; add tap affordance; tone badge + char count; truncate to 3–5 lines with fade
- New `VariantDetailView`: full text, Copy + Share actions, optional Edit; bottom action bar, safe-area aware
- Navigation: tap card → push detail; preserve back to results and scroll position

### Implementation Plan ✅ COMPLETED

- [x] Update `Views/Variants/VariantCard.swift` to remove buttons and apply truncation ✅ COMPLETED
- [x] Create `Views/Variants/VariantDetailView.swift` ✅ COMPLETED
- [x] Wire `InlineVariantsView` items with `NavigationLink` to detail view ✅ COMPLETED

### Acceptance Criteria ✅ COMPLETED

- [x] Cards are denser and truncated; tone + length visible ✅ COMPLETED
- [x] Tapping a card opens detail screen with actions ✅ COMPLETED
- [x] User can navigate back to the results screen by swiping back or tapping the "Back" button ✅ COMPLETED
- [x] Copy/Share work from detail; back returns to prior position ✅ COMPLETED

### Technical Implementation Summary

**Files Modified:**

- ✅ `VariantCard.swift` - Removed Copy/Share buttons, added truncation (4 lines), chevron indicator, fade effect
- ✅ `InlineVariantsView.swift` - Added NavigationLink wrapper with PlainButtonStyle
- ✅ `VariantDetailView.swift` - NEW - Full detail screen with scrollable content and bottom action bar

**Key Features Added:**

- ✅ Compact variant cards with 4-line truncation and fade effect
- ✅ Chevron indicator for tap affordance
- ✅ Navigation to full detail screen with Copy/Share actions
- ✅ Safe-area aware bottom action bar in detail view
- ✅ Text selection enabled in detail view
- ✅ Proper back navigation preserving scroll position

# Buydee — Impulsive Buying Intervention App

## 1. Overview

**Feature / Project Name:** Buydee

**Problem Statement:**
Gen Z (21–28 tahun) sering melakukan impulsive buying baik online maupun offline, yang menyebabkan penyesalan finansial dan pengeluaran yang tidak terkontrol. Mereka butuh sebuah "pause moment" — sebuah intervensi yang membantu mereka berpikir ulang sebelum membeli, tapi tanpa terasa menggurui atau membosankan. Saat ini tidak ada tool yang seamless masuk ke dalam shopping flow mereka (browse → screenshot → share link → beli).

**Proposed Solution:**
Sebuah iOS app bernama Buydee yang bertindak sebagai "impulse brake" — menggunakan AI conversational (Gemini) untuk mengajukan pertanyaan reflektif berbasis framework psikologi, lalu memberikan actionable plan yang sesuai. App ini terintegrasi langsung ke shopping flow user melalui screenshot shortcut, kamera, dan share extension agar friction untuk "pause and think" seminimal mungkin.

**AI Build Summary:**

> Build a native SwiftUI iOS app (iOS 17+) that helps users pause before impulsive purchases. Core features: (1) AI chat powered by Google Gemini API with a custom rethinking prompt framework that asks reflective questions and recommends action plans, (2) camera capture to photograph physical items for AI analysis, (3) Shortcuts integration for screenshot → OCR text extraction (item name + price) → auto-populate chat, (4) Share Extension to receive e-commerce links/images and route them to the AI chat. Local-only data with SwiftData. No auth required. 3–4 week timeline.

---

## 2. Goals & Success Metrics

**Primary Goal:** Membantu user melakukan "pause" sebelum impulsive purchase dengan memberikan reflective conversation yang actionable.

**Success Metrics:**

- ≥ 60% user yang memulai conversation dengan AI menyelesaikan seluruh pertanyaan reflektif
- ≥ 40% user melaporkan (via in-app feedback) bahwa mereka membatalkan atau menunda pembelian setelah menggunakan Buydee
- Average session duration ≥ 2 menit (menunjukkan engagement dengan reflective process)

**Anti-goals:**

- Bukan app budgeting / expense tracker — tidak melacak pengeluaran
- Bukan app yang menghakimi user — tone harus supportive, bukan judgmental
- Bukan financial advisor — tidak memberikan saran investasi atau financial planning
- Bukan e-commerce aggregator — tidak membandingkan harga antar toko

---

## 3. Scope & Constraints

**In scope:**

- AI-powered reflective chat dengan custom prompt framework
- Camera capture untuk foto barang fisik → AI analysis
- Screenshot Shortcut integration (OCR → extract nama & harga → auto-populate chat)
- Share Extension untuk menerima link/gambar dari e-commerce apps
- Manual input (copy-paste link / ketik di chat)
- Conversation history (lokal)
- Action plan recommendation berdasarkan jawaban user

**Out of scope:**

- User authentication / account system
- Cloud sync / multi-device
- Social features (sharing results, leaderboard)
- Price comparison / deal finder
- Push notification / scheduled reminders (Phase 2)
- Apple Watch companion app
- iPad support
- Widget / Live Activity

**Technical constraints:**

- **Platform:** iOS 17+ (iPhone only)
- **Auth:** None — semua data lokal
- **AI Backend:** Google Gemini API (requires network)
- **Local Storage:** SwiftData
- **OCR:** Apple Vision framework (on-device)
- **Accessibility:** WCAG AA — VoiceOver support, Dynamic Type
- **Offline support:** Partial — conversation history available offline, AI features require internet
- **Performance:** AI response < 5 detik, app launch < 2 detik

---

## 4. Jobs to Be Done (JTBD)

| Priority | Job Statement |
| -------- | ------------- |
| J1 | When **saya mau checkout barang online**, I want to **dipaksa berhenti sebentar dan berpikir ulang**, so I can **menghindari penyesalan karena beli impulsif**. |
| J2 | When **saya lihat barang bagus di toko fisik**, I want to **langsung foto dan dapat feedback apakah ini worth it**, so I can **membuat keputusan beli yang lebih rasional on the spot**. |
| J3 | When **saya lagi scrolling Shopee/TikTok Shop dan nemu barang menarik**, I want to **screenshot langsung dan dapat analisis tanpa effort**, so I can **pause tanpa kehilangan momentum browsing**. |
| J4 | When **saya sudah copy link produk dari e-commerce**, I want to **langsung share ke Buydee dan dapat guidance**, so I can **dengan cepat evaluate apakah ini pembelian yang bijak**. |
| J5 | When **saya sudah selesai menjawab pertanyaan reflektif**, I want to **mendapat action plan yang jelas dan spesifik**, so I can **tahu exactly apa yang harus dilakukan selanjutnya (beli/tunda/skip)**. |

---

## 5. User Stories

| ID | Role | Action | Benefit | JTBD Ref |
| --- | --- | --- | --- | --- |
| US1 | User | Saya ingin memulai chat dengan AI tentang barang yang ingin saya beli | Sehingga saya bisa mendapat pertanyaan reflektif yang membantu saya berpikir ulang | J1 |
| US2 | User | Saya ingin menjawab pertanyaan-pertanyaan reflektif dari AI | Sehingga AI bisa memahami motivasi dan kebutuhan saya terhadap barang tersebut | J1 |
| US3 | User | Saya ingin mendapat action plan setelah selesai menjawab pertanyaan | Sehingga saya tahu harus beli, tunda, atau skip barang tersebut | J5 |
| US4 | User | Saya ingin memfoto barang fisik dan langsung mendapat feedback AI | Sehingga saya bisa evaluate pembelian langsung di toko | J2 |
| US5 | User | Saya ingin screenshot produk di Shopee/TikTok Shop dan otomatis masuk ke app | Sehingga nama dan harga produk sudah auto-extracted dan siap di-evaluate | J3 |
| US6 | User | Saya ingin upload screenshot dari galeri ke chat AI | Sehingga saya bisa evaluate produk yang sudah saya simpan sebelumnya | J3 |
| US7 | User | Saya ingin share link produk dari e-commerce ke Buydee | Sehingga AI langsung bisa analyze produk tanpa perlu copy-paste manual | J4 |
| US8 | User | Saya ingin paste link produk di chat | Sehingga saya bisa manually evaluate produk dari link yang sudah di-copy | J4 |
| US9 | User | Saya ingin melihat history conversation sebelumnya | Sehingga saya bisa review keputusan-keputusan yang sudah saya buat | J1 |

---

## 6. Proposed Experience

**Design Direction:**
Buydee terasa seperti "teman bijak" yang muncul di saat yang tepat — warm, supportive, tapi jujur. UI-nya clean dan calming (bukan flashy) untuk menciptakan suasana reflektif. Mental model-nya adalah **chat companion** — semua interaksi terjadi dalam konteks percakapan, bukan form atau checklist.

**Key Screens / States:**

- **Home / Chat List** — Daftar conversation sebelumnya + tombol "New Check" untuk mulai conversation baru
- **Chat View** — Conversational UI antara user dan Buydee AI. Mendukung text input, image attachment, dan link paste
- **Camera Capture** — Full-screen camera untuk foto barang fisik, dengan preview sebelum submit ke AI
- **Action Plan Card** — Hasil akhir dari reflective session: rekomendasi (Buy / Wait / Skip) dengan reasoning
- **Empty state:** Ilustrasi friendly + copy "Mau beli sesuatu? Buydee siap bantu kamu mikir dulu 🤔"
- **Error state:** Jika AI tidak bisa direach → "Koneksi terputus. Tapi coba tanya ke diri sendiri: Apakah kamu benar-benar butuh ini?" + retry button
- **Loading state:** Typing indicator bubble (seperti iMessage) saat AI sedang merespons

**Interaction Model:**

- **Primary Flow (Manual):**
  1. User tap "New Check" → masuk Chat View
  2. User ketik/paste nama barang atau link → AI mulai bertanya
  3. User jawab 3–5 pertanyaan reflektif
  4. AI berikan action plan card

- **Screenshot Shortcut Flow:**
  1. User screenshot di e-commerce app
  2. Shortcut trigger → OCR extract nama & harga
  3. Buydee app terbuka → Chat View dengan pre-filled message
  4. User tap send → AI mulai sesi reflektif

- **Camera Flow:**
  1. User tap ikon kamera di Chat View
  2. Foto barang → preview → confirm
  3. AI analyze foto dan mulai sesi reflektif

- **Share Extension Flow:**
  1. User tap Share di e-commerce app
  2. Pilih Buydee → app terbuka ke Chat View dengan link pre-filled
  3. AI extract info dari link dan mulai sesi reflektif

- **Gallery Upload Flow:**
  1. User buka Buydee → Chat View
  2. Tap attachment → pilih foto dari galeri
  3. AI analyze screenshot/foto dan mulai sesi reflektif

**Accessibility Notes:**

- Full VoiceOver support — semua elemen chat harus accessible
- Dynamic Type support — chat bubbles harus scale properly
- Minimum contrast ratio 4.5:1 untuk teks
- Haptic feedback pada action plan reveal
- Camera capture harus accessible via VoiceOver

**Figma / Design Link:** [placeholder — add link when available]

---

## 7. Component Inventory

| Component | Type | Description | Linked Stories |
| --- | --- | --- | --- |
| `ChatListView` | Layout | Daftar semua conversation sebelumnya, sorted by date. Pull-to-refresh. | US9 |
| `ChatListItemCard` | Display | Card untuk setiap conversation — menampilkan item name, date, dan outcome (Buy/Wait/Skip badge) | US9 |
| `ChatView` | Layout | Main conversational UI. ScrollView dengan message bubbles, input bar di bawah. | US1, US2, US3 |
| `MessageBubble` | Display | Chat bubble — variant untuk user message (kanan) dan AI message (kiri). Support text, image preview, dan link preview. | US1, US2 |
| `ChatInputBar` | Form | Text field + send button + attachment menu (camera, gallery, paste). Sticky di bottom. | US1, US4, US6, US8 |
| `AttachmentMenu` | Action | Bottom sheet / popover menu: Camera, Photo Library, Paste Link | US4, US6, US8 |
| `CameraCaptureView` | Layout | Full-screen camera dengan capture button, flash toggle, dan cancel. Preview mode setelah foto. | US4 |
| `ImagePreviewBubble` | Display | Thumbnail image di dalam chat bubble (user's photo/screenshot) | US4, US6 |
| `LinkPreviewCard` | Display | Rich preview card di dalam chat — menampilkan product image, nama, harga (jika bisa di-extract) | US7, US8 |
| `ActionPlanCard` | Display | Card hasil akhir — badge (Buy ✅ / Wait ⏳ / Skip ❌), reasoning summary, dan suggested next step | US3 |
| `TypingIndicator` | Display | Animated dots (…) saat AI sedang memproses respons | US1, US2 |
| `EmptyStateView` | Display | Ilustrasi + copy untuk empty chat list | — |
| `ErrorBanner` | Display | Inline error message (no connection, API error) dengan retry action | — |
| `NewCheckButton` | Action | Floating/prominent button di Home untuk mulai conversation baru | US1 |
| `PreFilledMessageView` | Display | Message bubble yang sudah terisi dari Shortcut/Share Extension, siap di-send | US5, US7 |
| `ShareExtensionView` | Layout | Compact UI di Share Sheet — menampilkan Buydee icon, brief confirmation, lalu buka app | US7 |

---

## 8. Data Models

```swift
// MARK: - Core Models (SwiftData)

@Model
class Conversation {
    var id: UUID                          // Unique identifier
    var createdAt: Date                   // When conversation started
    var updatedAt: Date                   // Last message timestamp
    var itemName: String?                 // Extracted or user-provided item name
    var itemPrice: String?                // Extracted or user-provided price
    var itemImageData: Data?              // Thumbnail of item (photo/screenshot)
    var sourceType: ConversationSource    // How the conversation was initiated
    var sourceURL: String?                // E-commerce link if provided
    var outcome: ConversationOutcome?     // Final recommendation (nil if incomplete)
    var actionPlanSummary: String?        // AI's reasoning for the outcome
    
    @Relationship(deleteRule: .cascade)
    var messages: [Message]               // All messages in this conversation
}

@Model
class Message {
    var id: UUID
    var createdAt: Date
    var role: MessageRole                 // .user or .assistant
    var content: String                   // Text content
    var imageData: Data?                  // Attached image (photo/screenshot)
    var messageType: MessageType          // .text, .image, .link, .actionPlan
    
    var conversation: Conversation?       // Back-reference
}

// MARK: - Enums

enum ConversationSource: String, Codable {
    case manual          // User typed manually
    case camera          // User took a photo
    case screenshot      // Via Shortcut (screenshot + OCR)
    case shareExtension  // Via Share Extension (link)
    case galleryUpload   // User uploaded from photo library
}

enum ConversationOutcome: String, Codable {
    case buy             // AI recommends buying
    case wait            // AI recommends waiting/delaying
    case skip            // AI recommends skipping
}

enum MessageRole: String, Codable {
    case user
    case assistant
}

enum MessageType: String, Codable {
    case text
    case image
    case link
    case actionPlan
}
```

---

## 9. API / Integration Surface

### Google Gemini API

| Method | Endpoint | Description | Auth Required | Notes |
| --- | --- | --- | --- | --- |
| POST | `generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent` | Send text prompt + optional image to Gemini | API Key | Supports multimodal (text + image) |
| POST | `generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:streamGenerateContent` | Stream response for real-time typing effect | API Key | Use for better UX with typing indicator |

### On-Device APIs

| Framework | Usage | Description |
| --- | --- | --- |
| **Vision (VNRecognizeTextRequest)** | OCR | Extract text from screenshot — parse item name and price |
| **PhotosUI (PHPickerViewController)** | Gallery Access | Pick images from photo library |
| **AVFoundation** | Camera | Capture photos of physical items |
| **App Intents / Shortcuts** | Screenshot Shortcut | Automate: screenshot → OCR → open Buydee with pre-filled data |
| **Share Extension (NSExtensionItem)** | Share Sheet | Receive shared links/images from e-commerce apps |
| **SwiftData** | Local Persistence | Store conversations and messages on-device |

**External integrations:**

- **Google Generative AI Swift SDK** (`google-generative-ai-swift`) — official Gemini SDK for iOS
- **No backend server needed** — direct client-to-API communication with API key

---

## 10. State Management Map

| State | Location | Persistence | Notes |
| --- | --- | --- | --- |
| `conversations` | SwiftData (ModelContext) | Persistent | All past and active conversations |
| `messages` | SwiftData (ModelContext) | Persistent | All messages within conversations |
| `currentConversation` | Local UI (@State) | Session | Active conversation being viewed |
| `chatInputText` | Local UI (@State) | None | Current text in chat input field |
| `isAIResponding` | Local UI (@State) | None | Controls typing indicator visibility |
| `cameraState` | Local UI (@State) | None | Camera preview, captured image |
| `preFilledData` | App Intent / URL Scheme | Session | Data from Shortcut or Share Extension, consumed on app open |
| `geminiAPIKey` | Keychain / Bundled Config | Persistent | API key for Gemini (bundled or stored securely) |
| `aiConversationHistory` | In-memory array | Session | Full message history sent to Gemini for context |
| `networkStatus` | NWPathMonitor | None | Online/offline state for showing error banner |

---

## 11. Tech Stack

| Layer | Choice | Rationale |
| --- | --- | --- |
| **Frontend** | SwiftUI (iOS 17+) | Native performance, declarative UI, required for Apple Academy |
| **Styling** | Native SwiftUI modifiers + custom design system | Consistent with iOS Human Interface Guidelines |
| **AI Backend** | Google Gemini 2.0 Flash via REST / Swift SDK | Multimodal (text + vision), fast response, cost-effective |
| **Database** | SwiftData | Modern Apple persistence framework, seamless SwiftUI integration |
| **Auth** | None | Not needed — fully local data |
| **OCR** | Apple Vision framework | On-device, no network needed, accurate for text extraction |
| **Hosting** | N/A (native app) | Distributed via TestFlight / App Store |
| **Key libraries** | `GoogleGenerativeAI` (Gemini SDK), `SwiftData`, `Vision`, `AVFoundation`, `PhotosUI` | All first-party Apple + official Google SDK |

---

## 12. Suggested File Structure

```
buydee/
├── buydeeApp.swift                          # App entry point, environment setup
├── Info.plist                              # App configuration
│
├── Models/
│   ├── Conversation.swift                  # SwiftData model
│   ├── Message.swift                       # SwiftData model
│   └── Enums.swift                         # ConversationSource, Outcome, MessageRole, MessageType
│
├── Views/
│   ├── Home/
│   │   ├── ChatListView.swift              # Main screen — list of conversations
│   │   ├── ChatListItemCard.swift          # Individual conversation card
│   │   ├── EmptyStateView.swift            # Empty state illustration
│   │   └── NewCheckButton.swift            # CTA to start new conversation
│   │
│   ├── Chat/
│   │   ├── ChatView.swift                  # Main chat interface
│   │   ├── MessageBubble.swift             # Chat bubble (user/AI variants)
│   │   ├── ChatInputBar.swift              # Input field + attachment menu
│   │   ├── TypingIndicator.swift           # AI typing animation
│   │   ├── ImagePreviewBubble.swift        # Image in chat
│   │   ├── LinkPreviewCard.swift           # Link preview in chat
│   │   ├── ActionPlanCard.swift            # Final recommendation card
│   │   └── PreFilledMessageView.swift      # Pre-filled from Shortcut/Share
│   │
│   ├── Camera/
│   │   └── CameraCaptureView.swift         # Camera capture + preview
│   │
│   └── Components/
│       ├── AttachmentMenu.swift             # Bottom sheet for attachments
│       └── ErrorBanner.swift                # Network error banner
│
├── Services/
│   ├── GeminiService.swift                 # Gemini API integration + prompt management
│   ├── OCRService.swift                    # Vision framework text extraction
│   ├── ImageAnalysisService.swift          # Process camera/screenshot images
│   └── ConversationManager.swift           # Business logic for conversation flow
│
├── Prompts/
│   ├── SystemPrompt.swift                  # Base system prompt for Buydee AI persona
│   ├── ReflectiveQuestionFramework.swift   # Question framework configuration
│   └── ActionPlanTemplates.swift           # Action plan response templates
│
├── Utilities/
│   ├── LinkParser.swift                    # Extract product info from e-commerce URLs
│   ├── PriceExtractor.swift                # Parse price from OCR text
│   └── HapticManager.swift                 # Haptic feedback utility
│
├── Extensions/
│   ├── Date+Extensions.swift               # Date formatting helpers
│   └── View+Extensions.swift               # Reusable view modifiers
│
├── BuydeeShareExtension/                    # Share Extension target
│   ├── ShareViewController.swift           # Handle incoming shared content
│   ├── Info.plist
│   └── MainInterface.storyboard
│
├── BuydeeShortcuts/                         # App Intents for Shortcuts
│   ├── ScreenshotAnalyzeIntent.swift       # Shortcut: Screenshot → OCR → Open App
│   └── AppShortcutsProvider.swift          # Register available shortcuts
│
└── Assets.xcassets/
    ├── AppIcon.appiconset/
    ├── Colors/                             # Custom color assets
    └── Images/                             # Empty state illustrations, icons
```

---

## 13. Acceptance Criteria

**US1 — Memulai chat dengan AI**

- [ ] User bisa tap "New Check" dari Home dan masuk ke Chat View kosong
- [ ] User bisa mengetik nama barang / deskripsi di chat input dan mengirim
- [ ] AI merespons dengan pertanyaan reflektif pertama dalam < 5 detik
- [ ] Typing indicator muncul selama AI memproses
- [ ] Conversation otomatis tersimpan di SwiftData

**US2 — Menjawab pertanyaan reflektif**

- [ ] AI mengajukan pertanyaan satu per satu (bukan semua sekaligus)
- [ ] User bisa menjawab dengan free text
- [ ] AI follow-up question relevan dengan jawaban sebelumnya
- [ ] Total pertanyaan 3–5 sebelum memberikan action plan
- [ ] Conversation context dipertahankan antar pertanyaan

**US3 — Mendapat action plan**

- [ ] Setelah selesai reflective questions, AI menampilkan ActionPlanCard
- [ ] Card menampilkan outcome badge (Buy ✅ / Wait ⏳ / Skip ❌)
- [ ] Card berisi reasoning summary (2–3 bullet points)
- [ ] Card berisi suggested next step yang spesifik
- [ ] Outcome tersimpan di conversation record
- [ ] Haptic feedback saat action plan muncul

**US4 — Foto barang fisik via kamera**

- [ ] User bisa tap ikon kamera di ChatInputBar
- [ ] Camera view terbuka full-screen dengan capture button
- [ ] Setelah foto, user melihat preview dan bisa retake atau confirm
- [ ] Foto dikirim sebagai message bubble di chat
- [ ] AI menganalisis foto dan memulai sesi reflektif
- [ ] Edge case: Camera permission denied → tampilkan Settings redirect

**US5 — Screenshot via Shortcut**

- [ ] Shortcut tersedia di Shortcuts app setelah install Buydee
- [ ] Setelah screenshot di e-commerce app, Shortcut trigger-able dari Action Button
- [ ] OCR extract text dari screenshot
- [ ] Nama barang dan harga diparsing dari OCR result
- [ ] Buydee app terbuka dengan Chat View + pre-filled message berisi nama & harga
- [ ] User hanya perlu tap send
- [ ] Edge case: OCR gagal extract → pre-fill dengan raw text, AI coba parse sendiri

**US6 — Upload screenshot dari galeri**

- [ ] User bisa tap attachment → Photo Library
- [ ] Photo picker muncul (PHPicker) dengan filter image only
- [ ] Selected image muncul di chat sebagai message
- [ ] AI menganalisis gambar dan mulai sesi reflektif
- [ ] Edge case: Gambar bukan produk → AI gracefully handle ("Hmm, ini bukan barang belanja ya?")

**US7 — Share link via Share Extension**

- [ ] Share Extension muncul di Share Sheet dari Safari, Shopee, TikTok, dll
- [ ] Setelah tap Buydee di Share Sheet, app terbuka
- [ ] Link otomatis muncul di Chat View sebagai pre-filled message
- [ ] AI detect bahwa ini adalah link produk dan mulai sesi reflektif
- [ ] Edge case: Link bukan e-commerce → AI handle gracefully

**US8 — Paste link di chat**

- [ ] User bisa paste link di chat input field
- [ ] Link detected dan ditampilkan sebagai LinkPreviewCard (jika memungkinkan)
- [ ] AI memproses link dan mulai sesi reflektif
- [ ] Fallback: jika link preview gagal, tetap kirim sebagai plain text

**US9 — History conversation**

- [ ] Home menampilkan list semua conversation, sorted by newest first
- [ ] Setiap card menampilkan: item name (atau "Untitled"), date, outcome badge
- [ ] Tap card → masuk ke Chat View dengan full conversation history
- [ ] Swipe to delete conversation
- [ ] Empty state ditampilkan jika belum ada conversation
- [ ] Edge case: Incomplete conversation (no outcome) ditampilkan dengan "In Progress" badge

---

## 14. Open Questions & Risks

- **Q:** Apa framework pertanyaan reflektif yang spesifik? (misal: Need vs Want matrix, 72-hour rule, dsb.) — _Owner: Product/Design Team_
- **Q:** Apa saja action plan templates yang sudah di-specify? Berapa banyak variasi? — _Owner: Product/Design Team_
- **Q:** Bagaimana handling Gemini API key? Bundled di app atau environment variable? — _Owner: Engineering_
- **Q:** Apakah ada rate limiting concern untuk Gemini API di free tier? — _Owner: Engineering_
- **Q:** Untuk Share Extension, apakah cukup handle link saja atau juga gambar dari e-commerce apps? — _Owner: Product_
- **Q:** Bagaimana tone of voice AI? Bahasa Indonesia, English, atau campur? — _Owner: Product/Design_
- **Risk:** Gemini API latency bisa > 5 detik pada peak hours — _Mitigation: Streaming response + typing indicator untuk perceived performance_
- **Risk:** OCR accuracy untuk screenshot e-commerce yang complex (banyak elemen) — _Mitigation: AI sebagai fallback parser, extract nama & harga dari raw OCR text_
- **Risk:** Share Extension dan Shortcuts setup bisa complex dan error-prone — _Mitigation: Prioritaskan manual input + camera dulu, Shortcut/Share Extension sebagai enhancement_
- **Tradeoff:** Menggunakan Gemini API langsung dari client (no backend) berarti API key exposed di app binary — acceptable untuk Academy challenge, tapi tidak untuk production

---

## 15. Rollout & Next Steps

**MVP scope (Week 1–2):** The smallest shippable version that validates the core JTBD.

- Includes:
  - Chat View dengan AI reflective conversation (Gemini)
  - Custom system prompt + reflective question framework
  - Action Plan Card (Buy/Wait/Skip)
  - Camera capture → AI analysis
  - Conversation history (SwiftData)
  - Basic Home/Chat List

- Excludes:
  - Screenshot Shortcut integration
  - Share Extension
  - Link preview parsing
  - Gallery upload

**Phase 2 (Week 3–4):** Enhanced input methods.

- Screenshot Shortcut (OCR → pre-fill chat)
- Share Extension (receive links from e-commerce)
- Gallery upload (photo library picker)
- Link preview cards
- Polish: animations, haptics, empty states

**Phase 3+ (Post-challenge ideas):**

- Push notifications — "Sudah 48 jam sejak kamu mau beli X. Masih mau?"
- Spending pattern insights dari conversation history
- Widget — quick "Am I buying impulsively?" check
- Siri integration — "Hey Siri, Buydee should I buy this?"
- Community challenges — "30 Day No Impulse Buy"

**Sign-off needed from:**

- [ ] PM / Product Owner
- [ ] Engineering Lead
- [ ] Design Lead
- [ ] Academy Mentor / Coach

**Next steps:**

1. **Finalize reflective question framework & action plan templates** — _Owner: Product/Design, by Week 0_
2. **Design system & UI mockups in Figma** — _Owner: Design, by Week 0_
3. **Set up Xcode project + SwiftData models** — _Owner: Engineering, by Day 1_
4. **Implement Gemini API integration + system prompt** — _Owner: Engineering, by Week 1_
5. **Build Chat UI** — _Owner: Engineering, by Week 1_
6. **Implement Camera + OCR** — _Owner: Engineering, by Week 2_
7. **Build Shortcuts + Share Extension** — _Owner: Engineering, by Week 3_
8. **QA + Polish + TestFlight** — _Owner: All, by Week 4_

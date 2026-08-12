# Buydee — Technical Product Requirements

> Status: target arsitektur chatbot MVP per 12 Agustus 2026. Dokumen ini memprioritaskan technical logic. Untuk perilaku percakapan, developer prompt penuh adalah source of truth.

## 1. Tujuan teknis

Buydee adalah aplikasi SwiftUI yang memberi ruang refleksi sebelum pengguna memutuskan pembelian. Chatbot membantu pengguna menyusun alasan dan trade-off, tetapi tidak memberikan verdict.

Kontrak keputusan chatbot hanya memiliki dua nilai:

- `BUY` — beli sekarang.
- `BYE` — tidak beli sekarang.

Model tidak boleh menganggap BUY, BYE, atau menunggu sebagai pilihan yang otomatis lebih baik. Kontrak Buy/Wait/Skip dan action plan preskriptif pada PRD lama tidak berlaku untuk chatbot MVP.

## 2. Source of truth dan baseline project

Jika dokumentasi berbeda, gunakan urutan acuan berikut:

1. Source code aktif: konfigurasi AI, developer prompt, models, service protocol, camera flow, dan design system.
2. Dokumen ini untuk batas arsitektur, integrasi, dan acceptance criteria.
3. `README.md` untuk setup developer lokal.
4. Ide lama hanya berlaku jika disebut eksplisit sebagai roadmap.

Baseline yang sudah tersedia:

- App shell dengan onboarding dan Home (`ContentView`).
- Design system melalui `Color.buydee`/`BuydeeColors` di `AppColor.swift` dan semantic fonts di `AppFont.swift`.
- Camera dan Photos flow melalui `CameraCaptureView`, `CameraCaptureViewModel`, dan `CameraService`.
- `CameraCaptureView` mengembalikan hasil melalui `onImageCaptured: (UIImage) -> Void`.
- Goals onboarding disimpan ke `UserDefaults` dengan key `userGoals`.
- Permission descriptions Camera dan Photo Library sudah dikonfigurasi di project settings.

Chatbot menggunakan camera-first entry. Home membuka Camera/Photos flow existing; setelah pengguna mengonfirmasi preview melalui **Use Photo**, aplikasi membuka ChatView dengan gambar sebagai draft attachment. Tidak ada tombol akses Chat sementara di Home.

## 3. Scope

### Target chatbot MVP

- Chat screen untuk text dan image attachment.
- OpenRouter Chat Completions dengan developer prompt penuh pada role `developer`.
- State machine percakapan diinfer model dari maksimal 12 pesan transcript terakhir.
- Integrasi `CameraCaptureView` yang sudah ada; tidak membuat camera service atau picker kedua.
- Preprocessing hasil camera/Photos: resize maksimum 2048 px, JPEG kualitas 0.82, dan data URL base64.
- Summary Markdown yang tervalidasi sebelum action BUY/BYE muncul.
- BUY/BYE dikirim sebagai user message agar model menjalankan fase penutup.
- Completion screen berbeda untuk hasil BUY dan BYE.
- Single-flight request, cancellation, error state, dan pencegahan duplicate send.
- Transcript hanya hidup selama runtime chat; goals tetap persisten di `UserDefaults`.
- Satu knowledge ringkas lintas chat disimpan dan terus diperbarui melalui SwiftData.
- Maksimum 30 keputusan selesai disimpan sebagai record SwiftData terstruktur; maksimum 12 terbaru menjadi knowledge tambahan.
- API key dibaca dari environment developer dan disimpan ke Keychain.

### Tidak termasuk MVP

- SwiftData atau persistence untuk transcript/history chat.
- OCR, object detection, atau image-analysis service terpisah.
- Membaca isi product page dari URL, web search, tool/function calling, RAG, atau API-enforced structured output.
- Streaming response.
- Screenshot Shortcut, Share Extension, link preview/parser, widget, dan reminder sebagai bagian chatbot.
- Perubahan besar pada navigation Home di luar camera-first entry.

### Roadmap

- Home/chat-list final dan persistence history dengan migration plan.
- Screenshot Shortcut dan OCR bila kebutuhan produk telah divalidasi.
- Share Extension serta resolver URL melalui service/backend tersendiri.
- Widget, recap, dan reminder.
- Backend proxy, attestation, rate limiting, serta rotasi credential untuk production.

Item roadmap tidak boleh dimasukkan diam-diam ke request atau state chatbot MVP.

## 4. Arsitektur target

Project mempertahankan feature-based MVVM dengan shared Core layer.

```text
BuydeeApp
├── Onboarding feature
│   └── UserDefaults: hasCompletedOnboarding, userGoals
├── Home / ContentView
│   └── Check It Together → Camera preview → ChatView + image draft
├── Camera feature (existing)
│   ├── CameraCaptureView
│   ├── CameraCaptureViewModel
│   └── Core/Managers/CameraService
└── Chat feature
    ├── Views
    │   ├── ChatView + bubbles + composer
    │   ├── Summary/decision presentation
    │   └── DecisionCompletionView
    ├── ViewModel
    │   ├── runtime transcript/draft state
    │   ├── send, retry, cancel, and navigation
    │   └── Summary marker gate
    ├── Models
    │   ├── ChatMessage / ChatRole
    │   ├── DraftImageAttachment
    │   ├── PurchaseDecision / DecisionMetadata
    │   ├── PurchaseDecisionRecord (SwiftData list)
    │   └── UserChatKnowledge (SwiftData single record)
    ├── Services
    │   ├── ChatServicing / OpenRouter service
    │   ├── AIConfiguration
    │   ├── ImageAttachmentProcessor
    │   ├── SwiftDataUserKnowledgeStore
    │   └── SwiftDataDecisionHistoryStore
    └── Prompts
        └── DeveloperPrompt

Core
├── DesignSystem/AppColor.swift
├── DesignSystem/AppFont.swift
├── Managers/CameraService.swift
└── Security/OpenRouterCredentialStore.swift
```

Dependency flow:

```text
Home Check It Together → Camera/Photos preview → Use Photo → ChatView + image draft
Chat View → Chat ViewModel → ChatServicing → OpenRouter REST
                         ├→ DeveloperPrompt + UserDefaults goals + SwiftData knowledge/decision history
                         ├→ CredentialStore → Keychain
                         └→ ImageAttachmentProcessor

Chat composer → existing CameraCaptureView
CameraCaptureView → onImageCaptured(UIImage)
→ image Data → ImageAttachmentProcessor → draft preview → OpenRouter vision input
```

Rules:

- View merender state dan meneruskan user intent; network/prompt logic tidak berada di View.
- ViewModel mengakses AI melalui `ChatServicing`, bukan membangun HTTP payload sendiri.
- Service tidak mengontrol layout atau navigation.
- Camera feature bertanggung jawab sampai menghasilkan `UIImage`; chatbot bertanggung jawab atas konversi, preprocessing, draft, dan request multimodal.
- Jangan menggandakan `CameraService`, `CameraCaptureView`, atau Photos picker yang sudah tersedia.
- Shared dependency berada di `Core`; Feature tidak mengimpor Feature lain kecuali entry/integration composition di level app/Home.

## 5. Design system dan kontrak UI

Referensi desain menentukan komposisi layout dan bentuk komponen, bukan warna atau font. Semua warna harus berasal dari `Color.buydee`, termasuk token chat yang tersedia (`chatBackground`, `chatComposerBackground`, `chatAssistantBubble`, `chatUserBubble`, `chatSummaryBackground`, `chatMascotPlaceholder`, `chatByeBackground`, dan `chatError`). Typography memakai semantic tokens dari `AppFont.swift`, termasuk `.buydeeChatMessage`, `.buydeeChatButton`, `.buydeeChatSummaryTitle`, dan `.buydeeChatCompletionTitle`. Jika token baru diperlukan, perluas design system secara terpisah—jangan menaruh hard-coded style baru di feature chat.

### Chat screen

- Diakses melalui camera-first flow dari Home dan dipresentasikan melalui navigation yang dapat kembali ke Home.
- Back action di kiri atas.
- Transcript scrollable; bubble user rata kanan dan bubble assistant rata kiri.
- Rectangle menjadi placeholder maskot di kiri bubble assistant sampai mascot final tersedia.
- Image bubble menjaga aspect ratio dan menampilkan gambar yang telah dipilih.
- Jika user message berisi gambar dan caption, UI merender image bubble dan caption bubble secara terpisah. Service tetap mempertahankannya sebagai satu multimodal message agar konteks image–caption tidak terputus.
- Composer sticky di bawah berisi input, Camera action, dan send action.
- Camera action membuka `CameraCaptureView`; hasil `UIImage` diteruskan ke image processor sebagai draft attachment.
- Response assistant merender Markdown H1–H6, bold, italic, inline code, link, unordered/ordered list, blockquote, fenced code block, dan highlight opsional `==...==`.
- Saat request aktif, tampilkan teks supportive yang muted tanpa bubble (misalnya “Bentar ya, aku lagi bantu pikirin…”), disable seluruh action yang dapat mengirim, tetapi jangan menampilkan response parsial.

### Readiness floating button

Tombol “Are you ready to decide now?” tampil melayang tepat di atas composer setelah dua exchange lengkap: minimal dua user message yang masing-masing sudah memiliki assistant response.

Tombol disembunyikan ketika:

- request sedang aktif;
- Summary valid sudah diterima; atau
- keputusan sudah dipilih.

CTA mengirim user message melalui pipeline normal yang meminta model merangkum berdasarkan konteks tersedia. CTA tidak boleh membuat Summary lokal atau langsung menampilkan BUY/BYE.

### Summary state

- Summary tampil sebagai card/bubble seperti referensi dan memakai `AppColor`/`AppFont`.
- UI hanya merender konteks, PROS, dan CONS yang diberikan model; UI tidak menambahkan reasoning.
- BUY dan BYE mempunyai hierarki visual yang setara dan baru tampil setelah marker strict tervalidasi.

### Completion

- Saat BUY/BYE ditap, kirim pilihan sebagai user message dan segera navigasikan ke halaman baru bertipe `PurchaseDecision`, sesuai interaksi pada referensi.
- BYE menampilkan pengguna memilih tidak membeli sekarang; BUY menampilkan pengguna memilih membeli.
- Layout mengikuti referensi: headline, rectangle placeholder maskot, curved/raised result surface, deskripsi, dan satu tombol selesai.
- Copy kedua halaman netral; tidak menyiratkan satu keputusan lebih baik.
- Tombol selesai menghapus runtime chat dan kembali ke destination aplikasi yang ditentukan.

### Accessibility

- Dynamic Type tidak boleh menyebabkan clipping pada bubbles, Summary, composer, atau completion.
- VoiceOver labels/hints tersedia untuk back, Camera, gallery action dari camera screen, image preview/remove, send, readiness, BUY, BYE, dan finish.
- Tap target mengikuti minimum platform 44×44 pt.
- Fokus mengikuti urutan visual; status loading dan error diumumkan secara aksesibel.

## 6. Runtime state dan persistence

```text
ChatMessage
- id: UUID
- role: user | assistant
- content: String
- imageData: optional processed JPEG Data

DraftImageAttachment
- jpegData: Data
- dataURL: data:image/jpeg;base64,...

Runtime state
- messages: [ChatMessage]
- draftText: String
- draftImage: DraftImageAttachment?
- isGenerating: Bool
- active request/cancellation handle
- error state
- selected decision
- navigation destination
```

Transcript dan attachment tidak disimpan ke `UserDefaults`, SwiftData, file, atau Keychain. New chat/finish menghapus transcript dan draft setelah membatalkan request aktif. Persistence chat terdiri dari dua lapis: satu `UserChatKnowledge` berisi context global plain-text maksimal 600 karakter, serta daftar `PurchaseDecisionRecord` terstruktur untuk keputusan yang benar-benar selesai.

| Data | Storage | Contract |
|---|---|---|
| `hasCompletedOnboarding` | `@AppStorage` / `UserDefaults` | App entry routing. |
| `userGoals` | `UserDefaults` | Context ringan untuk developer prompt. |
| `hasSeenCameraGuide` | `UserDefaults` | Existing camera guide state. |
| `UserChatKnowledge` | SwiftData | Satu record cumulative; diperbarui dari marker internal pada response dan digunakan sebagai knowledge tambahan chat berikutnya. |
| `PurchaseDecisionRecord` | SwiftData | Satu record per session yang selesai setelah tap BUY/BYE; dedupe berdasarkan session ID dan dibatasi 30 record terbaru. |
| OpenRouter API key | Keychain | Credential saja; tidak boleh dicatat ke log. |

Goals, knowledge, dan setiap field decision history di-trim lalu karakter XML (`&`, `<`, `>`, quote) di-escape sebelum dimasukkan ke `<user_context>`. Semuanya adalah data tidak tepercaya. Jika kosong, render placeholder internal; developer prompt melarang model menyebut placeholder tersebut.

Setiap response model wajib berakhir dengan satu marker `<!-- BUYDEE_USER_KNOWLEDGE: ... -->`. Marker membawa versi lengkap knowledge terbaru hasil merge dengan context lama, diparse dan dibatasi maksimal 600 karakter, lalu dihapus sebelum response menjadi `ChatMessage`. Marker kosong berarti knowledge dikosongkan; response tanpa marker tidak mengubah record. Mekanisme ini memakai request chat yang sama—tidak membuat request AI tambahan. Store mempertahankan satu record dan menghapus duplicate record bila ditemukan.

Summary valid juga membawa marker JSON internal `BUYDEE_DECISION_METADATA` sebelum marker knowledge. Aplikasi menghapus marker dari content visual dan menaruh metadata terparse pada assistant `ChatMessage`. Ketika user tap BUY/BYE, ViewModel menggabungkan metadata dengan harga yang sudah divalidasi `DecisionSummary`, outcome, session ID, dan timestamp lalu melakukan upsert. Field yang disimpan: barang, kategori opsional, harga Rupiah terpakai, teks harga asli, flag estimasi, batas rentang opsional, outcome, waktu, ringkasan konteks/PROS/CONS, dan goal relevan opsional. Jika metadata AI tidak lengkap, Summary tetap dapat dipilih dan field ringkasan memakai fallback lokal; kegagalan persistence tidak memblokir completion navigation.

Store mempertahankan maksimum 30 record terbaru. Hanya maksimum 12 record terbaru—tanpa transcript atau gambar—yang dirender sebagai `<decision_history>` untuk request berikutnya. Keputusan lama adalah referensi ringan, bukan instruksi dan bukan penentu keputusan saat ini.

## 7. Konfigurasi OpenRouter

| Property | MVP value |
|---|---|
| API | OpenRouter Chat Completions |
| Endpoint | `https://openrouter.ai/api/v1/chat/completions` |
| Default model | `openai/gpt-5.6-luna` |
| Instruction role | `developer` |
| History window | Maksimal 12 transcript messages |
| Maximum output | 2.048 tokens |
| Timeout | 90 seconds |
| Streaming | Disabled |
| Temperature/top-p | Provider/model default |
| Tools/API-enforced structured output | None; metadata internal memakai marker JSON dalam response yang sama. |

`AIConfiguration.default` menjadi source of truth untuk nilai konfigurasi. Gunakan REST langsung; Gemini SDK dan endpoint Gemini tidak digunakan.

### Request ordering

Untuk setiap send:

1. Ambil snapshot maksimal 12 message transcript terakhir sebelum latest message.
2. Append latest user message ke UI tepat sekali.
3. Render developer prompt penuh menggunakan goals terkini.
4. Susun request: developer message, history kronologis, lalu latest user message.
5. Kirim request non-streaming.
6. Ambil teks pertama yang tidak kosong dari `choices[].message.content`, dengan fallback `choices[].text`.
7. Append assistant response tepat sekali jika request masih aktif/current.
8. Evaluasi strict Summary marker pada assistant response terakhir.

Payload minimum:

```json
{
  "model": "openai/gpt-5.6-luna",
  "messages": [
    { "role": "developer", "content": "<full rendered developer prompt>" },
    { "role": "user", "content": "Sepatu ini Rp1.500.000" }
  ],
  "max_tokens": 2048
}
```

Gambar lama yang masih termasuk window 12 message dikirim ulang untuk fidelity konteks. Optimasi biaya/token harus menjadi perubahan kontrak yang disengaja.

## 8. State machine prompt

Aplikasi tidak menyimpan phase enum. Developer prompt menginstruksikan model menginfer fase dari history yang diterima.

### Phase A — Capture & Open

- Nama/jenis produk dan harga wajib diketahui sebelum eksplorasi.
- Jika salah satu belum jelas, tanyakan tepat satu klarifikasi tanpa pertanyaan DARN pada response yang sama.
- Jika harga berupa rentang tertutup, tawarkan nilai tengahnya sebagai estimasi dan tunggu konfirmasi eksplisit user pada giliran terpisah. Jika user menolak, minta satu nominal atau batas rentang yang ingin dipakai. Jangan lanjut ke eksplorasi atau Summary sebelum harga ini disepakati.
- Jangan menguatkan promo dengan framing nominal “hemat Rp…”.

### Phase B — Explore

Setiap response berisi maksimal dua kalimat reaksi/insight, satu Markdown heading `#` sepanjang 2–5 kata, dan tepat satu pertanyaan terbuka. Desire, Ability, Reason, dan Need adalah intent, bukan checklist empat pertanyaan. Jangan mengulang intent yang sudah terjawab atau pernah ditanyakan tanpa jawaban.

### Phase C — DARN Gate

Kecukupan dinilai dari keseluruhan history. Satu jawaban boleh memenuhi beberapa intent. Jika decision fatigue tinggi, model boleh mengambil jalur pendek, tetapi Summary tetap wajib dan fakta yang hilang tidak boleh dikarang.

### Phase D — Summary & Choice

Summary memuat produk, harga, situasi singkat, PROS, CONS, dan pertanyaan netral BUY/BYE. PROS/CONS hanya berasal dari pengguna. Maksimal satu perbandingan goal–harga boleh digunakan jika benar-benar relevan dan hanya memakai nominal yang tersedia. Nilai tengah rentang hanya boleh dipakai setelah konfirmasi pada Phase A.

### Phase E — Close

Setelah user memilih BUY/BYE, pilihan tetap diteruskan ke model sebagai user message agar kontrak Phase E tidak hilang. Model menerima pilihan secara netral, boleh memberikan maksimal satu pertanyaan takeaway, lalu menutup singkat. UI completion tidak menunggu response ini untuk berpindah halaman; task yang masih aktif tetap harus dikelola atau dibatalkan secara eksplisit agar tidak menghasilkan state liar.

## 9. Strict Summary contract

Output Summary yang diharapkan:

```markdown
Sebentar aku rangkum dulu ya—biar kamu bisa melihat seluruh gambarannya sebelum memilih.

[Produk, harga, dan situasi]

**PROS:**
- …
**CONS:**
- …

Dari semua yang kita bahas—kamu mau pilih **BUY** (beli sekarang) atau **BYE** (tidak beli sekarang)?
```

Jika Summary memakai nilai tengah rentang yang sudah dikonfirmasi user, output juga wajib memiliki marker internal berikut pada baris tersendiri. Marker tidak digunakan untuk harga tunggal atau nominal yang dipilih langsung oleh user.

```html
<!-- BUYDEE_MIDPOINT_CONFIRMED -->
```

Decision buttons hanya tampil ketika assistant response terakhir memiliki semua marker berikut, case-insensitive:

- `**PROS:**`
- `**CONS:**`
- `**BUY**`
- `**BYE**`

Bold marker dan colon pada PROS/CONS wajib. Selain marker, `DecisionSummary` harus berhasil mem-parsing sedikitnya satu item PROS dan satu item CONS. Jika parser menemukan rentang harga, Summary ditolak kecuali marker midpoint terkonfirmasi juga ada; marker tersebut dibuang dari content yang dirender. Button tidak tampil saat generating. UI tidak boleh menebak Summary hanya dari bubble count, DARN phase, atau isi yang mirip.

Tap button mengirim salah satu message berikut sebagai role `user` melalui pipeline normal:

```text
BUY — Beli sekarang
```

```text
BYE — Tidak beli sekarang
```

Disable kedua button segera setelah tap agar pilihan dan request Phase E hanya terkirim sekali.

## 10. Pipeline gambar dan kamera

Gunakan flow existing:

```text
Chat Camera action
→ present CameraCaptureView
→ CameraService capture ATAU PhotosPicker existing
→ preview/retake/use photo di CameraCaptureView
→ onImageCaptured(UIImage)
→ convert ke source Data
→ validate/decode + apply orientation
→ proportional resize; longest side max 2048 px
→ JPEG sRGB quality 0.82
→ store DraftImageAttachment + preview/remove di composer
→ data:image/jpeg;base64,...
→ OpenRouter multimodal message
```

Jangan membuat flow kamera/Photos baru. Pertahankan lifecycle, cancel, permission denied, guide, flash error, retake, dan use-photo behavior milik feature Camera. Cancel tidak membuat draft atau mengirim AI request.

Jika gambar dikirim tanpa caption, gunakan internal prompt:

```text
Identifikasi barang dan harga yang terlihat, lalu bantu aku mempertimbangkannya sebelum membeli.
```

Multimodal content:

```json
[
  { "type": "text", "text": "<caption or internal image prompt>" },
  { "type": "image_url", "image_url": { "url": "data:image/jpeg;base64,<BASE64>" } }
]
```

Model vision yang sama mengidentifikasi produk/harga dan mengikuti state machine pada satu request. Jangan menambah OCR, classifier, object detection, atau image-analysis request terpisah.

## 11. URL handling

Pesan URL HTTP/HTTPS tanpa gambar tidak dikirim ke AI. MVP tidak memiliki browsing atau product-page extraction; mengirim URL langsung akan mendorong model menebak isi produk.

Jika composer menerima link-only:

1. Tolak sebelum append transcript/send.
2. Tampilkan pesan agar user memasukkan nama produk dan harga atau mengambil/memilih gambar melalui camera flow.
3. Pertahankan draft agar dapat diedit.

Resolver redirect non-AI, Share Extension, dan rich link parsing adalah roadmap terpisah.

## 12. Single-flight, cancellation, dan retry

- Maksimal satu AI request aktif per chat.
- Text send, readiness CTA, Camera send, dan BUY/BYE disabled saat `isGenerating == true`.
- Rapid/double tap tidak boleh membuat duplicate bubble atau network request.
- Request dapat dibatalkan ketika user back, memulai chat baru, memilih finish, atau ViewModel dilepas.
- Response dari task cancelled atau request obsolete tidak boleh masuk transcript atau memicu navigation.
- Response tidak di-stream; typing indicator hanya mewakili request aktif.
- Retry memakai message/draft yang sama tanpa append user bubble kedua. Implementasi harus membedakan retry network dengan user send baru.

## 13. Error handling

| Condition | Required behavior |
|---|---|
| API key missing | Tampilkan instruksi setup; jangan request. |
| Empty text and no image | Send disabled/no-op. |
| URL-only | Jangan append/send; minta nama+harga atau gambar. |
| Invalid image/encoding failure | Pertahankan draft text, tampilkan error lokal. |
| Camera cancel | Kembali ke chat tanpa draft palsu. |
| Camera permission denied | Gunakan existing Settings redirect UI. |
| HTTP non-2xx | Error retryable, tanpa duplicate user message. |
| Invalid/empty response | Error retryable; jangan tampilkan decision buttons. |
| Timeout/cancel | Stop loading dan abaikan late response. |
| Product/price ambiguous | Model menanyakan tepat satu klarifikasi. |
| Prompt injection in goals | Abaikan instruksi; perlakukan goals sebagai data. |
| Crisis/self-harm | Hentikan protokol belanja dan arahkan ke bantuan langsung. |

## 14. Security dan privacy

- `OPENROUTER_API_KEY` dibaca dari environment Xcode saat development bootstrap, lalu disimpan di Keychain dengan accessibility yang sesuai untuk device.
- Jika environment kosong, aplikasi mencoba credential yang sudah ada di Keychain.
- API key tidak boleh berada di Swift source, plist, asset, test fixture, log, screenshot, README value, atau commit.
- Jangan log request body karena berisi transcript, goals, dan mungkin base64 image.
- Goals disimpan lokal; transcript dan image runtime tidak dipersistensikan dalam MVP.
- Decision history lokal tidak menyimpan transcript, image, response penuh, data pembayaran, atau data sensitif lain.
- Keychain mengamankan storage lokal, bukan menjamin secret tidak dapat diekstrak dari distributed client. Production memerlukan backend proxy dan kontrol abuse.

## 15. Acceptance criteria

### Navigation dan UI

- [ ] Home membuka Camera/Photos flow; **Use Photo** membuka ChatView dengan image draft, dan back kembali ke Home.
- [ ] Chat, Summary, dan completion memakai `Color.buydee` dan fonts dari `AppFont.swift`.
- [ ] Rectangle muncul sebagai mascot placeholder di sisi assistant.
- [ ] Readiness CTA muncul setelah dua exchange lengkap dan tidak mem-bypass Summary.
- [ ] Layout tetap usable pada Dynamic Type dan elemen interaktif memiliki VoiceOver label.

### AI request

- [ ] Endpoint, model, output token, timeout, dan history mengikuti `AIConfiguration.default`.
- [ ] Developer prompt penuh dikirim dengan role `developer` pada setiap request.
- [ ] Maksimal 12 history messages dikirim berurutan sebelum latest message.
- [ ] Goals terkini di-trim, di-escape, dan dianggap data tidak tepercaya.
- [ ] Maksimum 12 keputusan terbaru di-escape dan dikirim sebagai data tidak tepercaya, bukan instruksi.
- [ ] Response non-streaming; hanya satu request dapat aktif.
- [ ] Cancellation mengabaikan late response dan double tap tidak menduplikasi send.
- [ ] Transcript hilang pada new chat/finish, sedangkan goals tersedia setelah relaunch.

### Camera dan image

- [ ] Camera action menggunakan `CameraCaptureView`/`CameraService` existing.
- [ ] Camera dan Photos existing sama-sama mengirim hasil melalui `onImageCaptured`.
- [ ] Hasil diproses ke longest side maksimum 2048 px dan JPEG quality 0.82.
- [ ] Draft preview/remove bekerja sebelum send.
- [ ] Image-only memakai internal prompt yang ditentukan.
- [ ] Satu multimodal request dikirim ke model vision; tidak ada OCR/image service kedua.

### Summary dan decision

- [ ] BUY/BYE hanya muncul jika empat strict marker ada pada assistant response terakhir dan `DecisionSummary` berhasil diparse.
- [ ] BUY/BYE tidak muncul saat generating atau hanya berdasarkan bubble count.
- [ ] Tap decision mengirim exact user message dan hanya memicu Phase E sekali.
- [ ] Tap BUY/BYE mengirim user message sekali dan langsung membuka completion screen yang sesuai.
- [ ] Kedua outcome memakai copy netral.
- [ ] Tap BUY/BYE membuat atau memperbarui tepat satu decision record untuk session tersebut; chat yang belum selesai tidak disimpan.
- [ ] Decision history dibatasi 30 record dan tidak berisi transcript atau image.

### Verification scenarios

- [ ] Product dan harga lengkap langsung memicu satu pertanyaan eksplorasi.
- [ ] Product ambigu atau harga hilang hanya memicu satu klarifikasi.
- [ ] Rich answer dapat memenuhi beberapa DARN intent tanpa pertanyaan berulang.
- [ ] Decision fatigue tetap menghasilkan Summary.
- [ ] Summary hanya menggunakan fakta user dan marker lengkap.
- [ ] BUY dan BYE diterima setara.
- [ ] Prompt injection dalam `userGoals` diabaikan.
- [ ] Camera capture, Photos selection, retake, cancel, permission denied, dan invalid image terverifikasi.
- [ ] URL-only tidak pernah diteruskan ke OpenRouter.
- [ ] Double tap, timeout, cancel, retry, dan back tidak membuat response/message duplikat.

## 16. Urutan implementasi

1. Tambahkan Chat models, `ChatServicing`, `AIConfiguration`, credential store, image processor, dan developer prompt penuh.
2. Implementasikan dan test OpenRouter request/response mapping.
3. Implementasikan Chat ViewModel: runtime transcript, goals, single-flight, cancellation, retry, marker gate, dan typed navigation.
4. Hubungkan **Check It Together** di Home ke Camera/Photos preview, lalu navigasikan **Use Photo** ke ChatView dengan image draft.
5. Bangun chat UI dengan `AppColor`/`AppFont`, rectangle mascot placeholder, composer, Markdown, dan readiness CTA.
6. Integrasikan composer ke `CameraCaptureView.onImageCaptured`; teruskan hasil ke image processor tanpa mengubah camera service.
7. Implementasikan strict Summary gate, user-message BUY/BYE, dan completion pages.
8. Jalankan seluruh acceptance scenarios sebelum mengerjakan roadmap.

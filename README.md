# Buydee

Buydee adalah aplikasi SwiftUI untuk membantu pengguna berhenti sejenak sebelum memutuskan pembelian. Chatbot bersifat reflektif dan netral: keputusan akhir tetap `BUY` atau `BYE` dari pengguna.

## Status project

Baseline yang sudah tersedia:

- onboarding dan goals lokal;
- Home screen dengan savings summary, goal editor, mascot, dan CTA `Check It Together`;
- design system `AppColor.swift` dan `AppFont.swift`;
- camera/Photos flow melalui `CameraCaptureView`, `CameraCaptureViewModel`, dan `CameraService`.

Target chatbot MVP:

- camera-first entry dari Home menuju ChatView dengan image draft;
- reflective chat teks dan gambar melalui OpenRouter;
- integrasi camera/Photos existing ke draft chatbot;
- Summary dengan strict BUY/BYE marker;
- completion screen BUY dan BYE;
- runtime-only transcript, cancellation, dan duplicate-send protection.
- cumulative user knowledge yang ringkas melalui satu record SwiftData;
- daftar maksimum 30 keputusan selesai (barang, harga, BUY/BYE, dan ringkasan trade-off) di SwiftData.

SwiftData transcript/chat history, OCR, Screenshot Shortcut, Share Extension, product-link analysis, widgets, dan reminders bukan scope chatbot MVP. URL-only tidak dikirim ke model. SwiftData menyimpan context global ringkas dan record keputusan selesai, bukan pesan, gambar, atau transcript lengkap.

## Arsitektur dan teknologi

- SwiftUI, feature-based MVVM, dan shared `Core` layer.
- UI memakai `Color.buydee` serta semantic fonts dari `AppFont.swift`.
- OpenRouter Chat Completions via REST.
- Endpoint: `https://openrouter.ai/api/v1/chat/completions`.
- Default model: `openai/gpt-5.6-luna`.
- Developer prompt dikirim dengan role `developer`.
- Maksimal 12 transcript messages sebagai history.
- Non-streaming response, maksimum 2.048 output token, timeout 90 detik.
- `UserDefaults` untuk onboarding, goals, dan camera guide state.
- SwiftData untuk satu cumulative user-knowledge record maksimal 600 karakter dan maksimum 30 record keputusan selesai.
- Keychain untuk OpenRouter credential.
- AVFoundation/PhotosUI dari Camera feature existing.
- Image pipeline chatbot: longest side 2048 px, JPEG quality 0.82, lalu data URL base64.

Lihat [PRD_BUYDEE.md](PRD_BUYDEE.md) untuk kontrak request, prompt state machine, image integration, UI, security, dan acceptance criteria.

## Developer setup

### 1. Prerequisites

- macOS dan Xcode yang mendukung deployment target pada `buydee.xcodeproj`.
- iPhone device untuk pengujian kamera; Simulator dapat dipakai untuk UI dan Photos flow.
- OpenRouter account dan API key development.

### 2. Clone dan buka project

```bash
git clone https://github.com/zildjianvitoo/buydee.git
cd buydee
open buydee.xcodeproj
```

Tunggu Xcode selesai mengindeks project, lalu pilih scheme `buydee`.

### 3. Tambahkan OpenRouter API key ke Run scheme

1. Buka **Product → Scheme → Edit Scheme…**.
2. Pilih **Run** pada sidebar.
3. Buka tab **Arguments**.
4. Pada **Environment Variables**, tekan `+`.
5. Isi Name dengan `OPENROUTER_API_KEY`.
6. Isi Value dengan API key development lokal.
7. Centang variable agar aktif, lalu tutup scheme editor.

Gunakan placeholder saat menulis dokumentasi atau membagikan screenshot:

```text
OPENROUTER_API_KEY=<your-local-openrouter-key>
```

Pada run pertama, aplikasi membaca environment key dan menyimpannya ke Keychain. Run berikutnya dapat memakai key di Keychain jika environment variable tidak tersedia.

### 4. Pilih runtime

- Gunakan physical iPhone untuk capture camera lengkap, flash, dan permission testing.
- Gunakan Simulator untuk chat UI, network flow, dan memilih fixture/image dari Photos bila tersedia.
- Pastikan network aktif karena AI tidak memiliki offline fallback.

### 5. Build dan run

1. Pilih device/simulator target.
2. Jalankan **Product → Build** atau `Cmd + B`.
3. Jalankan aplikasi dengan `Cmd + R`.
4. Selesaikan onboarding agar `userGoals` tersimpan.
5. Dari Home, tap **Check It Together**, ambil atau pilih foto, lalu tap **Use Photo** untuk membuka ChatView dengan image draft terlampir.

### 6. Verifikasi credential dan request

- Jika key tidak tersedia, aplikasi harus menampilkan error konfigurasi dan tidak mengirim request.
- Pastikan request menuju endpoint OpenRouter, bukan endpoint Gemini.
- Jangan mencetak API key, authorization header, request body, goals, transcript, atau base64 image ke console.
- Saat mengganti key, aktifkan environment variable baru pada Run scheme agar Keychain diperbarui saat bootstrap.

### 7. Verifikasi camera integration

1. Dari Home, tap **Check It Together**.
2. Capture foto atau pilih foto melalui Photos action pada camera screen existing.
3. Pada preview, verifikasi **Retake/Take Photo**, **Select Another**, dan **Use Photo**.
4. Tap **Use Photo** dan pastikan ChatView terbuka dengan image draft terlampir, bukan langsung mengirim request.
5. Verifikasi remove, cancel, permission denied, image-only send, serta caption send.
6. Setelah send, pastikan image dan caption dirender sebagai dua bubble terpisah walaupun tetap dikirim sebagai satu multimodal message ke AI.

## Security rules

- Jangan menaruh key di Swift source, `Info.plist`, `.xcconfig` yang di-commit, asset, fixture, README value, atau log.
- Jangan commit user scheme/Xcode user data yang mengandung secret.
- Jangan log transcript, image data, `UserChatKnowledge`, atau `PurchaseDecisionRecord`.
- Gunakan API key development pribadi dan rotasi key jika pernah terekspos.
- Keychain melindungi local storage, tetapi bukan pengganti backend protection untuk aplikasi production.
- Production harus menggunakan backend proxy/rate limiting sebelum distribusi luas.

## Chatbot contract ringkas

- Developer prompt penuh menentukan fase; aplikasi tidak menyimpan enum fase.
- Nama produk dan harga harus diketahui sebelum eksplorasi DARN.
- Harga berbentuk rentang harus dikonfirmasi dulu: AI menawarkan nilai tengah, menunggu persetujuan user, dan Summary berbasis midpoint wajib membawa marker `<!-- BUYDEE_MIDPOINT_CONFIRMED -->`.
- Summary wajib mengandung `**PROS:**`, `**CONS:**`, `**BUY**`, dan `**BYE**` sebelum tombol decision tampil.
- Tap decision mengirim `BUY — Beli sekarang` atau `BYE — Tidak beli sekarang` sebagai user message.
- Satu request AI saja boleh aktif; back/new chat membatalkan request dan late response diabaikan.
- Transcript hanya runtime; `userGoals` persisten di `UserDefaults`, context penting lintas chat disimpan sebagai satu record SwiftData, dan keputusan selesai disimpan sebagai daftar terpisah.
- Marker knowledge dan decision metadata internal dihapus sebelum bubble dirender dan tidak membutuhkan request AI kedua.
- Decision record hanya dibuat setelah Summary valid dan user tap BUY/BYE; maksimum 12 record terbaru menjadi knowledge tambahan pada chat berikutnya.
- Image menggunakan model vision yang sama setelah resize 2048/JPEG 0.82; tidak ada OCR atau image-analysis service kedua.
- URL HTTP/HTTPS tanpa gambar ditolak sebelum send.

## Dokumentasi

- [Technical PRD](PRD_BUYDEE.md)
- [Contributing guide](CONTRIBUTING.md)

## Team

Built for Apple Developer Academy Challenge 4.

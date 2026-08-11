# Contributing Guide — Buydee

> Panduan development workflow untuk tim Buydee. Pastikan semua anggota tim mengikuti konvensi ini agar codebase tetap rapi dan mudah di-maintain.

---

## Branching Strategy

Kita menggunakan **Git Flow (simplified)** dengan 3 level branch:

```
main          ← production-ready, hanya dari merge dev
  └── dev     ← integration branch, semua feature di-merge ke sini
       ├── feat/chat-ui
       ├── feat/gemini-service
       ├── fix/camera-crash
       └── ...
```

### Branch Types

| Branch | Format | Dari | Merge ke | Keterangan |
|--------|--------|------|----------|------------|
| `main` | `main` | — | — | Production-ready. **Jangan langsung push ke sini.** |
| `dev` | `dev` | `main` | `main` | Integration branch. Semua feature di-merge ke sini dulu. |
| Feature | `feat/<nama-fitur>` | `dev` | `dev` | Fitur baru |
| Bug fix | `fix/<deskripsi-bug>` | `dev` | `dev` | Perbaikan bug |
| Hotfix | `hotfix/<deskripsi>` | `main` | `main` + `dev` | Fix urgent di production |
| Chore | `chore/<deskripsi>` | `dev` | `dev` | Config, refactor, docs, dll |

### Aturan Branch

- **Selalu buat branch baru dari `dev`** (kecuali hotfix)
- **1 branch = 1 fitur/task**. Jangan campur multiple features di 1 branch
- Nama branch pakai **lowercase + kebab-case**: `feat/chat-input-bar`, bukan `feat/ChatInputBar`
- Hapus branch setelah di-merge

### Contoh Workflow

```bash
# 1. Pastikan dev up-to-date
git checkout dev
git pull origin dev

# 2. Buat feature branch
git checkout -b feat/chat-ui

# 3. Kerjakan fitur, commit secara berkala
git add .
git commit -m "feat(chat): add ChatView with message bubbles"

# 4. Push ke remote
git push origin feat/chat-ui

# 5. Buat Pull Request ke `dev` di GitHub
# 6. Minta review dari minimal 1 orang
# 7. Setelah approved, merge ke `dev`
# 8. Hapus branch
git branch -d feat/chat-ui
```

---

## Conventional Commits

Semua commit message **wajib** mengikuti format [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Type

| Type | Kapan dipakai | Contoh |
|------|--------------|--------|
| `feat` | Menambah fitur baru | `feat(chat): add typing indicator animation` |
| `fix` | Memperbaiki bug | `fix(camera): resolve crash on permission denied` |
| `refactor` | Refactor kode tanpa ubah behavior | `refactor(gemini): extract prompt builder to separate service` |
| `style` | Perubahan formatting/styling (bukan CSS) | `style(home): fix indentation in HomeViewModel` |
| `docs` | Dokumentasi | `docs: update CONTRIBUTING.md with commit rules` |
| `test` | Menambah/mengubah test | `test(chat): add unit test for ChatViewModel` |
| `chore` | Maintenance, config, dependencies | `chore: add GoogleGenerativeAI package dependency` |
| `build` | Build system, CI/CD | `build: update Xcode project settings for iOS 17` |
| `perf` | Performance improvement | `perf(chat): lazy load message images` |
| `ui` | Perubahan UI/visual | `ui(home): update empty state illustration` |

### Scope (Opsional tapi Direkomendasikan)

Scope menunjukkan area kode yang berubah. Gunakan nama **feature folder**:

| Scope | Area |
|-------|------|
| `chat` | Features/Chat/ |
| `home` | Features/Home/ |
| `camera` | Features/Camera/ |
| `onboarding` | Features/Onboarding/ |
| `settings` | Features/Settings/ |
| `gemini` | Core/Managers/GeminiService |
| `ocr` | Core/Managers/OCRService |
| `entities` | Core/Entities/ |
| `widget` | HoldyWidget/ |
| `share-ext` | HoldyShareExtension/ |
| `shortcuts` | HoldyShortcuts/ |
| `notif` | Notifications/ |

### Rules

1. **Lowercase** — semua type dan description huruf kecil
2. **Imperative mood** — tulis seperti perintah: "add feature", bukan "added feature" atau "adding feature"
3. **No period** — jangan akhiri description dengan titik
4. **Max 72 karakter** — untuk subject line
5. **Body opsional** — gunakan untuk penjelasan "kenapa", bukan "apa"

### Contoh Commit Messages

```bash
# ✅ Benar
feat(chat): add action plan card component
fix(camera): handle nil image data on capture
refactor(gemini): split system prompt into separate file
chore: configure swiftdata model container in app entry
docs: add branching strategy to contributing guide
ui(home): implement empty state view with illustration

# ❌ Salah
Fixed the bug                          # tidak ada type
feat: Add Chat View.                   # huruf besar + titik
feat(chat): add chat view and also update home view and fix camera bug  # terlalu banyak, pecah jadi multiple commits
update stuff                           # tidak deskriptif
```

### Breaking Changes

Jika commit mengandung breaking change, tambahkan `!` setelah type/scope:

```bash
feat(entities)!: restructure Conversation model schema

BREAKING CHANGE: Conversation model sekarang menggunakan relationship
baru untuk Messages. Data lama tidak compatible, perlu delete app.
```

---

## Pull Request (PR) Guidelines

### PR Title

Ikuti format yang sama dengan conventional commit:

```
feat(chat): implement AI reflective conversation flow
```

### PR Description Template

```markdown
## What
[Deskripsi singkat perubahan]

## Why
[Kenapa perubahan ini diperlukan]

## How
[Pendekatan teknis yang diambil]

## Screenshots (jika ada UI changes)
[Attach screenshot/screen recording]

## Checklist
- [ ] Code sudah di-test di device/simulator
- [ ] Tidak ada warning baru di Xcode
- [ ] Commit messages mengikuti conventional commits
- [ ] Branch sudah up-to-date dengan `dev`
```

### Review Rules

- Minimal **1 approval** sebelum merge ke `dev`
- Merge ke `main` butuh **approval dari lead**
- Gunakan **Squash and Merge** untuk keep history clean

---

## Code Style

### Swift Conventions

- Ikuti [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Gunakan **4 spaces** untuk indentation (default Xcode)
- **MARK comments** untuk organize file sections:

```swift
// MARK: - Properties
// MARK: - Body
// MARK: - Private Methods
// MARK: - Supporting Views
```

### File Naming

- Views: `ChatView.swift`, `MessageBubble.swift`
- ViewModels: `ChatViewModel.swift`
- Models: `ChatMessage.swift`
- Services: `GeminiService.swift`
- Extensions: `Date+Extensions.swift`

### Architecture Rules

- **Views** hanya handle UI rendering — logic di ViewModel
- **ViewModels** handle business logic — akses data via Services/Managers
- **Core/** untuk shared code — jangan import antar Features
- **Features** boleh import dari Core, **tidak boleh** import dari Feature lain

---

## Quick Reference

```bash
# Start fitur baru
git checkout dev && git pull origin dev
git checkout -b feat/nama-fitur

# Commit
git add .
git commit -m "feat(scope): deskripsi singkat"

# Push & PR
git push origin feat/nama-fitur
# → Buat PR ke `dev` di GitHub

# Sync dengan dev terbaru
git checkout dev && git pull origin dev
git checkout feat/nama-fitur
git merge dev
```

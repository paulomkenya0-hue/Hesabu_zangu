# 🚀 HESABU ZANGU — LAUNCH CHECKLIST

## ━━━ KABLA YA BUILD ━━━

### ✅ Code
- [ ] flutter analyze — errors zote zimeisha
- [ ] flutter test — tests zinapita
- [ ] AdMob IDs za kweli zimewekwa (si test IDs)
- [ ] M-Pesa number sahihi imewekwa kwenye premium_service.dart
- [ ] Premium unlock codes zimebadilishwa na za kweli
- [ ] WhatsApp number ya kweli imewekwa

### ✅ Assets
- [ ] App icon (1024x1024 PNG) imetengenezwa
- [ ] Splash screen imewekwa
- [ ] Screenshots za Play Store (min 2, recommended 8)
  - [ ] Home screen / Dashboard
  - [ ] Add transaction screen
  - [ ] History screen
  - [ ] Report screen na charts
  - [ ] PDF download
  - [ ] Settings na premium

---

## ━━━ APP ICON — JINSI YA KUTENGENEZA ━━━

Tumia flutter_launcher_icons package:

```yaml
# Ongeza kwenye pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/icon.png"  # 1024x1024 PNG yako
  adaptive_icon_background: "#1B5E20"
  adaptive_icon_foreground: "assets/images/icon_foreground.png"
```

```bash
dart run flutter_launcher_icons
```

---

## ━━━ BUILD COMMANDS ━━━

```bash
# 1. Clean kwanza
flutter clean
flutter pub get

# 2. Build APK ya debug (kwa testing)
flutter build apk --debug

# 3. Build APK ya release
flutter build apk --release

# 4. Build App Bundle (kwa Play Store — BORA ZAIDI)
flutter build appbundle --release

# 5. APK iko wapi?
# Debug:   build/app/outputs/flutter-apk/app-debug.apk
# Release: build/app/outputs/flutter-apk/app-release.apk
# Bundle:  build/app/outputs/bundle/release/app-release.aab
```

---

## ━━━ GITHUB SETUP ━━━

```bash
# 1. Unda repo GitHub (hesabu_zangu)
# 2. Kwenye terminal:
git init
git add .
git commit -m "🚀 Initial commit - Hesabu Zangu v1.0.0"
git branch -M main
git remote add origin https://github.com/USERNAME/hesabu_zangu.git
git push -u origin main
```

### .gitignore (MUHIMU — usiupload keystore!)
```
# Ongeza kwenye .gitignore
*.keystore
*.jks
/build
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
android/app/google-services.json
```

---

## ━━━ CODEMAGIC SETUP ━━━

1. Nenda https://codemagic.io
2. Sign in na GitHub account yako
3. "Add application" → chagua repo yako
4. Chagua "Flutter App" workflow
5. Codemagic itaona codemagic.yaml yako automatically
6. Bonyeza "Start build"
7. Baada ya dakika 15-20 → APK na AAB ziko tayari

### Environment Variables za Codemagic (kwa signing):
```
CM_KEYSTORE_PATH     → /path/to/keystore.jks
CM_KEYSTORE_PASSWORD → password yako
CM_KEY_ALIAS         → alias yako
CM_KEY_PASSWORD      → key password
```

---

## ━━━ KEYSTORE — JINSI YA KUUNDA ━━━

```bash
keytool -genkey -v \
  -keystore hesabu_zangu.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias hesabu_zangu

# Itauliza: jina, shirika, nchi, password
# Weka: TZ kwa nchi
# HIFADHI KEYSTORE HII SALAMA — USIPOTEZE KAMWE!
```

---

## ━━━ PLAY STORE SETUP ━━━

### Step 1: Google Play Console
1. Nenda https://play.google.com/console
2. Lipa $25 registration fee (mara moja tu)
3. "Create app" → Hesabu Zangu
4. Chagua: Free, Tanzania + nchi zote

### Step 2: Store Listing
- [ ] Title: "Hesabu Zangu - Simamia Pesa Zako"
- [ ] Short description (kutoka PLAY_STORE_LISTING.md)
- [ ] Full description (kutoka PLAY_STORE_LISTING.md)
- [ ] Screenshots (min 2)
- [ ] Feature graphic (1024x500 PNG)
- [ ] App icon (512x512 PNG)

### Step 3: App Content
- [ ] Privacy Policy URL: https://USERNAME.github.io/hesabu_zangu/privacy
- [ ] Content rating questionnaire (Finance app = Everyone)
- [ ] Target audience: Everyone
- [ ] Data safety form (haikusanyi data = rahisi)

### Step 4: Upload AAB
- Production → Create new release
- Upload app-release.aab
- Release notes (kwa Kiswahili!):
  ```
  v1.0.0 — Toleo la Kwanza! 🎉
  • Rekodi mapato na matumizi kwa urahisi
  • Ripoti za PDF na Excel
  • Dashboard nzuri na charts
  • Vikumbusho vya kila siku
  • 100% offline — bila internet
  ```

### Step 5: Review na Launch
- [ ] Internal testing → testers wachache
- [ ] Closed testing → beta wachache
- [ ] Production → Submit for review
- ⏳ Google inachukua siku 1-7 ku-review

---

## ━━━ GITHUB PAGES (Privacy Policy) ━━━

```bash
# 1. Unda folder docs/ kwenye repo
mkdir docs
cp privacy_policy.html docs/index.html

# 2. Push GitHub
git add docs/
git commit -m "Add privacy policy"
git push

# 3. GitHub Settings → Pages → Source: main/docs
# 4. URL itakuwa: https://USERNAME.github.io/hesabu_zangu/
# 5. Tumia URL hii kwa Play Store Privacy Policy
```

---

## ━━━ POST-LAUNCH: WIKI 1 ━━━

### Masoko (Marketing) — Sh. 0 Budget:
- [ ] Post WhatsApp groups za Iringa/Tanzania
- [ ] Facebook groups za biashara Tanzania
- [ ] Twitter/X post na screenshots
- [ ] Tuma kwa marafiki 20 wa karibu
- [ ] Groups za wafanyabiashara wa bodaboda

### Fuatilia:
- [ ] Play Store reviews — jibu zote!
- [ ] Crash reports kwenye Play Console
- [ ] AdMob dashboard — mapato ya kwanza!

---

## ━━━ BAADA YA USERS 1,000 ━━━

Priority za version 1.1:
- [ ] Widget ya home screen (balance ya haraka)
- [ ] Backup ya Google Drive
- [ ] Dark mode
- [ ] Budget planner (weka limit kwa kila aina)
- [ ] Multiple accounts (mimi + mke/mume)
- [ ] Export CSV
- [ ] Swahili language pack kamili

---

## 🎯 MALENGO YA KWANZA

```
Wiki 1:    Users 50  (marafiki na familia)
Wiki 2-4:  Users 200 (word of mouth)
Mwezi 2:   Users 500
Mwezi 3:   Users 1,000 ← TARGET
Mwezi 6:   Users 5,000
Mwaka 1:   Users 20,000
```

```
Mapato ya AdMob (wastani):
1,000 DAU × 3 ads × $0.30 CPM = ~$0.90/siku = ~$27/mwezi

Mapato ya Premium (5% conversion):
50 users × Sh. 2,500 = Sh. 125,000/mwezi

JUMLA MWEZI WA 3: ~Sh. 195,000+ 🎉
```

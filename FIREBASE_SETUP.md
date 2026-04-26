# Hướng dẫn Setup Firebase cho Contacts App

## Bước 1: Tạo Project trên Firebase Console

1. Truy cập https://console.firebase.google.com/
2. Nhấn **"Add project"** → Đặt tên: `ContactsApp`
3. Tắt Google Analytics (tùy chọn) → **Create project**

---

## Bước 2: Tạo Android App

1. Trong Firebase Console → nhấn icon **Android**
2. Điền **Android package name** - lấy từ file:
   ```
   android/app/build.gradle.kts
   ```
   Tìm dòng: `applicationId = "com.example.contacts_app"`

3. Đặt App nickname: `Contacts App`

---

## Bước 3: Lấy SHA-1 và SHA-256 (bắt buộc cho Google Sign-In)

Mở terminal, chạy lệnh:

```bash
cd android
./gradlew signingReport
```

Trên Windows:
```bash
cd android
gradlew.bat signingReport
```

Tìm phần **`Variant: debugAndroidTest`** và copy:
- `SHA1: XX:XX:XX:...`
- `SHA-256: XX:XX:XX:...`

Thêm cả 2 vào **SHA certificate fingerprints** trong Firebase Console.

---

## Bước 4: Download google-services.json

1. Nhấn **"Download google-services.json"**
2. Đặt file vào: `android/app/google-services.json`

---

## Bước 5: Cấu hình Android build files

### android/build.gradle.kts (project level)
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

### android/app/build.gradle.kts (app level)
```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

---

## Bước 6: Bật Authentication Providers

1. Firebase Console → **Authentication** → **Sign-in method**
2. Bật **Email/Password** → Save
3. Bật **Google** → Chọn Project support email → Save

---

## Bước 7: Tạo Firestore Database

1. Firebase Console → **Firestore Database** → **Create database**
2. Chọn **Start in test mode** (cho development)
3. Chọn region gần nhất (ví dụ: `asia-southeast1`)

### Firestore Security Rules (production):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/contacts/{contactId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Bước 8: Chạy ứng dụng

```bash
flutter pub get
flutter run
```

---

## Cấu trúc Firestore

```
users/
  {uid}/
    contacts/
      {contactId}/
        - name: string
        - phone: string
        - createdAt: timestamp
        - updatedAt: timestamp (optional)
```

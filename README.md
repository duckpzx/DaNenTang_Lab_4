# Lab 4 - Authenticate with Firebase (Contacts App)

## Cấu trúc project

```
lib/
├── main.dart                        # Khởi tạo Firebase, định nghĩa app
├── controllers/
│   ├── auth_services.dart           # Xử lý Authentication (Email, Google, Logout)
│   └── crud_services.dart           # CRUD contacts với Cloud Firestore
└── views/
    ├── login_page.dart              # Màn hình đăng nhập
    ├── sign_up_page.dart            # Màn hình đăng ký
    ├── home.dart                    # Danh sách contacts (StreamBuilder)
    ├── add_contact_page.dart        # Thêm contact mới
    └── update_contact.dart          # Chỉnh sửa contact
```

## Tính năng

- Đăng nhập bằng Email/Password
- Đăng nhập bằng Google
- Đăng ký tài khoản mới
- Đăng xuất
- Thêm / Xem / Sửa / Xóa contacts (Firestore real-time)

## Firebase Setup

1. Tạo project tại [console.firebase.google.com](https://console.firebase.google.com)
2. Thêm Android app → download `google-services.json` → đặt vào `/android/app/`
3. Lấy SHA-1 & SHA-256: `cd android && ./gradlew signingReport`
4. Bật **Email/Password** và **Google** tại Authentication → Sign-in method
5. Tạo **Firestore Database** (test mode)
6. Chạy `flutterfire configure` để tạo `lib/firebase_options.dart`

Chi tiết xem [FIREBASE_SETUP.md](FIREBASE_SETUP.md)

## Packages sử dụng

| Package | Mục đích |
|---|---|
| `firebase_core` | Khởi tạo Firebase |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Lưu trữ contacts |
| `google_sign_in` | Google Sign-In (mobile) |

## Cài đặt & chạy

```bash
flutter pub get
flutter run
```

Chạy trên Web:

```bash
flutter run -d chrome --web-port 7357
```

## Cấu trúc Firestore

```
users/
  {uid}/
    contacts/
      {contactId}/
        - name: string
        - phone: string
        - createdAt: timestamp
```

## 🎬 Video

Video demo chức năng

https://github.com/user-attachments/assets/29da28cd-6f56-408a-8f58-6c3bc6c2d265

Video Firebase dữ liệu

https://github.com/user-attachments/assets/f2a94e87-cbf2-4d29-960e-8ad649f7b811

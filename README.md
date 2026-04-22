# 🛍️ VISTORA – Fashion E-Commerce App

**VISTORA** is a modern **Flutter-based fashion e-commerce mobile application** inspired by platforms like **Zara** and **Nike**.
It delivers a smooth, elegant, and responsive shopping experience for **Men, Women, and Kids**.

The app is built with a **Feature-Based Architecture** and uses **Cubit (BLoC)** for scalable and maintainable state management.

---

## ✨ Features

* 👕 Browse fashion categories (Men, Women, Kids)
* 🛍️ Smooth shopping experience
* 🔍 Smart product search
* ❤️ Wishlist / Favorites system
* 🧾 Product details page
* 🛒 Cart management with real-time updates
* 👤 User profile management
* 🔐 Authentication (Login & Register)
* 💳 Checkout system (Payment ready)
* 📱 Clean & responsive UI

---

## 🚀 Advanced Features

* 🔥 Firebase Authentication (Login / Register / Logout)
* ☁️ Cloud Firestore Database Integration
* 🧠 State Management using Cubit (BLoC)
* 🧱 Feature-Based Clean Architecture
* 🔄 Real-time Cart Updates
* 💳 Payment Integration with Paymob
* 📦 Scalable & Maintainable Code Structure
* 📱 Fully Responsive UI (ScreenUtil)

---

## 📸 App Screenshots

### 🚀 Splash

<p align="center">
  <img src="assets/screenshots/splash_view.jpg" width="40%" />
</p>

---

### 🚀 Onboarding

<p align="center">
  <img src="assets/screenshots/onboarding_view1.jpg" width="30%" />
  <img src="assets/screenshots/onboarding_view2.jpg" width="30%" />
  <img src="assets/screenshots/onboarding_view3.jpg" width="30%" />
</p>

---

### 🔐 Authentication

<p align="center">
  <img src="assets/screenshots/sigin_view.jpg" width="45%" />
  <img src="assets/screenshots/create_view.jpg" width="45%" />
</p>

---

### 🏠 Home & Products

<p align="center">
  <img src="assets/screenshots/home_view.jpg" width="30%" />
  <img src="assets/screenshots/home_view1.jpg" width="30%" />
  <img src="assets/screenshots/products_view1.jpg" width="30%" />
</p>

<p align="center">
  <img src="assets/screenshots/products_view2.jpg" width="30%" />
  <img src="assets/screenshots/products_view3.jpg" width="30%" />
</p>

---

### 🔍 Search

<p align="center">
  <img src="assets/screenshots/search_view.jpg" width="40%" />
</p>

---

### ❤️ Favorites

<p align="center">
  <img src="assets/screenshots/fav_view.jpg" width="40%" />
</p>

---

### 🛒 Cart & Checkout

<p align="center">
  <img src="assets/screenshots/cart_view.jpg" width="30%" />
  <img src="assets/screenshots/checkout_view.jpg" width="30%" />
  <img src="assets/screenshots/visa.jpg" width="30%" />
</p>

---

### 👤 Profile

<p align="center">
  <img src="assets/screenshots/profile_view.jpg" width="40%" />
</p>

---

## 🛠️ Tech Stack

* 🟦 Flutter
* 🎯 Dart
* 🔥 Firebase (Authentication & Firestore)
* 🧠 Cubit (BLoC State Management)
* 📐 ScreenUtil (Responsive UI)
* 💳 Paymob (Payment Integration)

---

## 🧱 Architecture

The project follows a **Feature-Based Clean Architecture (Lightweight)**:

* `core/` → Shared services (API, Firebase, constants)
* `features/` → Each feature is modular and independent

  * `cubit/` → State management
  * `data/` → Models & repositories
  * `view/` → UI screens
  * `widgets/` → Reusable components

---

## 📂 Project Structure

```bash
lib/
│
├── core/
│   ├── apiservice.dart
│   ├── firebase_service.dart
│   ├── checkout.dart
│   ├── constant.dart
│
├── features/
│   ├── auth/
│   ├── cart/
│   ├── favorite/
│   ├── home/
│   ├── onboarding/
│   ├── productsdetails/
│   ├── profile/
│   ├── search/
│   ├── shared_widgets/
│
└── main.dart
```

---

## 🚀 Getting Started

```bash
git clone https://github.com/shawki-ashraf/VISTORA-APP.git
cd VISTORA-APP
flutter pub get
flutter run
```

---

## 💡 Future Improvements

* 📦 Order tracking system
* 🌍 Multi-language support
* 🔔 Push notifications
* ⭐ Product reviews & ratings

---

## 👨‍💻 Author

**Shawky Ashraf**
Flutter Developer 🚀

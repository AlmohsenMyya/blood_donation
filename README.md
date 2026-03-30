# 🩸 Sheryan | Advanced Blood Donation Management System

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-764ABC?logo=dart)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_UI_&_Reactive_State-green)]()

## 📌 Executive Overview
**Sheryan** is a high-performance, cross-platform mobile ecosystem engineered to bridge the critical gap between voluntary blood donors and recipients in real-time. Moving beyond simple directory apps, Sheryan implements a **Reactive Data Flow** and a **Role-Based Access Control (RBAC)** system to ensure that life-saving resources are matched with urgent needs efficiently and securely.

---

## 🏗 System Architecture & Engineering Highlights

This project was built with a focus on **Scalability**, **State Predictability**, and **Seamless User Experience**.

*   **Reactive State Management:** Leveraged `Flutter Riverpod` for a robust, compile-safe state management layer, ensuring high performance and decoupling of business logic from the UI.
*   **Backend-as-a-Service (BaaS):** Integrated a comprehensive Firebase suite (`Firestore`, `Auth`, `Messaging`, `Storage`) for real-time data synchronization and secure cloud infrastructure.
*   **Dual-Persona Interface:** A unified codebase serving two distinct user experiences (Donor vs. Recipient) via a sophisticated conditional routing logic.
*   **Real-time Request Lifecycle:** Implemented Firestore Streams to provide instant updates for blood requests without requiring manual refreshes.

---

## 🛠 Core Functional Modules

### 🔐 Identity & Access Management (IAM)
*   **Role-Based Onboarding:** Custom authentication flow allowing users to register as either "Donors" or "Recipients".
*   **Secure Persistence:** Session management via `Shared Preferences` and Firebase Auth state observers.
*   **Security Suite:** Built-in features for password entropy management, secure account deletion, and credential resets.

### 📍 Intelligent Matching & Filtering
*   **Geospatial Filtering:** Users can query donors and requests based on city-level granularity.
*   **Type-Specific Discovery:** Advanced filtering algorithms for sorting by blood groups (A+, B-, O+, etc.).
*   **Request Orchestration:** Recipients can broadcast urgent needs, which are instantly visible to qualified donors in the vicinity.

### 📱 Premium UX/UI Design
*   **Sophisticated Dark Mode:** A high-contrast, accessibility-focused dark theme tailored for medical/emergency environments.
*   **Atomic Design Principles:** Modular UI components built for reusability and consistent styling across the application.
*   **Interactive Notifications:** Integration with `Flutter Local Notifications` for real-time engagement.

---

## 🚀 Technical Stack

| Layer | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart SDK ^3.9.2) |
| **State Management** | Riverpod 3.0 (Declarative & Reactive) |
| **Database** | Cloud Firestore (NoSQL Real-time) |
| **Authentication** | Firebase Auth (OAuth & Email/Password) |
| **Storage** | Firebase Cloud Storage |
| **Utilities** | URL Launcher, Permission Handler, Intl |

---

## 📂 Project Structure (Modular Approach)

```
lib/
├── providers/     # Business logic & State providers (Riverpod)
├── services/      # API wrappers & Firebase service layers
├── screens/       # Presentation layer (Modularized by feature)
│   ├── auth/      # Login, Signup, Role Selection
│   ├── home/      # Main Dashboards
│   ├── donor/     # Exclusive Donor-side workflows
│   └── requests/  # Blood request CRUD operations
└── models/        # Data structures & JSON serialization
```

---

## 👨‍💻 Engineering Philosophy
As a software engineer, my goal with this project was to solve a real-world problem using a **Clean Code** approach. The application is designed with the **SOLID** principles in mind, ensuring that the backend services are easily swappable and the UI remains highly responsive even during complex data streams.

---

## 🛠 Installation & Development

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/AlmohsenMyya/sheryan.git
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Firebase:**
    *   Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
    *   Run `flutterfire configure`.
4.  **Run Application:**
    ```bash
    flutter run
    ```

---
Developed with ❤️ for the community.

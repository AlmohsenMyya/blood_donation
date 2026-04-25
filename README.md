# 🩸 Sheryan | Intelligent Blood Donation Ecosystem

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase)](https://firebase.google.com)
[![OneSignal](https://img.shields.io/badge/Notifications-OneSignal-E44D26?logo=onesignal)](https://onesignal.com)
[![Architecture](https://img.shields.io/badge/Architecture-Cloud_Distributed_System-blue)]()

## 📌 Executive Overview
**Sheryan** (شريان) is a sophisticated, cloud-based medical ecosystem designed to bridge the gap between voluntary blood donors and recipients. Unlike traditional directory apps, Sheryan functions as a **Managed Verification Platform** that integrates hospitals as trusted intermediaries. By combining **Reactive Programming**, **Bi-directional Authentication via QR**, and **Smart Medical Logic**, it ensures that every life-saving act is secure, verified, and timely.

---

## 🏛 Hybrid Architecture: Software & Networking
This project represents a fusion of **Software Engineering** and **Advanced Cloud Networking**, making it a robust case study for distributed systems.

*   **Software Layer:** Built with `Flutter` & `Riverpod 3.0` for a high-performance, reactive UI that adapts its behavior and branding based on the user's role.
*   **Networking Layer:** A distributed architecture leveraging `Firebase Firestore` for real-time data persistence and `OneSignal` for intelligent, tag-based push notification routing.
*   **Security & Protocols:** Implements `HTTPS/TLS` for data in transit and a proprietary **Double-Scan Verification Protocol** to prevent fraudulent donation logging.

---

## 🌟 Key Engineering Features

### 🧠 Smart Compatibility Engine (Medical Logic)
Integrated a specialized `BloodLogic` engine that moves beyond simple matching.
*   **Donation Map:** Automatically calculates compatible donors (e.g., AB+ recipients see all donors, while O- donors are notified of all matching requests).
*   **Dynamic Filtering:** Optimized Firestore queries using `whereIn` clauses to fetch medical matches in real-time.

### 🛡 Verified Lifecycle Management
A trust-based workflow managed by **Hospital Administrators**:
1.  **Unverified:** Initial request by a recipient.
2.  **Verified:** Authenticated by a hospital via QR scan (Visible to donors).
3.  **Completed:** Finalized via a **Double-Scan Flow** (Donor QR + Request QR) supervised by medical staff.

### 🔔 Intelligent Notification Hub (OneSignal)
A serverless notification system utilizing **Smart Tagging**:
*   **Contextual Alerts:** Push notifications are filtered by `city`, `blood_group`, and `user_role`.
*   **Automated Gratitude:** Instant "Thank You" and "Success" alerts triggered via REST API calls upon donation completion.

### 🎨 Centralized Design System (CDS)
A bespoke UI framework (`lib/core/theme/`) that provides:
*   **Role-Based Theming:** Adaptive color palettes (Golden for Donors, Medical Blue for Hospitals, Professional Grey for Super Admins).
*   **Full Localization:** Complete RTL/LTR support (Arabic & English) with adaptive layouts.

---

## 🛠 Multi-Role Ecosystem

| Role | Core Responsibilities |
| :--- | :--- |
| **Donor** | Manage digital donor card (QR), discover verified compatible requests, track donation history. |
| **Recipient** | Broadcast verified blood needs, track request status, automated WhatsApp outreach. |
| **Hospital Admin** | Verify local requests, supervise and log successful donations via QR scanning. |
| **Super Admin** | Manage system-wide infrastructure (Cities, Hospital registry, Admin account lifecycle). |

---

## 🚀 Technical Stack

| Category | Technology |
| :--- | :--- |
| **Frontend** | Flutter (Dart SDK ^3.9.2) |
| **State Management** | Riverpod 3.0 (Declarative & Reactive) |
| **Real-time Database** | Cloud Firestore (NoSQL Synchronization) |
| **Push Gateway** | OneSignal (REST API & Smart Tagging) |
| **Communication** | WhatsApp Integration, URL Launcher |
| **Hardware Int.** | Mobile Scanner (QR/Barcode), Geolocator |

---

## 📂 Project Structure (Clean Architecture)

```
lib/
├── core/
│   ├── theme/        # Centralized Design System (CDS)
│   ├── utils/        # BloodLogic, WhatsAppHelper, QR Logic
│   └── enums/        # UserRoles, RequestStatus
├── providers/        # State Management (Theme, Auth, Locale)
├── services/         # Firebase & OneSignal Service layers
├── screens/          # Presentation Layer (Modularized)
│   ├── hospital/     # Hospital Admin Dashboard & Scanners
│   ├── admin/        # Super Admin Infrastructure Mgmt
│   ├── donors/       # Matching & Discovery workflows
│   └── requests/     # Request Lifecycle UI
└── l10n/             # Multilingual ARB files (AR/EN)
```

---

## 🛡 Security & Reliability
*   **Network Security:** All communication is secured via standard Firebase protocols (HTTPS/TLS).
*   **Data Integrity:** Firestore Security Rules ensure that only authorized Hospital Admins can modify verification statuses.
*   **Fault Tolerance:** Implements local persistence to ensure the app remains functional during intermittent network connectivity.

---
Developed with 🩸 and Engineering Precision by **Almohsen Myya**.

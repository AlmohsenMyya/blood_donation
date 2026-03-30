# Software Requirements Specification (SRS) - Project: Sheryan (Lifeline)

## 1. Introduction
### 1.1 Purpose
This document provides a comprehensive overview of the **Sheryan** (Lifeline) mobile application. It outlines the functional and non-functional requirements, system architecture, and user interfaces designed to facilitate efficient blood donation management.

### 1.2 Project Scope
Sheryan is a real-time, cross-platform mobile solution (iOS/Android) built using Flutter and Firebase. It serves as a bridge between blood donors and individuals in urgent need of blood, providing a secure, role-based ecosystem.

---

## 2. General Description
### 2.1 Product Perspective
The application operates as a standalone mobile client integrated with Firebase Cloud Services. It utilizes a Reactive State Management approach (Riverpod) to ensure data integrity and a smooth user experience.

### 2.2 User Classes and Characteristics
*   **Donors:** Users willing to donate blood. They can manage their availability, view nearby requests, and track their donation history.
*   **Recipients:** Users seeking blood. They can create urgent requests, search for donors by blood type and location, and track the status of their requests.
*   **Administrators:** System overseers responsible for data validation and user management (handled via Firebase Console/Custom Admin Module).

---

## 3. Functional Requirements

### 3.1 Authentication & Authorization (IAM)
*   **FR-1:** Users shall register using email/password or OAuth.
*   **FR-2:** The system shall support Role-Based Access Control (RBAC) - Donor vs. Recipient.
*   **FR-3:** Secure password recovery and account deletion features must be available.

### 3.2 Donor Management
*   **FR-4:** Donors shall be able to set and update their blood type and current city.
*   **FR-5:** Donors shall have a dedicated dashboard to view incoming urgent requests.

### 3.3 Request Management
*   **FR-6:** Recipients shall be able to create "Urgent Blood Requests" specifying blood type, hospital location, and urgency level.
*   **FR-7:** The system shall broadcast requests to matching donors in real-time.
*   **FR-8:** Recipients shall be able to edit or close active requests.

### 3.4 Search and Filtering
*   **FR-9:** Users shall be able to filter donors/requests based on Blood Group (A+, B-, O+, etc.).
*   **FR-10:** Geospatial filtering shall allow users to find donors/requests within specific cities.

### 3.5 Notifications
*   **FR-11:** The system shall push real-time notifications to donors when a matching request is posted in their area.

---

## 4. Non-Functional Requirements

### 4.1 Performance
*   **NFR-1:** App screens shall load within < 2 seconds under normal network conditions.
*   **NFR-2:** Real-time data updates via Firestore Streams should reflect changes within < 500ms.

### 4.2 Security
*   **NFR-3:** All data transmission must be encrypted via SSL/TLS.
*   **NFR-4:** Firebase Security Rules shall be implemented to prevent unauthorized data access between roles.

### 4.3 Availability & Reliability
*   **NFR-5:** The system shall maintain 99.9% uptime leveraging Firebase's cloud infrastructure.

---

## 5. System Architecture

### 5.1 Technology Stack
*   **Frontend:** Flutter SDK (Dart).
*   **State Management:** Riverpod 3.0 (Provider-based architecture).
*   **Backend:** Firebase (Firestore, Auth, Cloud Messaging, Storage).

### 5.2 Folder Structure (Logical Architecture)
```text
lib/
├── providers/     # Reactive Logic Layer
├── services/      # Data Access Layer (Firebase Connectors)
├── screens/       # Presentation Layer (UI Components)
├── models/        # Domain Objects / Data Transfer Objects
└── utils/         # Helpers & Constants
```

---

## 6. External Interface Requirements

### 6.1 User Interface (UI)
*   **UI-1:** The interface shall adhere to Material Design 3 guidelines.
*   **UI-2:** A high-contrast Dark Mode must be the primary theme for emergency usability.

### 6.2 Communication Interfaces
*   **CI-1:** Integration with device dialer for direct contact between donors and recipients.
*   **CI-2:** Integration with FCM (Firebase Cloud Messaging) for push notifications.

---

## 7. Future Enhancements
*   Integration with Google Maps API for precise distance calculation.
*   Gamification system (Badges/Points) for active donors.
*   Integration with local hospital APIs for blood bank inventory tracking.

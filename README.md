# 🏋️‍♂️ Fitt Tracker

**Fitt Tracker** is a full-featured fitness tracking mobile application built using **Flutter**, designed to help users track workouts, monitor health vitals, and receive performance-based workout recommendations — all while demonstrating clean microservices-based backend architecture.

---

## 🚀 Features

### ✅ Core Functionality
- **User Authentication**
  - Sign up with email/password  
  - Google Sign-In integration  
  - Session management and token-based auth  

- **Workout Logging**
  - Manual workout entry (sets, reps, weight, etc.)  
  - Create and manage custom workout routines  
  - Track one-rep maxes and personal bests  

- **Health Monitoring**
  - Input and track heart rate, calories, blood pressure, oxygen levels  
  - Supports integration with smartwatch data (via API - future scope)

- **Leaderboards & Community**
  - Compare progress with friends via global leaderboard  
  - See how others are progressing with similar goals  

- **Workout Recommendations**
  - Suggests exercises based on historical performance  
  - Highlights muscle groups not recently trained  

---

## 🧱 Tech Stack

### 💻 Frontend
- **Flutter (Dart)** for cross-platform UI  
- Material Design for UI/UX consistency  
- `provider` for state management (if applicable)  
- Responsive layout for multiple device sizes  

### 🛠️ Backend (Microservices Architecture)
- **REST API** built in **Node.js** with **Express**  
- **MongoDB** for NoSQL database (User profiles, workouts, stats)  
- **Docker** used to containerize services  
- Session and token management for security  
- `uuid` for generating secure session tokens  

### 🧪 Testing and DevOps
- Postman for API testing  
- Logging via `logger` package (Flutter)  
- `SessionManager` utility for persistent local storage  
- Planned CI/CD pipeline using GitHub Actions  

---

## 🔑 Project Modules Breakdown

| Module              | Description                                 |
|---------------------|---------------------------------------------|
| `lib/screens/auth/` | Login, signup, and auth flow screens        |
| `lib/screens/feed/` | Workout feed & leaderboard display          |
| `lib/screens/routines/` | Routine management and detail view      |
| `lib/api/`          | API client handling all REST calls          |
| `lib/utils/`        | Utility functions like session manager      |
| `lib/widgets/`      | Reusable UI components                      |

---

## 📦 Backend Microservices (Planned or Implemented)

- **Auth Service** — Handles login/signup, session creation  
- **Workout Service** — Handles CRUD operations on workout data  
- **Health Data Service** — Stores and retrieves vitals  
- **Recommendation Engine** — Suggests next workouts based on trends  
- **Leaderboard Service** — Tracks scores, ranks and global comparisons  

---

## 🧪 Sample API Response (Sign-Up)

```json
{
  "message": "User created successfully",
  "user_id": "abc123xyz"
}
````

This `user_id` is saved locally and passed with every API call for authentication.

---

## 📱 Screenshots

> Coming Soon — UI previews and user flow demo GIFs will be added once polishing is complete.

---

## 🧩 Challenges Faced

* Syncing `user_id` correctly after sign-up and login
* Handling device-specific bugs on Flutter iOS simulator
* Consistent token/session persistence across app restarts
* Avoiding backend crashes due to malformed data from clients
* Making the app responsive and intuitive without relying on dropdowns

---

## 🧠 Learnings

* Deep dive into microservices with authentication, health tracking, and performance analytics
* Hands-on understanding of Flutter’s widget system and lifecycle
* REST API design that balances performance and clarity
* Debugging and deployment in a multi-platform context (Android, iOS)

---

## 📅 Timeline

| Milestone | Description                                    |
| --------- | ---------------------------------------------- |
| Week 1-2  | Frontend setup, auth screens, state management |
| Week 3-4  | Backend scaffolding, Mongo schema design       |
| Week 5    | Workout/routine creation, leaderboard logic    |
| Week 6    | Health data module + integration               |
| Week 7    | Debugging, polishing, deployment-ready state   |

---

## 🛣️ Future Scope

* 📊 Graphical charts to visualize performance over time
* ⏱️ Timer-based routines with countdown and rest alerts
* 🧠 Smarter recommendations using ML/AI models
* 📡 Real-time sync and cloud storage support
* 📥 Export data in PDF/CSV formats

---

## 🤝 Contributors

* **Mansher Singh** – Full-stack Developer
  *Always open to collaboration, feel free to connect on [LinkedIn](https://www.linkedin.com/in/mansherius)*

---

## ⚙️ Setup Instructions

### Backend

```bash
cd backend
docker-compose up --build
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

> Ensure that your device/simulator is running and backend server is reachable at the correct IP (`http://51.20.171.163:8000`)


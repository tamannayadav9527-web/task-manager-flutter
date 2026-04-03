# Task Manager App

A clean and functional Task Manager App built using Flutter. This app allows users to efficiently manage tasks with features like CRUD operations, search, filtering, recurring tasks, and status tracking.

---

# Features

- ✅ Add, Edit, Delete Tasks (CRUD)
- 🔍 Search Tasks by Title
- 🎯 Filter Tasks by Status (To-Do, In Progress, Done)
- 🔁 Recurring Tasks (Daily / Weekly)
- 🚫 Blocked Tasks Handling
- 🏷 Task Status Labels (Completed / Upcoming)
- 📅 Due Date Tracking
- 💾 Local Data Storage using SharedPreferences

---

# Demo Video

👉 Watch the demo here:
https://drive.google.com/your-video-link

---

# Tech Stack

- Flutter (UI Framework)
- Dart (Programming Language)
- Provider (State Management)
- SharedPreferences (Local Storage)

---

# Project Structure

lib/
 ├── models/          # Data models (Task)
 ├── providers/       # State management logic
 ├── screens/         # UI screens
 ├── widgets/         # Reusable UI components

---

# How to Run the App

1. Clone the repository:

git clone https://github.com/your-username/task-manager-app.git

2. Navigate to project folder:

cd task-manager-app

3. Install dependencies:

flutter pub get

4. Run the app:

flutter run

---

# Key Functionality Explained

🟢 Task Status

- Upcoming → Default state for new tasks
- Completed → When checkbox is marked

🔁 Recurring Tasks

- Daily tasks auto-create a new task for the next day when marked complete
- Weekly tasks repeat after 7 days

🚫 Blocked Tasks

- Tasks can depend on other tasks
- Blocked tasks cannot be marked complete

---

# AI Usage

AI tools like ChatGPT were used to:

- Understand Flutter concepts and architecture
- Debug issues and fix errors
- Improve UI design and structure

# Helpful Prompt Example:

«"How to implement recurring tasks in Flutter using Provider?"»

# Issue Faced:

AI-generated code caused layout overflow in UI.

# Solution:

Used "Expanded", proper padding, and column alignment to fix layout issues.

---

# Author

Tamanna Yadav

---

# Notes

This project was built as part of an assignment submission.
It demonstrates core Flutter development skills including UI design, state management, and local data persistence.

---

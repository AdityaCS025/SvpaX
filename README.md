# 🤖 SvpaX - Smart Virtual Personal Assistant

A cross-platform productivity application built with **Flutter** (frontend) and **Node.js/Express** (backend), featuring AI-powered chat, task management, reminders, news integration, weather updates, and speech recognition.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Running the Application](#-running-the-application)
- [API Documentation](#-api-documentation)
- [Project Structure](#-project-structure)
- [License](#-license)

---

## ✨ Features

- 🗣️ **AI-Powered Chat** - Intelligent conversations using Google Gemini AI
- ✅ **Task Management** - Create, update, and track your to-do items
- ⏰ **Reminders** - Set and manage reminders
- 📅 **Calendar Integration** - View and organize your schedule
- 🌤️ **Weather Updates** - Real-time weather information
- 📰 **News Integration** - Stay updated with the latest news
- 🎤 **Speech Recognition** - Voice input support
- 🔊 **Text-to-Speech** - Audio output capabilities

---

## 🛠️ Tech Stack

### Frontend (Flutter)
- Flutter SDK ^3.9.2
- Provider (State Management)
- Speech-to-Text & Flutter TTS
- HTTP for API calls
- Table Calendar

### Backend (Node.js)
- Express.js
- MongoDB with Mongoose
- Google Generative AI (Gemini)
- JWT Authentication
- Swagger API Documentation

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **npm** (comes with Node.js)
- **Flutter SDK** (^3.9.2) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- **MongoDB** - [Download](https://www.mongodb.com/try/download/community) or use [MongoDB Atlas](https://www.mongodb.com/atlas)
- **Git** - [Download](https://git-scm.com/)

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/AdityaCS025/SvpaX.git
cd SvpaX
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install
```

### 3. Flutter App Setup

```bash
# Navigate to Flutter app directory
cd ../svpax

# Get Flutter dependencies
flutter pub get
```

---

## ⚙️ Configuration

### Backend Environment Variables

Create a `.env` file in the `backend/` directory:

```env
# Server Configuration
PORT=5000

# MongoDB Connection
MONGODB_URI=mongodb://localhost:27017/svpax

# JWT Secret
JWT_SECRET=your_jwt_secret_key

# Google Gemini API Key
GEMINI_API_KEY=your_gemini_api_key

# Weather API Key (OpenWeatherMap)
WEATHER_API_KEY=your_weather_api_key

# News API Key
NEWS_API_KEY=your_news_api_key
```

### Flutter Environment Variables

Create a `.env` file in the `svpax/` directory:

```env
API_BASE_URL=http://localhost:5000
```

> **Note:** For Android emulator, use `http://10.0.2.2:5000` instead of `localhost`

---

## ▶️ Running the Application

### Start the Backend Server

```bash
cd backend

# Development mode (with auto-reload)
npm run dev

# OR Production mode
npm start
```

The server will start at `http://localhost:5000`

### Run the Flutter App

```bash
cd svpax

# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d windows    # Windows
flutter run -d chrome     # Web
flutter run -d android    # Android
flutter run -d ios        # iOS
```

---

## 📚 API Documentation

Once the backend is running, access the Swagger API documentation at:

```
http://localhost:5000/api-docs
```

---

## 📁 Project Structure

```
SvpaX/
├── backend/                 # Node.js Backend
│   ├── controllers/         # Route controllers
│   ├── models/              # Mongoose models
│   ├── routes/              # API route definitions
│   ├── services/            # Business logic & middleware
│   ├── server.js            # Entry point
│   ├── package.json         # Node dependencies
│   └── .env                 # Environment variables
│
├── svpax/                   # Flutter Frontend
│   ├── lib/                 # Dart source code
│   ├── android/             # Android platform files
│   ├── ios/                 # iOS platform files
│   ├── web/                 # Web platform files
│   ├── windows/             # Windows platform files
│   ├── pubspec.yaml         # Flutter dependencies
│   └── .env                 # Environment variables
│
└── README.md                # This file
```

---

## 📄 License

This project is licensed under the **MIT License**.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📧 Contact

For any questions or feedback, please open an issue on GitHub.

---

**Made with ❤️ by Aditya**

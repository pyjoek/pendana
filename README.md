# ❤️ Pendana  

Pendana is a **dating application built for Tanzanians**, designed to connect people through meaningful encounters. It features user profiles, encounters (like/dislike), chat messaging, and filtering options such as gender and age.  

This project is built with **Flutter (frontend)** and **Laravel (backend)**, providing a scalable, modern, and responsive dating platform.  

---

## 🚀 Features  

- 🔐 **Authentication**: User registration & login  
- 👤 **Profiles**: Create & edit user profile with photos  
- 💘 **Encounters**: Swipe through users (like/dislike system)  
- 💌 **Messaging**: Real-time chat between matched users  
- 🎯 **Filters**: Search & filter by age and gender  
- 📊 **Liked Me**: See users who liked your profile  
- 🌍 **Tanzania-only focus**: Localized experience for Tanzanian users  

---

## 🛠️ Tech Stack  

**Frontend**  
- [Flutter](https://flutter.dev) – UI framework for Android/iOS  
- Dart  

**Backend**  
- [Laravel](https://laravel.com) – PHP framework for REST APIs  
- MySQL/PostgreSQL – Database  

**Other**  
- REST API for communication between app & backend  
- Card Swiper for encounters  

---

## 📂 Project Structure  

```bash
pendana/
│
├── lib/                # Flutter app source code
│   ├── screens/        # Screens (Login, Signup, Encounters, Chat, etc.)
│   ├── widgets/        # Reusable UI components
│   ├── models/         # Data models
│   ├── services/       # API calls
│   └── main.dart       # App entry point
│
├── backend/ (Laravel)  # Backend project (separate repo or folder)
│   ├── app/Http        # Controllers & APIs
│   ├── database/       # Migrations & seeds
│   └── routes/api.php  # API endpoints
│
└── README.md

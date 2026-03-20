# 📱 Instagram Flutter Clone

A **pixel-perfect** Instagram Home Feed clone built with Flutter — replicating the look, feel, and interactions of the real Instagram app.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/State-Provider-blueviolet)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

- 📖 **Stories Tray** — Horizontally scrollable stories with gradient rings and "Your Story" badge
- 🖼️ **Feed Posts** — Full-width posts with captions, likes, comments, and timestamps
- 🔍 **Pinch-to-Zoom** — Smooth overlay zoom using `InteractiveViewer` with spring-back animation
- ♾️ **Infinite Scrolling** — Auto-fetches next page when approaching the end of the feed
- ❤️ **Like & Save** — Stateful toggle buttons with animated transitions and double-tap to like
- ✨ **Shimmer Loading** — Skeleton loaders on initial load and pagination (no plain spinners)
- 🗂️ **Carousel Posts** — Multi-image posts with dot indicator and page counter badge
- 🌐 **Cached Network Images** — Memory and disk caching via `cached_network_image`
- 📐 **Responsive UI** — Uses `MediaQuery` for pixel-perfect sizing across all screen sizes

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | Provider 6.x |
| Image Caching | cached_network_image |
| Loading Skeleton | shimmer |
| Fonts | google_fonts (Grand Hotel) |

---

## 🎥 Demo

<p align="center">
  <img src="assets/gif/Adobe Express - Instagram_clone (1) (1).gif.gif" width="300"/>
</p>

---

## 📸 Screenshots

| Home Feed | Stories | Pinch-to-Zoom |
|---|---|---|
| ![Feed](assets/screenshots/feed.png) | ![Stories](assets/screenshots/stories.png) | ![Zoom](assets/screenshots/zoom.png) |

| Shimmer Loading | Carousel Post | Like Toggle |
|---|---|---|
| ![Shimmer](assets/screenshots/shimmer.png) | ![Carousel](assets/screenshots/carousel.png) | ![Like](assets/screenshots/like_toggle.png) |

---

## 🚀 How to Run

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter plugin

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/pawanshersiya/instagram_clone.git
cd instagram_clone

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run

# 4. Build release APK (optional)
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & MultiProvider root
│
├── models/
│   ├── post_model.dart          # PostModel, UserModel data classes
│   └── story_model.dart         # StoryModel data class
│
├── services/
│   └── post_repository.dart     # Mock data layer with 1.5s simulated delay
│
├── providers/
│   └── feed_provider.dart       # ChangeNotifier providers (feed, like, save, carousel)
│
├── screens/
│   └── home_screen.dart         # Main screen with top bar & bottom nav
│
└── widgets/
    ├── post_card.dart           # Full post UI component
    ├── stories_tray.dart        # Horizontal stories strip
    ├── pinch_to_zoom.dart       # InteractiveViewer-based zoom gesture
    ├── cached_avatar.dart       # Reusable cached circular avatar
    └── shimmer_post.dart        # Skeleton loaders for posts & stories
```

---

## 🔮 Future Improvements

- [ ] Add Instagram Reels screen with video playback
- [ ] Implement Comments bottom sheet
- [ ] Add real authentication (Firebase Auth)
- [ ] Connect to a live API or Firebase Firestore
- [ ] Add Story viewing screen with progress bar
- [ ] Dark / Light mode toggle
- [ ] Explore / Search screen
- [ ] Push notifications support

---

## 👨‍💻 Author

**Pawan Shersiya**

[![GitHub](https://img.shields.io/badge/GitHub-pawan--shersiya-181717?logo=github)](https://github.com/pawanshersiya)

---
   
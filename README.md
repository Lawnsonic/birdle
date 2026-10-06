# 🐦 Birdle

A sleek, responsive, Wordle-inspired word-guessing game built with Flutter as part of the [Flutter Learning Pathway](https://docs.flutter.dev/learn/pathway).

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)

---

## 🎮 How to Play

Guess the hidden 5-letter word in **6 attempts**!

After each guess, the tiles change color to give you feedback:

- 🟩 **Green**: The letter is in the word and in the correct position.
- 🟨 **Yellow**: The letter is in the word, but in a different position.
- ⬛ **Grey**: The letter does not appear in the word.

---

## ✨ Features

- **Interactive On-Screen Keyboard**:
  - Full QWERTY layout with dedicated `ENTER` and `⌫` (Backspace) keys.
  - Dynamic key highlighting based on evaluated letters (Hit, Partial, Miss).
- **Physical Keyboard Support**:
  - Seamless hardware keyboard input on Web, Desktop, and Mobile (A–Z, Backspace, Enter).
- **Live Tile Preview**:
  - Watch letters appear directly in the active row as you type, complete with subtle focus highlights.
- **Rich Dictionary**:
  - Over **5,700** accepted English 5-letter guesses.
  - Curated collection of bird, nature, and common target words.
- **Clean Material 3 Design**:
  - Nature-inspired teal color palette.
  - Responsive, centered layout that looks great on mobile, tablet, and desktop browsers.
- **Quality Assurance**:
  - Comprehensive unit and widget tests covering game logic and UI interactions.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.27 or newer recommended)

### Run Locally

1. Clone the repository:
   ```bash
   git clone https://github.com/Lawnsonic/Birdle.git
   cd Birdle
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Launch on Chrome or connected device:
   ```bash
   flutter run -d chrome
   ```

### Run Tests

Execute the test suite:
```bash
flutter test
```

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---
name: wonkka_expert
description: Expert assistant for developing 'Wonkka' (원까), an AI-based restaurant cost calculator.
---

# Wonkka Project Skill

This skill provides comprehensive instructions for developing the 'Wonkka' app, ensuring consistency in architecture, tech stack, and code quality.

## 🏗 Architecture: Clean Architecture + BLoC

Follow the Clean Architecture pattern strictly to separate concerns and ensure maintainability.

### 1. Presentation Layer (`lib/presentation/`)
- **BLoC/Cubit**: Manage UI state and business logic.
- **Pages**: Top-level widgets (screens).
- **Widgets**: Reusable UI components.
- **Note**: UI should only interact with BLoCs, not repositories or data sources directly.

### 2. Domain Layer (`lib/domain/`)
- **Entities**: Pure Dart objects representing the core business data.
- **Repositories (Abstract)**: Interfaces for data operations.
- **UseCases**: Encapsulate specific business rules (e.g., `CalculateRecipeCostUseCase`).
- **Note**: This layer must have NO dependency on other layers.

### 3. Data Layer (`lib/data/`)
- **Models**: Data Transfer Objects (DTOs) that can be serialized (JSON, SQLite maps).
- **Repositories (Implementations)**: Concrete implementation of domain repository interfaces.
- **DataSources**: Remote (Firebase, Gemini API) and Local (SQLite via `sqflite`).

## 🛠 Tech Stack & Packages

- **State Management**: `flutter_bloc`
- **Dependency Injection**: `get_it`
- **Database**: `sqflite`, `path`
- **Backend/AI**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_mlkit_image_labeling`, `flutter_gemini`
- **Utilities**: `image_picker`, `flutter_dotenv`, `intl`

## 📏 Coding Standards & Rules

1. **File Length**: Any single Dart file MUST NOT exceed **1,500 lines**. Split large widgets or logic into smaller, cohesive files.
2. **OOP Principles**:
   - Use **SOLID** principles.
   - Prefer composition over inheritance.
   - Use abstract classes for repository and data source definitions.
3. **Flutter API Compliance**: Only use stable and supported Flutter/Dart APIs. Avoid deprecated or platform-specific hacks that might break on web/iOS/Android.
4. **Error Handling**: Use `Either` (from `dartz`) or custom `Result` objects for Domain/Data layer operations to handle errors gracefully without throwing exceptions in business logic.
5. **UI Aesthetics**:
   - Use `flutter_screenutil` for responsive design.
   - Maintain a premium, modern look (Glassmorphism, smooth animations).
   - Use `flutter_animate` for micro-animations.
6. **Color Usage**: Do not use `withOpacity()`. Use `withAlpha()` instead for color transparency. (e.g., `color.withAlpha(25)` instead of `color.withOpacity(0.1)`).

## 📝 Documenting Work (Daily Review)

Every day, create a review document in `reviews/YYYY-MM-DD_review.md` containing:
- Summary of tasks completed.
- Code changes overview.
- Key design decisions.
- Any challenges or future TODOs.

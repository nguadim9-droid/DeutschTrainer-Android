# Environment & Setup Status (Verified)

## Machine Check Summary
Checked on current Windows workstation before scaffolding Flutter platform binaries:
- **Present:** `java` / `javac` (`23.0.2`), `git`, `npx`, `pnpm`.
- **Missing:** `flutter`, `dart`, `adb`, `sdkmanager`, `gradle`, `Android Studio`, `ANDROID_HOME`.
- **Storage Constraint:** Drive `C:` has **`11.67 GB`** free (`D:` has `0 GB`).

## Important Setup Notes
1. **Disk Space Warning (`11.67 GB` free on `C:`):**
   - Installing full Android Studio + Android Emulator system images + Flutter SDK + Gradle caches typically needs **12–18 GB** and risks filling drive `C:`.
   - **Recommended Lightweight Path:**
     1. Free at least **8–10 GB** extra space on `C:` if possible, **or** skip the heavy Android Emulator and test directly on your **real Android phone via USB Debugging**.
     2. Install **Flutter SDK (Windows stable)** into `C:\src\flutter`.
     3. Install **JDK 17** (recommended for Android Gradle stability alongside or instead of JDK 23) and **Android Command-Line Tools** (`platform-tools`, `platforms;android-35`, `build-tools;35.0.0`) — or Android Studio without an emulator image.
2. **Next Command Once Flutter & Android SDK Are Ready:**
   ```powershell
   flutter doctor
   flutter create --org com.deutschtrainer --platforms=android .
   ```
   *(Running `flutter create` inside `C:\Users\NGUADI\Downloads\DeutschTrainer-Android` will generate the verified `android/`, `pubspec.yaml`, and Gradle wrapper files without overwriting `README.md`, `AGENTS.md`, or `docs/`.)*

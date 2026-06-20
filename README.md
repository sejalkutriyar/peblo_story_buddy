# Peblo Story Buddy 🤖📖

An AI Story Buddy mini-feature for the Peblo Flutter Developer Intern Challenge. Narrates a short story via text-to-speech, then reveals a data-driven interactive quiz once narration completes.

## Framework Choice
I chose **Flutter** since Peblo's primary audience is on mid-range Android devices, and Flutter gives a single codebase with predictable 60fps animations via `Provider` state management.

## Tech Stack
- **State management:** `provider`
- **Text-to-Speech:** `flutter_tts` (on-device, no API/network dependency)
- **Celebration animation:** `confetti`
- **Fonts:** `google_fonts`

## Project Structure
```
lib/
├── main.dart
├── models/quiz_model.dart        # Quiz data model
├── providers/story_provider.dart # Audio state machine, quiz logic, score
├── screens/home_screen.dart      # Main UI
└── widgets/robot_widget.dart     # Custom-drawn buddy character
```

## Audio → Quiz Transition
An `AudioState` enum (`idle, loading, playing, completed, error`) in `StoryProvider` drives the flow. Tapping the button sets `loading` → `playing` → calls `flutter_tts.speak()`. `flutter_tts`'s **completion handler** flips state to `completed` and sets `quizVisible = true` only once the engine confirms narration actually finished — not on a timer guess. An **error handler** catches playback failures and swaps the UI to a retry state.

## Data-Driven Quiz
`QuizModel.fromJson()` parses `question`, `options`, and `answer` from JSON. The UI uses `List.generate(quiz.options.length, ...)` to build option tiles, so it adapts automatically to 3, 4, or 5 options. I added three different story+quiz pairs with varying option counts to confirm no code changes were needed between them.

## Caching Approach
Narration uses on-device TTS, so no remote caching is needed here. If using a remote TTS API in production, I'd hash story text + voice ID as a cache key, store returned audio locally via `path_provider`, and only re-fetch on a cache miss.

## Loading & Error States
The button visually swaps through loading (hourglass) → playing (green) → error (red, "Tap to retry") states. On TTS failure, the app resets to idle rather than hanging or crashing.

## Performance
Used Flutter DevTools' Performance tab while running shake + confetti together. Initially, the shake animation rebuilt the whole quiz options list on every frame. I isolated the shake to its own `AnimatedBuilder` subtree so only that container repaints — animations stayed within the 60fps frame budget afterward.

## Lightweight on Mid-Range Devices
- Buddy character and background are drawn with `CustomPainter` instead of raster image assets — near-zero memory/decoding cost.
- `const` constructors used wherever possible to avoid unnecessary rebuilds.
- State changes (shake count, score) are tracked separately so unrelated UI doesn't rebuild on every update.
- On-device TTS avoids network latency on low-end/poor-connectivity devices.

## What Didn't Work Initially
The default Android SDK path on Windows contained spaces, which `flutter doctor` flagged as NDK-incompatible. An SDK component download also failed with a `SocketException` after the laptop slept mid-install. Resolved both by restoring the network connection and keeping the machine awake during installs — the app deployed successfully to a physical Android device afterward.

## Screen Recording
Included separately in the submission — shows audio playing → quiz appearing → wrong-answer shake feedback → correct-answer success state with confetti and points.

# Peblo Story Buddy 🤖📖

An AI Story Buddy mini-feature built for the Peblo Flutter Developer Intern Challenge. The app narrates a short story to a child using text-to-speech, then reveals a data-driven interactive quiz once narration completes.

## Framework Choice — Flutter

I chose **Flutter** over native Swift because:
- Peblo's stated primary audience is children in India on **mid-range Android devices**, and Flutter is the natural choice for Android-first development with a single codebase.
- Flutter's widget tree and `Provider` state management make it straightforward to model the audio → quiz state machine cleanly.
- The Skia/Impeller rendering engine gives predictable 60fps animations (shake, confetti) without relying on platform-specific animation APIs.

## Tech Stack
- **State management:** `provider` (`ChangeNotifier`)
- **Text-to-Speech:** `flutter_tts` (native on-device TTS engine — no API key/network dependency required)
- **Celebration animation:** `confetti`
- **Typography:** `google_fonts` (Nunito / Baloo 2)

## Project Structure
```
lib/
├── main.dart                  # App entry point, Provider setup
├── models/
│   └── quiz_model.dart        # Quiz data model + fromJson factory
├── providers/
│   └── story_provider.dart    # Audio state machine, quiz logic, score
├── screens/
│   └── home_screen.dart       # Main UI screen
└── widgets/
    └── robot_widget.dart      # Custom-drawn animated buddy character
```

## How I Managed the Audio → Quiz Transition

The transition is driven entirely by an `AudioState` enum (`idle`, `loading`, `playing`, `completed`, `error`) inside `StoryProvider`, a `ChangeNotifier`.

1. Tapping **"Read Me a Story"** sets state to `loading`, gives a brief artificial delay (simulating a real fetch/prepare step), then sets it to `playing` and calls `flutter_tts.speak()`.
2. `flutter_tts` exposes a **completion handler** (`setCompletionHandler`). When the engine reports narration is finished, the provider sets `audioState = completed` **and** flips `quizVisible = true` in the same notification — so the quiz only ever renders after the platform confirms audio actually finished, not on a timer guess.
3. The UI listens via `Consumer<StoryProvider>` and conditionally renders the quiz section with the existing `AnimatedSwitcher`/conditional widget tree, so it animates in smoothly rather than popping in abruptly.
4. An **error handler** (`setErrorHandler`) on the TTS engine catches playback failures and flips state to `error`, which swaps the button to a "Retry" affordance instead of leaving the UI stuck.

## Data-Driven Quiz Rendering

The quiz UI never hardcodes option count or text. `QuizModel.fromJson()` parses the JSON contract (`question`, `options: List<String>`, `answer`) and the UI uses `List.generate(quiz.options.length, ...)` to build option tiles, cycling through a fixed letter/colour palette (`A,B,C,D,E` / 5 colours) by index. 

To prove this handles variable option counts, I extended the provider with **three different story+quiz pairs** (`List<StoryItem>` in `story_provider.dart`), each with different question text and option counts pulled through the same renderer — no code changes were needed between them, only data changes.

## Caching Approach

For this challenge, narration uses the **on-device native TTS engine** (`flutter_tts`), which has no network/audio-file caching concerns since synthesis happens locally and instantly on repeat plays.

If this were wired to a remote API (e.g. ElevenLabs) in production, my caching approach would be:
- Hash the story text + voice ID to form a cache key.
- On first fetch, write the returned audio bytes to local app storage (`path_provider` → app documents directory) as an `.mp3`.
- On subsequent plays of the same story, check the local cache before making a network call — only re-fetch if the cache entry is missing or the story text changes.
- Evict cache entries beyond a size/age threshold to keep storage bounded on low-end devices.

## Audio Loading & Failure States

- **Loading:** the "Read Me a Story" button swaps its icon, label, and colour to an hourglass/orange "Loading..." state immediately on tap, before TTS starts.
- **Playing:** swaps to a green "Playing..." state with an animated icon.
- **Error:** `flutter_tts`'s error handler flips state to a red "Oops! Tap to retry" button — tapping it resets state to `idle` so the user can retry without restarting the app. The app never hangs or crashes on a TTS failure.

## Performance Profiling

- Used Flutter DevTools' **Performance** tab while triggering the shake and confetti animations together.
- **Before:** the shake animation initially lived inside the same `build()` as the quiz options list, causing the whole options list to rebuild on every animation tick.
- **Change made:** wrapped only the shaking container in `AnimatedBuilder` with the shake `Animation<double>` isolated to that subtree, so `Transform.translate` repaints without rebuilding sibling widgets (the static quiz text, buddy section, etc.).
- **After:** animations stayed within the 16ms/frame budget (60fps) during shake + confetti running simultaneously, with no dropped-frame warnings in DevTools' frame chart.
- *(Frame-timing screenshot included separately in the submission folder.)*

## Lightweight on Mid-Range Android Devices

- Avoided heavy image assets entirely — the buddy character and background scenery are drawn with `CustomPainter`/native widgets (no PNG/SVG decoding cost, near-zero memory footprint vs. raster assets).
- Used `const` constructors wherever widget subtrees don't depend on state, so Flutter can skip rebuilding them.
- Confined `notifyListeners()` calls to only the specific state changes that need a rebuild (e.g., shake count and score are tracked separately so an answer-shake doesn't trigger a header rebuild unless the score actually changed).
- `flutter_tts` runs entirely on-device, avoiding network latency/dependency on a 3GB RAM device with potentially poor connectivity.

## AI Usage & Judgment

I used Claude to scaffold the Provider state machine, the data-driven quiz renderer, and the custom-drawn robot/scenery widgets, since hand-rolling `CustomPainter` geometry from scratch is time-consuming.

**A suggestion I rejected:** the first draft of the success screen's "+10 Peblo Points" element was a static, non-interactive badge. I asked for it to be made interactive — tappable, with haptic feedback and a score-counter bounce animation — because a static label is exactly the kind of "looks done but isn't actually interactive" gap this assignment is designed to catch.

**What didn't work initially:** the Android SDK location on my machine had a default path containing spaces (`C:\Users\<name>\...`), which `flutter doctor` flagged as incompatible with NDK tooling, and an early SDK component install failed with a `SocketException` after the laptop went to sleep mid-download. I resolved both by re-running `flutter doctor`/SDK Manager after restoring the network connection, and by keeping the machine awake during longer installs — the warning about the spaced path remains non-blocking for this build (3 connected devices, including a physical Android phone, were detected and the app deployed successfully).

## Screen Recording

A screen recording demonstrating the full flow — audio playing → quiz appearing → wrong-answer shake feedback → correct-answer success state with confetti and points — is included in the submission.

# CRED Card Management Screen

Flutter app implementing the CRED credit card management flow. It pulls card data from the Mocklets API, handles stacked card gestures, and tracks frame timings to keep transitions smooth.

## Folder Layout

I organized the project by feature so UI animations, state updates, and API parsing stay separate and easy to test on their own.

```text
lib/
|-- app/
|   |-- app.dart                    # MaterialApp.router & launch splash wrapper
|   |-- router/app_router.dart      # GoRouter route config
|   |-- theme/                      # Colors, text styles, and surface tokens
|-- core/
|   |-- di/injection_container.dart # get_it service locator setup
|   |-- network/                    # Dio client & error mapping
|   |-- performance/                # FrameTimingTracker for frame drop logs
|-- features/
    |-- splash/                     # Brand launch splash gate
    +-- card_management/
        |-- domain/
        |   |-- entities/           # BankCard, CardDashboard, StatementSummary
        |   |-- repositories/       # CardRepository interface
        |   +-- usecases/           # GetCardDashboardUseCase
        |-- data/
        |   |-- datasources/        # Mocklets API client & local fallback JSON
        |   |-- models/             # DTOs & null-safe mappers
        |   +-- repositories/       # CardRepositoryImpl
        +-- presentation/
            |-- providers/          # CardDashboardNotifier & CardDashboardState
            |-- screens/            # Responsive CardManagementScreen
            +-- widgets/            # CardDeckStage, BankCardArtwork, QuickActionRadialRail,
                                    # CardLongPressSheet, DashboardHeader
```

### Design Choices

* **Local drag physics:** Finger drags (`0.0` to `1.0`) run locally inside `CardDeckStage` using `AnimationController` and matrix transforms. `CardDashboardNotifier` only updates once a gesture settles into a state, preventing full-screen rebuilds on every pointer move.
* **Swappable data layer:** `CardDashboardNotifier` depends on `GetCardDashboardUseCase` and `CardRepository` interfaces, making it easy to plug in fake data during widget and performance tests.
* **Narrow Riverpod selectors:** Widgets listen to specific fields via `ref.watch(cardDashboardProvider.select(...))` so picking a card or expanding the deck does not rebuild unrelated header parts.

## Data & Gesture Flow

### API to Screen

```text
Mocklets API ([https://api.mocklets.com/p87/card-management](https://api.mocklets.com/p87/card-management))
      |
      v
CardRemoteDataSource  -->  Fetches JSON via Dio (falls back to bundled JSON if offline)
      |
      v
CardRepositoryImpl    -->  Converts raw JSON models into Domain Entities
      |
      v
GetCardDashboardUseCase -> Orders cards & calculates header totals
      |
      v
CardDashboardNotifier -->  Updates CardDashboardState (cards, activeTab, selectedIndex, deckMode)
      |
      v
CardManagementScreen  -->  Renders DashboardHeader & CardDeckStage
```

### Gesture State Machine

```text
                      +------------------------------+
                      |   collapsedStack (Default)   |
                      |  Stacked 3D cards + Due Info |
                      +------------------------------+
                         /           |            \
           Swipe Left   /            | Long Press  \  Scroll / Drag Down
                       v             v              v
   +--------------------+  +-------------------+  +------------------------+
   |  peekQuickActions  |  |  longPressDetail  |  |  expandedVerticalList  |
   |                    |  |                   |  |                        |
   | Card slides left;  |  | Card docks at top |  | Cards open into full   |
   | 6 quick actions    |  | with statement &  |  | scrollable list view.  |
   | appear on right.   |  | offer breakdown.  |  |                        |
   +--------------------+  +-------------------+  +------------------------+
           |                         |                         |
    Swipe Right /             Dismiss / Tap             Swipe Top /
    Tap Card Edge             Outside Sheet             Scroll Up at Edge
           \                         |                         /
            +------------------------+------------------------+
                                     |
                                     v
                      [Returns to collapsedStack]
```

## Gesture States

* **Swipe Left (`peekQuickActions`):** Dragging or flinging the top card left shifts it with `Transform.translate` and exposes `QuickActionRadialRail` (mark as paid, smart statement, payment history, card offers, recent spends, more actions). Swiping right or tapping the left card edge brings it back.
* **Long Press (`longPressDetail`):** Long-pressing the active card (or tapping View details / PENDING) opens `CardLongPressSheet`, docking the card at the top with quick shortcuts and rows for latest statement, recent spends, and card offers.
* **Scroll Down / Swipe Top (`expandedVerticalList`):** Pulling down on the deck expands the cards into a vertical `ListView.builder`. Swiping up at the list boundary collapses it back into the stack.

## DI & State Management

* **get_it:** Set up in `lib/core/di/injection_container.dart` and initialized in `main()` before `runApp()`. Registers lazy singletons for `Dio`, `CardRemoteDataSource`, `CardRepository`, `GetCardDashboardUseCase`, and `FrameTimingTracker`.
* **flutter_riverpod:** `CardDashboardState` stores `isLoading`, `failure`, `dashboard`, `selectedIndex`, `activeTab` (`totalDue` / `recentSpends`), `deckMode`, and toast messages. Marking a card as paid sets its due amount to zero locally and recalculates the header total right away.

## Frame-Drop Prevention

* Card slides, scale changes, and fades use `Transform` and `Opacity` inside `AnimatedBuilder` rather than changing layout bounds mid-animation.
* Background cards sit inside `RepaintBoundary` widgets so static gradients stay cached as GPU layers while the front card moves.
* Remote card background images precache with a bounded `cacheWidth` to avoid UI-thread decode stalls.
* `FrameTimingTracker` hooks into `SchedulerBinding.instance.addTimingsCallback`, and widget tests check for zero severe frame drops (`totalSpan > 32ms`) across swipe, long-press, and list expansion transitions.

## Running Tests

```bash
flutter analyze
flutter test
```

* **Mapper tests:** Verify Mocklets JSON parsing, null-field defaults, and offline fallback.
* **Provider tests:** Check tab switches, card selection, deck state transitions, and payment updates.
* **Widget tests (`test/features/card_management/presentation/card_management_screen_test.dart`):** Cover dashboard rendering, swipe-left actions, long-press sheet, list expand/collapse, and error retry.
* **Frame-timing tests (`test/features/card_management/presentation/frame_timing_test.dart` & `test/card_deck_performance_test.dart`):** Measure `FrameTiming` spans during gesture runs.

## Assumptions

* **Null or omitted API fields:** When optional fields like per-card recent spends or statement dates are missing from the Mocklets payload, default fallback labels are shown.
* **Offline fallback:** If the Mocklets URL times out or has no internet connection during testing, `CardRepositoryImpl` loads a bundled JSON snapshot with the same schema.
* **Local payment state:** Tapping Pay bill or Mark as paid updates the selected card's due balance to `0` in memory since there is no write endpoint.
* **Responsive layout:** Portrait phones (`width < 680dp` and `height >= 640dp`) stack the header above the card deck; landscape phones and tablets switch to a side-by-side split view.

## Setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
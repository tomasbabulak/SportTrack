# ``SportTrack``

This app is a workout tracker built with a **MVVM** architecture, separating UI from business logic for improved testability and maintainability.

## Key Features

### Storage
In the app are used two types of storage - cloud and local. Both storages are managed by StorageService.
- **Cloud**: Firestore provides real-time sync and scalable cloud storage.
- **Local**: SwiftData ensures offline access and fast local data handling. 

### Adding New Workouts
Users can tap "Plus" in the navigation bar to add a workout. A modal screen is presented for workout input.

#### Benefits:
- Focused and distraction-free input.
- Clear workflow for adding content.
- Contextual consistency. 

### Logic Separation
All business logic is contained in view models, making it fully testable, as demonstrated in `WorkoutViewModelTests`.
Benefits:
- Testability is improved with isolated logic.
- Reusable, decoupled logic from the views. 

### Libraries
Libraries are maintained with PM.
- **Dependencies** (by Point-Free): Used for dependency injection, improving modularity and simplifying testing.
- **SwiftUINavigation** (by Point-Free): Facilitates state-driven navigation in SwiftUI. 

### Additional Features
- Error handling and alert presentation - implemented in **Workout View**
- Logging - all error events are logged
- User can filter workouts based on storage type
- Supports both portrait and landscape orientations.
- Fully compatible with dark mode and light mode.
- Includes Large Content accessibility support. 

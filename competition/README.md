# Sports Competition App

A Flutter mobile application that allows users to search for sports competitions, teams, and players, view details, save favorites, and see team locations on a map.

## Features

- **Search Functionality**: Search for competitions, teams, and players with real-time results
- **Detailed Information**: View comprehensive details about competitions, teams, and players
- **Favorites System**: Save your favorite teams and players locally
- **Interactive Map**: See the locations of major teams on a map
- **Beautiful UI**: Modern and responsive user interface

## Project Structure

The project follows a clean architecture with separation of concerns:

```
lib/
├── data/            # Database helpers and local storage
├── models/          # Data models (Competition, Team, Player)
├── providers/       # State management using Provider
├── screens/         # UI screens
│   └── details/     # Detail screens for competitions, teams, players
├── services/        # API services
├── utils/           # Utility functions and constants
├── widgets/         # Reusable UI components
└── main.dart        # Application entry point
```

## Setup Instructions

1. **Clone the repository**

2. **Get dependencies**
   ```
   flutter pub get
   ```

3. **API Key Setup**
   - Register for a free API key at [Football-Data.org](https://www.football-data.org/)
   - Open `lib/services/api_service.dart` and replace `YOUR_API_KEY` with your actual API key

4. **Google Maps Setup** (for the map feature)
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - For Android: Add your API key to `android/app/src/main/AndroidManifest.xml`
   - For iOS: Add your API key to `ios/Runner/AppDelegate.swift`

5. **Run the app**
   ```
   flutter run
   ```

## Technologies Used

- **Flutter**: UI framework
- **Provider**: State management
- **SQLite**: Local database for favorites
- **HTTP**: API requests
- **Google Maps**: Map integration
- **Cached Network Image**: Image caching

## API Information

This app uses the [Football-Data.org API](https://www.football-data.org/documentation/api) which provides comprehensive data on football competitions, teams, and players. The free tier has some limitations on the number of requests, but it's sufficient for demonstration purposes.

## Future Improvements

- Add authentication system
- Implement more advanced search filters
- Add match schedules and live scores
- Improve offline capabilities
- Add statistics and charts for teams and players

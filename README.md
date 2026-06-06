# HireHub

HireHub is a 2-screen Flutter application that fetches live job openings from:

https://www.arbeitnow.com/api/job-board-api

## Features

- Reactive state management using GetX (no `setState` for API/network state)
- Typed JSON mapping with `JobModel`
- Search jobs by title or company name
- Bookmark jobs locally with a heart toggle
- Open detailed job description on tap
- Apply button launches the source URL via `url_launcher`
- Resilient error handling with a `Try Again` action

## Architecture

- `lib/models/job_model.dart`: typed model and JSON parsing
- `lib/services/job_api_service.dart`: API call and exception handling
- `lib/controllers/job_controller.dart`: reactive app state (jobs/search/bookmarks/loading/error)
- `lib/screens/job_dashboard_screen.dart`: search, loading, retry, list feed
- `lib/screens/job_detail_screen.dart`: full job description and apply action
- `lib/widgets/job_card.dart`: reusable job list item

## Run

```bash
flutter pub get
flutter run
```

## Test & Lint

```bash
flutter analyze
flutter test
```

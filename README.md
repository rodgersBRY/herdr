# Cattle Manager Client

Flutter mobile client for the Cattle Manager backend.

## Environment Setup

This app now reads runtime config from `.env`.

1. Copy `.env.example` to `.env`
2. Set your API URL and optional local auth defaults

Example:

```env
API_BASE_URL=http://localhost:8888/v1
AUTH_EMAIL=
AUTH_PASSWORD=
```

Do not commit real secrets in `.env`. It is ignored by git.

## Run

```bash
flutter pub get
flutter run
```

## Auth Flow

- `POST /auth/sign-up`
- `POST /auth/sign-in`
- `POST /auth/refresh` (automatic on 401)
- `GET /auth/me` (session restore/profile fetch)

All protected API requests include `Authorization: Bearer <access_token>`.

## Backend Feature Endpoints Used

- Cows: list, get single, create, update status/details
- Milk logs: list by cow/date, create, update
- Health records: list, create, update
- Breeding records: list, create
- Expenses: list, create
- Milk sales: list, create
- Alerts + Dashboard summaries

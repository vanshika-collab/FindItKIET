# FindItKIET

Lost‑and‑found system with an iOS app and Node.js backend.

---

## Requirements (macOS)
- Xcode (latest)
- Homebrew
- Node.js 18
- PostgreSQL 14

---

## One‑Time Setup

### 1) Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2) Install Node.js 18
```bash
brew install node@18
echo 'export PATH="/opt/homebrew/opt/node@18/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
node -v
```

### 3) Install PostgreSQL 14
```bash
brew install postgresql@14
brew services start postgresql@14
createdb finditkiet
```

---

## Backend Setup (Node + Prisma)

```bash
cd backend
npm install
```

Update `.env` to match your local username:
```
DATABASE_URL="postgresql://<your-username>@localhost:5432/finditkiet?schema=public"
```

Generate Prisma client + run migrations:
```bash
npm run prisma:generate
npm run prisma:migrate
```

Start backend:
```bash
npm run dev
```

Backend runs on:
```
http://localhost:8000/api/v1
```

---

## iOS App Setup

Open `ios-app/FindItApp/Core/Config/Config.swift`:

```
#if targetEnvironment(simulator)
static let baseURL = "http://localhost:8000/api/v1"
#else
static let baseURL = "http://<your-mac-ip>:8000/api/v1"
#endif
```

Run the app in Xcode.

---

## First Login

Since the database is empty, register a new user from the app:
- Email: any valid email
- Password: at least 6 characters
- Name: any

Then log in with the same credentials.

---

## Troubleshooting

- If the backend doesn’t start, check the terminal output.
- If the app can’t connect:
  - Simulator should use `localhost`.
  - Physical device must use your Mac’s IP address.
- Make sure PostgreSQL is running:
```bash
brew services list
```

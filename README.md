# 🎯 Darts Scorekeeper

This is a Flutter application for tracking scores in a classic 501 darts game between two players. The app supports player management and stores win statistics using Supabase as the backend database.

## 📦 Features

- Add and delete players
- Select players before each game
- Score entry with real-time updates
- Double out logic to finish games
- Win count tracking in Supabase

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/OlliYY/darts_scorekeeper.git
cd darts_scorekeeper
```

### 2. Install Flutter and Dependencies

Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed.

```bash
flutter pub get
```

### 3. Configure Supabase

Create a file called `lib/supabase_config.dart` and add your own Supabase credentials:

```dart
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseAnonKey = 'your-anon-key';
```

You also need a Supabase table called `players`:

| Column | Type    | Notes             |
|--------|---------|-------------------|
| id     | UUID    | Primary key       |
| name   | Text    | Player name       |
| wins   | Integer | Default = 0       |

You can create the table manually in Supabase or use SQL:

```sql
create table players (
  id uuid primary key default gen_random_uuid(),
  name text,
  wins integer default 0
);
```

### 4. Run the App

Make sure an Android emulator is running or a device is connected:

```bash
flutter run
```

---

## 🛠 Tech Stack

- Flutter (Dart)
- Supabase (PostgreSQL as DBaaS)
- Android Emulator for testing

---

## 🧪 Demo Screenshots

*Add demo screenshots here if available*

---

## 📄 License

This project is for educational purposes only.
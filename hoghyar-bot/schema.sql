CREATE TABLE IF NOT EXISTS users (
 telegram_id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, first_name TEXT,
 reminder_minutes INTEGER NOT NULL DEFAULT 60, created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS shifts (
 id INTEGER PRIMARY KEY AUTOINCREMENT, telegram_id TEXT NOT NULL, shift_date TEXT NOT NULL,
 shift_type TEXT NOT NULL, start_at_ms INTEGER NOT NULL, notified_at TEXT,
 created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (telegram_id) REFERENCES users(telegram_id) ON DELETE CASCADE,
 UNIQUE (telegram_id, shift_date)
);
CREATE INDEX IF NOT EXISTS idx_shifts_reminders ON shifts (notified_at, start_at_ms);
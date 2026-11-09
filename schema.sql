-- AI Deadline Agent: table for extracted deadlines
CREATE TABLE deadlines (
  id SERIAL PRIMARY KEY,
  course TEXT,
  task TEXT NOT NULL,
  due_at TIMESTAMPTZ NOT NULL,
  priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
  source_email_id TEXT UNIQUE,          -- Gmail message ID, so the same email is never saved twice
  created_at TIMESTAMPTZ DEFAULT now()
);

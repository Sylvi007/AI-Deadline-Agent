# AI Deadline Agent

An n8n agent that reads university emails (English and Japanese), extracts
assignment and exam deadlines with an LLM, stores them in PostgreSQL and
creates Google Calendar reminders automatically, with no manual typing.

![Workflow](docs/flow.png)

## Results

Tested on 15 real university emails (English and Japanese): the agent found 1 assignment
deadline (World Economy, Assignment One) and marked the other 14 as having no deadline.
Full accuracy check in progress.

## How it works

| Step | Node | What it does |
|---|---|---|
| 1 | Gmail | Fetches university emails (`from:tiu.ac.jp -from:me`) |
| 2 | Basic LLM Chain + Google Gemini | Reads the subject and body and extracts the deadline |
| 3 | Structured Output Parser | Forces the answer into fixed JSON (`has_deadline`, `course`, `task`, `due_date`, `due_time`, `priority`) |
| 4 | IF | Continues only when `has_deadline` is true |
| 5 | Postgres | Saves the deadline; `source_email_id` is UNIQUE, so the same email is never saved twice |
| 6 | Google Calendar | Creates an event ending at the deadline and starting 1 hour before |

Example output from a real email:

```json
{
  "has_deadline": true,
  "course": "World Economy",
  "task": "Assignment One",
  "due_date": "2025-10-10",
  "due_time": "23:59",
  "priority": "medium"
}
```

## Tech stack

- **n8n** (workflow automation, AI nodes)
- **Google Gemini** (Flash model) for extraction, temperature 0
- **PostgreSQL** (hosted on Neon)
- **Gmail API** and **Google Calendar API**

## Run it yourself

1. Create a PostgreSQL database and run `schema.sql`.
2. In n8n, import `workflow.json` (Workflows → Import from file).
3. Add your own credentials: Gmail, Google Calendar, Google Gemini (or another chat model) and Postgres.
4. In the Gmail node, change the search to your university's email domain.
5. Click **Execute workflow** to test on past emails.
6. For live use, replace the Manual Trigger and Gmail "Get many" node with a **Gmail Trigger** (poll every 5 minutes).

## Files

```
ai-deadline-agent/
├── README.md
├── workflow.json   # exported from n8n, credentials removed
├── schema.sql      # PostgreSQL table
├── prompt.txt      # the extraction prompt
└── docs/flow.png   # screenshot of the workflow
```

## What I learned

- Getting reliable JSON from an LLM: structured output parser, temperature 0, and telling the model exactly what to return when there is no deadline.
- Thinking models need a higher token limit, or their answers get cut off.
- Using a UNIQUE database constraint to make the workflow safe to re-run.

# 1.125ps02 — Personal Book Manager

## Run

Requires Bash, Python 3, Gum, and the Codex CLI. The app also detects Codex bundled inside ChatGPT.app or Codex.app on macOS. Set CODEX_BIN to an absolute executable path if needed. Sign in with `codex login` and check `codex login status`, then run:

```bash
./app.sh
```

Choose Get Recommendations and enter any topic or reading goal in English. Three Codex calls run concurrently. Each request sends your topic and saved library (including ratings) to Codex and uses your signed-in account. Network access is required. Requests time out after 180 seconds; failures are shown instead of silently falling back to a fixed book list.

## Architecture

The required architecture is preserved: app.sh starts the UI; UI scripts prompt and display; workflows coordinate components; recommendation scripts generate candidates; only data/book_database.sh reads or writes books.csv. Components pass TSV records and the database stores CSV. A small Python CSV routine handles quoted titles correctly.

## Personalization and recommendations

Each request uses your entered topic. The history strategy infers preferences from saved books and ratings; the interests strategy focuses directly on the topic; discovery explores unexpected connections beyond your usual genres. Bash directly launches Codex, waits for it, enforces a 180-second timeout, and cleans temporary files. Small Python blocks only validate JSON and format TSV. The recommendations directory contains only the four files specified in the assignment. Codex output is model-generated and is not independently verified against a book database.

The workflow launches all three scripts with &, captures process IDs with $!, waits for completion with wait, and displays running/done progress. It combines their output with cat and pipes it into refine_recommendations.sh for duplicate removal, exclusion of saved books, and a shortlist of at most six. Books are ranked by votes from distinct strategies (1-3); repeated suggestions within one strategy count once. Ties retain candidate order, and the shortlist shows the supporting strategies and reasons. The UI saves selected books directly without another Codex call.

## Other operations

Browse, add, search, and update reading status or ratings from the menu. Statuses are owned, want-to-read, reading, and finished. Ratings are 1-5; 0 is unrated. Arrow keys select and Enter confirms.

books/fetch_book_metadata.sh calls Codex for the genre and original publication year of the entered title and author. There is no built-in book list. Unknown fields are returned as unknown; model-generated facts are not independently verified. Adding a book makes one metadata request using your Codex allowance. The UI displays the year and lets you edit the genre before saving. The existing CSV schema does not store the year; links remain unknown (-). Fetching metadata and saving are separate workflow actions, so confirming a manually added book does not repeat the request.

## Direct commands

```bash
./workflows/get_recommendations.sh 'sustainable urban housing'
./workflows/manage_library.sh list
```

Use BOOK_DB to select a separate library for tests. TSV library columns are title, author, genre, status, rating, link. Candidate columns are title, author, genre, strategy, reason, link. Final recommendation column 4 is the number of distinct supporting strategies. Newlines and tabs are not allowed inside stored fields. Concurrent editing from multiple application instances is not supported.

## Submission

The original starter repository license is preserved in LICENSE. Add a short narrated demo video or a visible link, and push to your own GitHub repository after checking the remote.

Codex integration follows the [official non-interactive CLI documentation](https://developers.openai.com/codex/noninteractive/).

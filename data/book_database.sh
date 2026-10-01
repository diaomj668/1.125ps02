#!/bin/bash
# The only component that reads or writes the library CSV.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
export BOOK_DB="${BOOK_DB:-$ROOT/data/books.csv}"
python3 - "$@" <<'PYCODE'
import csv, os, sys, tempfile
from pathlib import Path
path = Path(os.environ['BOOK_DB'])
fields = ['title','author','genre','status','rating','link']
args = sys.argv[1:]
command = args[0] if args else 'list'
args = args[1:]
def fail(message):
    print(message, file=sys.stderr); sys.exit(1)
def key(value): return value.strip().casefold()
def emit(rows):
    for row in rows:
        print('\t'.join(row.get(f, '') for f in fields))
try:
    if path.exists():
        with path.open(newline='') as f:
            reader = csv.DictReader(f)
            if reader.fieldnames != fields: fail('Unexpected library CSV header.')
            rows = list(reader)
    else: rows = []
    if command == 'list': emit(rows)
    elif command == 'search':
        if len(args) != 1: fail('Usage: search TERM')
        emit([r for r in rows if key(args[0]) in key(' '.join(r.values()))])
    elif command == 'exists':
        if len(args) != 2: fail('Usage: exists TITLE AUTHOR')
        sys.exit(0 if any(key(r['title']) == key(args[0]) and key(r['author']) == key(args[1]) for r in rows) else 1)
    elif command in ('add','update'):
        if any(any(c in a for c in '\t\r\n') for a in args): fail('Fields cannot contain tabs or newlines.')
        if command == 'add':
            if len(args) != 6: fail('Usage: add TITLE AUTHOR GENRE STATUS RATING LINK')
            record = dict(zip(fields, [a.strip() for a in args]))
            if not record['title'] or not record['author']: fail('Title and author are required.')
            if any(key(r['title']) == key(record['title']) and key(r['author']) == key(record['author']) for r in rows): fail('This book is already in your library.')
            rows.append(record)
        else:
            if len(args) != 4 or args[2] not in ('status','rating'): fail('Usage: update TITLE AUTHOR status|rating VALUE')
            record = next((r for r in rows if key(r['title']) == key(args[0]) and key(r['author']) == key(args[1])), None)
            if record is None: fail('Book not found.')
            record[args[2]] = args[3].strip()
        if record['status'] not in ('owned','want-to-read','reading','finished'): fail('Invalid status.')
        if record['rating'] not in ('0','1','2','3','4','5'): fail('Rating must be 0 (unrated) or 1-5.')
        path.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.NamedTemporaryFile(mode='w', newline='', dir=path.parent, delete=False) as f:
            tmp = f.name
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader(); writer.writerows(rows)
        os.replace(tmp, path)
    else: fail('Unknown database command: ' + command)
except (OSError, csv.Error) as e: fail(str(e))
PYCODE

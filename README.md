# Project-LEX docs

Source of the Project LEX documentation (MkDocs Material).

```bash
python -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
mkdocs serve            # http://127.0.0.1:8000
mkdocs build --strict   # same check CI runs
```

Content lives in [`docs/`](docs/), navigation in [`mkdocs.yml`](mkdocs.yml).
Merges to `main` build the Docker image and deploy it via Coolify.

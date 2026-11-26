# Project-LEX docs

Source of the Project LEX documentation (Zensical).

Dev server in a container (hot reload, http://localhost:8000):

```bash
docker compose up --build
```

Or without Docker:

```bash
python -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
zensical serve          # http://127.0.0.1:8000
zensical build --strict # same check CI runs
```

Content lives in [`docs/`](docs/), navigation in [`mkdocs.yml`](mkdocs.yml).
Merges to `main` build the Docker image and deploy it via Coolify.

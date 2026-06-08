# Conduit Container Project

This repository contains a containerized Conduit fullstack application with an Angular frontend served by Nginx, a Django backend served through Gunicorn, and a PostgreSQL database.

The frontend routes API requests through the local Nginx proxy to communicate with the Django backend inside the Docker network. The external stylesheet dependency was replaced with a locally served file.

## Table of Contents

* [Project Structure](#project-structure)
* [Quickstart](#quickstart)
* [Configuration](#configuration)
* [Usage](#usage)
* [Security Notes](#security-notes)
* [Troubleshooting](#troubleshooting)

## Project Structure

```text
.
├── backend/
│   ├── conduit/
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── requirements.txt
│   └── .dockerignore
├── docs/
│   └── conduit-container-checklist.pdf
├── frontend/
│   ├── src/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .dockerignore
├── docker-compose.yaml
├── example.env
├── .gitignore
└── README.md
```

## Quickstart

```bash
git clone git@github.com:StevanAleksandrov/conduit-container-project.git
cd conduit-container-project
cp example.env .env
docker compose up -d --build
```

| Service      | URL                            |
| ------------ | ------------------------------ |
| Frontend     | http://localhost:8282          |
| API proxy    | http://localhost:8282/api/tags |
| Django admin | http://localhost:8000/admin/   |

## Configuration

Runtime configuration is based on [`example.env`](./example.env).

Create a local `.env` file from the template:

```bash
cp example.env .env
```

The `example.env` file contains the default variables required for the Docker Compose setup. For local usage, the default values can be used directly.

For VM deployment, adjust at least `DJANGO_ALLOWED_HOSTS` in the local `.env` file:

```env
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,<vm-ip>
```

The Django admin login uses the email and password configured through `DJANGO_SUPERUSER_EMAIL` and `DJANGO_SUPERUSER_PASSWORD`.

Database data is persisted through a Docker volume and survives `docker compose down`. Use `docker compose down -v` only when a full reset is intended.

## Usage

```bash
# Start or rebuild
docker compose up -d --build

# Show running services
docker compose ps

# Stop without deleting data
docker compose down

# View logs
docker compose logs backend
docker compose logs frontend
docker compose logs database

# Save logs to a file
docker logs <container-name> > container-logs.txt
```

## Security Notes

* `.env` is ignored by Git and must not be committed.
* `example.env` contains placeholder values only.
* No SSH keys, tokens, passwords or real IP addresses are stored in the repository.
* The PostgreSQL service is not exposed through a public host port.

## Troubleshooting

**502 Bad Gateway** — backend container is not running or not reachable:

```bash
docker compose ps
docker compose logs backend
```

**Missing frontend styles** — rebuild the frontend image:

```bash
docker compose build frontend
docker compose up -d frontend
```

**Reset database state** — local testing only:

```bash
docker compose down -v
docker compose up -d --build
```

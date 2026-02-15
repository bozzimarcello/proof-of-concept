# Project Guidelines

## Overview
Production-ready React + FastAPI authentication template designed for rapid project initialization with industry-standard security practices.

**This is a reusable template** - See [NEW_PROJECT_SETUP.md](NEW_PROJECT_SETUP.md) for using it in new projects.

## Technology Stack
**Frontend:**
- React 18.2
- React Router 6.21
- Bootstrap 5.3 / React-Bootstrap 2.9
- Axios for HTTP requests

**Backend:**
- FastAPI 0.104
- Uvicorn server
- Python 3.14 (with venv in backend/)
- PostgreSQL 16 (via Podman/Docker container)
- SQLAlchemy 2.0 ORM
- Alembic for database migrations
- JWT authentication with python-jose
- Password hashing with bcrypt via passlib
- Database driver: psycopg 3.x

**DevOps:**
- Podman for containerization (rootless, daemonless)
- Podman Compose for orchestration
- Docker also supported (drop-in replacement)
- Multi-stage container images for production
- Nginx for frontend serving (production)
- Database migrations with Alembic
- Quick start automation scripts

## Project Structure
- `frontend/` - React application (runs on localhost:3000)
- `backend/` - FastAPI server (runs on localhost:8000)
  - `alembic/` - Database migration files
  - `models.py` - SQLAlchemy models
  - `schemas.py` - Pydantic validation schemas
  - `auth.py` - Authentication utilities
  - `database.py` - Database connection management
  - `config.py` - Environment configuration
- `docker-compose.yml` - Development orchestration
- `docker-compose.prod.yml` - Production orchestration
- `quickstart.sh` - Automated setup script
- `init-new-project.sh` - Template initialization script
- `test_backend.py` - Backend testing script
- `NEW_PROJECT_SETUP.md` - Template usage guide

## Current State
**Authentication & Security:**
- ✅ Real JWT authentication with token expiration
- ✅ Password hashing with bcrypt
- ✅ User registration endpoint
- ✅ Environment-based configuration (.env)
- ✅ Seeded admin user: `admin` / `secret`

**Database:**
- ✅ PostgreSQL 16 with persistent storage
- ✅ SQLAlchemy ORM with proper models
- ✅ Alembic migrations for schema management
- ✅ Connection pooling and health checks

**Deployment:**
- ✅ Docker Compose (development & production)
- ✅ Podman support
- ✅ Multi-stage production Dockerfiles
- ✅ Nginx configuration for frontend
- ✅ Automated setup scripts
- ✅ Template initialization system

## Future Enhancements
- Add password reset functionality
- Add email verification
- Implement refresh tokens
- Add user profile management

## Coding Standards
- Backend: Follow FastAPI best practices, use Pydantic models
- Frontend: React functional components with hooks
- Keep CORS configured for localhost:3000

## Workflow Preferences

**Quick Start (Recommended):**
```bash
./quickstart.sh  # Interactive setup wizard
```

**Podman Compose (Easiest):**
```bash
podman-compose up -d              # Start all services
podman-compose logs -f backend    # View logs
podman-compose down               # Stop all services

# Or with podman compose:
podman compose up -d
podman compose logs -f backend
podman compose down
```

**Manual Development:**
- Use `npm` for frontend dependencies (not yarn)
- Use Python virtual environment in `backend/venv`
- Backend server: `cd backend && source venv/bin/activate && uvicorn main:app --reload`
- Frontend server: `cd frontend && npm start`

**Database Management:**
- Migrations: `alembic revision --autogenerate -m "description"` then `alembic upgrade head`
- Shell: `podman exec -it poc-postgres psql -U poc_user -d poc_auth_db`
- Logs: `podman logs poc-postgres`
- Status: `podman ps | grep postgres`

**Using as Template for New Projects:**
```bash
./init-new-project.sh my-new-app  # Rename and configure for new project
```

## Do Not
- Do not commit the `backend/venv/` directory
- Do not commit the `backend/.env` file (contains secrets)
- Do not modify CORS origins without considering security implications
- Do not use weak SECRET_KEY in production (regenerate with `openssl rand -hex 32`)

## Additional Context
This is a proof of concept application that implements industry-standard authentication practices:
- JWT tokens with expiration
- Bcrypt password hashing
- PostgreSQL for data persistence
- Environment-based configuration

The frontend requires no changes - it remains fully compatible with the new backend implementation.

# Project Guidelines

## Overview
React + FastAPI authentication proof of concept application demonstrating basic login flow with token-based authentication.

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
- PostgreSQL 16 (via Podman container)
- SQLAlchemy 2.0 ORM
- JWT authentication with python-jose
- Password hashing with bcrypt via passlib
- Database driver: psycopg 3.x

## Project Structure
- `frontend/` - React application (runs on localhost:3000)
- `backend/` - FastAPI server (runs on localhost:8000)
- `start_app.sh` - Convenience script to start both services
- `test_backend.py` - Backend testing script

## Current State
- ✅ Real JWT authentication with token expiration
- ✅ PostgreSQL database with persistent storage
- ✅ Password hashing with bcrypt
- ✅ User registration endpoint
- ✅ Seeded admin user: `admin` / `secret` (for backward compatibility)
- ✅ Database running in Podman container

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
- Use `npm` for frontend dependencies (not yarn)
- Use Python virtual environment in `backend/venv`
- Backend server: `cd backend && source venv/bin/activate && uvicorn main:app --reload`
- Frontend server: `cd frontend && npm start`

**Database (Podman):**
- Start container: `podman start poc-postgres`
- Stop container: `podman stop poc-postgres`
- View logs: `podman logs poc-postgres`
- Database shell: `podman exec -it poc-postgres psql -U poc_user -d poc_auth_db`
- Check status: `podman ps | grep poc-postgres`

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

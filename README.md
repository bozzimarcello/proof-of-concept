# React + FastAPI Authentication App

A production-ready web application template demonstrating authentication with React frontend and FastAPI backend.

> **🐳 This template uses Podman** (rootless, daemonless, Docker-compatible). See [WHY_PODMAN.md](WHY_PODMAN.md) for details. Docker works too - just replace `podman` with `docker`.

## 🎯 Use as Template

This project is designed to be used as a template for new projects. See **[NEW_PROJECT_SETUP.md](NEW_PROJECT_SETUP.md)** for detailed instructions.

**Quick start for new projects:**
```bash
./init-new-project.sh my-new-project
./quickstart.sh
```

## Project Structure

```
/
├── frontend/          # React application
│   ├── src/           # React source code
│   │   ├── components/
│   │   ├── pages/      # Login and Welcome pages
│   │   ├── App.js      # Main application
│   │   └── index.js    # Entry point
│   └── package.json   # Frontend dependencies
│
└── backend/           # FastAPI application
    ├── main.py        # FastAPI server
    └── requirements.txt # Python dependencies
```

## Security Notes

  ⚠️  **Never commit the `.env` file!** It contains sensitive secrets:
  - `SECRET_KEY` - JWT signing key
  - Database credentials

  Always use `.env.example` as a template and create your own `.env` file locally.

## Setup Instructions

### Option 1: Quick Start with Podman Compose (Recommended)

The easiest way to get started:

```bash
# 1. Run the quick start script
./quickstart.sh

# Or manually with Podman Compose:
podman-compose up -d
# Or: podman compose up -d

# Access the application:
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000
# API Docs: http://localhost:8000/docs
```

**Default credentials:**
- Username: `admin`
- Password: `secret`

**To stop:**
```bash
podman-compose down
# Or: podman compose down
```

> **Note:** This project uses Podman by default. Docker also works - just replace `podman` with `docker` in commands.

### Option 2: Manual Setup

#### Prerequisites
- Node.js (v16+)
- Python (v3.14+)
- npm or yarn
- Podman (or Docker) for containers
  - Recommended: `podman` and `podman-compose`
  - Alternative: `docker` and `docker compose`

#### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the React development server:
   ```bash
   npm start
   ```
   The frontend will be available at `http://localhost:3000`

### Database Setup

1. Create PostgreSQL container with Podman:
   ```bash
   podman volume create poc_postgres_data
   podman run -d \
     --name poc-postgres \
     -e POSTGRES_USER=poc_user \
     -e POSTGRES_PASSWORD=poc_password \
     -e POSTGRES_DB=poc_auth_db \
     -p 5432:5432 \
     -v poc_postgres_data:/var/lib/postgresql/data \
     postgres:16-alpine
   ```

2. Verify the container is running:
   ```bash
   podman ps | grep poc-postgres
   ```

**Database Management (Podman):**
- Start: `podman start poc-postgres`
- Stop: `podman stop poc-postgres`
- Logs: `podman logs poc-postgres`
- Shell: `podman exec -it poc-postgres psql -U poc_user -d poc_auth_db`
- View containers: `podman ps`

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create environment configuration file:
   ```bash
   cp .env.example .env
   # Or manually create .env with:
   # DATABASE_URL=postgresql+psycopg://poc_user:poc_password@localhost:5432/poc_auth_db
   # SECRET_KEY=$(openssl rand -hex 32)
   # ALGORITHM=HS256
   # ACCESS_TOKEN_EXPIRE_MINUTES=30
   ```

5. Run database migrations:
   ```bash
   alembic upgrade head
   ```
   This creates the `users` table and applies all migrations.

6. Start the FastAPI server:
   ```bash
   uvicorn main:app --reload
   ```
   The backend will be available at `http://localhost:8000`

## Testing the Application

1. Open your browser and navigate to `http://localhost:3000`
2. Use the following credentials to login:
   - Username: `admin`
   - Password: `secret`
3. After successful login, you'll be redirected to the welcome page
4. The welcome page displays a personalized message from the protected API endpoint

## API Endpoints

- `GET /` - Root endpoint
- `POST /token` - Authentication endpoint (returns JWT token)
  - Accepts HTTP Basic Auth (username/password)
  - Returns: `{"access_token": "...", "token_type": "bearer", "user": {...}}`
- `GET /welcome` - Protected endpoint that returns welcome content
  - Query params: `token` (JWT), `username`
  - Returns: `{"message": "...", "user": "..."}`
- `POST /register` - User registration endpoint
  - Body: `{"username": "...", "password": "...", "full_name": "..."}`
  - Returns: `{"username": "...", "full_name": "..."}`

## Features

- ✅ React frontend with login and welcome pages
- ✅ FastAPI backend with authentication
- ✅ PostgreSQL database with SQLAlchemy ORM
- ✅ JWT token authentication with expiration
- ✅ Password hashing with bcrypt
- ✅ User registration endpoint
- ✅ Responsive layout using Bootstrap
- ✅ Protected routes and authentication flow
- ✅ Error handling and loading states
- ✅ Database persistence (data survives restarts)
- ✅ Podman containerized PostgreSQL

## Architecture

**Authentication Flow:**
1. User submits credentials via HTTP Basic Auth to `/token`
2. Backend validates credentials against PostgreSQL database
3. Backend generates JWT token with 30-minute expiration
4. Frontend stores token in localStorage
5. Protected endpoints validate JWT and query user data

**Database Schema:**
- `users` table: id, username (unique), hashed_password, full_name, created_at

**Security Features:**
- Passwords hashed with bcrypt (never stored in plain text)
- JWT tokens signed with secret key
- Token expiration enforcement
- Database connection pooling with health checks

## Testing

Run the test script to verify all endpoints:
```bash
python test_backend.py
```

This tests:
- Root endpoint
- Login with valid/invalid credentials
- Welcome endpoint with valid/invalid tokens
- User registration
- Duplicate username prevention

## Next Steps

- [ ] Add password reset functionality
- [ ] Implement email verification
- [ ] Add refresh token support
- [ ] Create user profile management
- [ ] Add more protected content endpoints
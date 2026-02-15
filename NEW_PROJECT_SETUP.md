# Using This Template for New Projects

This guide explains how to use this proof-of-concept as a template for your new projects.

## 🚀 Quick Start - Automated Setup

The easiest way to start a new project from this template:

```bash
# 1. Clone or download this repository
git clone <this-repo> my-new-project
cd my-new-project

# 2. Run the initialization script
./init-new-project.sh my-awesome-app

# 3. Start the project
./quickstart.sh
```

That's it! The initialization script will:
- ✅ Rename all "poc" references to your project name
- ✅ Generate new SECRET_KEY
- ✅ Update database names and credentials
- ✅ Update Docker container names
- ✅ Clean up existing containers
- ✅ Optionally reset Git history

## 📋 Manual Setup (Step-by-Step)

If you prefer to set up manually or want to understand each step:

### 1. Clone/Download the Template

```bash
git clone <this-repo> my-new-project
cd my-new-project
```

### 2. Rename Project References

Find and replace these in all files:

| Old Value | New Value | Where |
|-----------|-----------|-------|
| `proof-of-concept` | `your-project-name` | README.md, CLAUDE.md, docker-compose.yml |
| `poc_user` | `yourproject_user` | .env files, docker-compose.yml |
| `poc_password` | `yourproject_password` | .env files, docker-compose.yml |
| `poc_auth_db` | `yourproject_db` | .env files, docker-compose.yml |
| `poc-postgres` | `yourproject-postgres` | docker-compose.yml |
| `poc-backend` | `yourproject-backend` | docker-compose.yml |
| `poc-frontend` | `yourproject-frontend` | docker-compose.yml |

### 3. Generate New Secrets

**IMPORTANT:** Always generate a new SECRET_KEY!

```bash
# Generate new SECRET_KEY
openssl rand -hex 32

# Update backend/.env with the new key
# SECRET_KEY=<your-new-key-here>
```

### 4. Update Database Credentials

Edit `backend/.env` and `docker-compose.yml`:
- Change database name: `poc_auth_db` → `yourproject_db`
- Change database user: `poc_user` → `yourproject_user`
- Change database password: `poc_password` → Choose a strong password

### 5. Clean Up Template-Specific Files

```bash
# Remove existing containers/volumes (Podman)
podman stop poc-postgres poc-backend poc-frontend
podman rm poc-postgres poc-backend poc-frontend
podman volume rm poc_postgres_data

# Or stop compose services:
podman-compose down -v
```

### 6. Reset Git History (Optional)

```bash
rm -rf .git
git init
git add .
git commit -m "Initial commit: My New Project"
```

### 7. Start Your Project

```bash
./quickstart.sh
```

## 🎯 What This Template Provides

### Backend Features
- ✅ FastAPI application structure
- ✅ JWT authentication with expiration
- ✅ Password hashing with bcrypt
- ✅ PostgreSQL database integration
- ✅ SQLAlchemy ORM
- ✅ Alembic database migrations
- ✅ User registration and login
- ✅ Environment-based configuration
- ✅ CORS configuration
- ✅ Comprehensive test suite

### Frontend Features
- ✅ React 18 with functional components
- ✅ React Router for navigation
- ✅ Bootstrap styling
- ✅ Login and protected routes
- ✅ Token storage in localStorage
- ✅ Error handling and loading states

### DevOps Features
- ✅ Docker Compose setup
- ✅ Podman support
- ✅ Database migrations
- ✅ Development and production configs
- ✅ Quick start scripts
- ✅ Comprehensive documentation

## 🔧 Customization Checklist

After initialization, customize these for your project:

### Required Changes
- [ ] Update project name in `README.md`
- [ ] Generate new `SECRET_KEY` in `backend/.env`
- [ ] Change database credentials
- [ ] Update container names in `docker-compose.yml`
- [ ] Customize `CLAUDE.md` with your project guidelines

### Recommended Changes
- [ ] Update `frontend/public/index.html` title and meta tags
- [ ] Replace favicon in `frontend/public/`
- [ ] Customize Bootstrap theme or replace with your CSS framework
- [ ] Add your project-specific environment variables
- [ ] Update API endpoint names to match your domain

### Optional Enhancements
- [ ] Add more user fields (email, profile picture, etc.)
- [ ] Implement password reset functionality
- [ ] Add email verification
- [ ] Implement refresh tokens
- [ ] Add role-based access control (RBAC)
- [ ] Add more sophisticated error handling
- [ ] Implement rate limiting
- [ ] Add API versioning
- [ ] Add request logging
- [ ] Implement caching (Redis)

## 📁 Project Structure

```
your-project/
├── backend/                    # FastAPI application
│   ├── alembic/               # Database migrations
│   │   └── versions/          # Migration files
│   ├── main.py                # Application entry point
│   ├── config.py              # Configuration management
│   ├── models.py              # Database models
│   ├── schemas.py             # Pydantic schemas
│   ├── auth.py                # Authentication utilities
│   ├── database.py            # Database connection
│   ├── requirements.txt       # Python dependencies
│   ├── .env                   # Environment variables (secret!)
│   ├── .env.example           # Environment template
│   └── Dockerfile             # Docker configuration
│
├── frontend/                   # React application
│   ├── src/                   # Source code
│   │   ├── components/        # React components
│   │   ├── pages/             # Page components
│   │   ├── App.js             # Main app component
│   │   └── index.js           # Entry point
│   ├── public/                # Static files
│   ├── package.json           # Node dependencies
│   └── Dockerfile.dev         # Docker configuration
│
├── docker-compose.yml         # Multi-container setup
├── quickstart.sh              # Quick setup script
├── init-new-project.sh        # Project initialization script
├── test_backend.py            # Backend tests
├── README.md                  # Main documentation
├── CLAUDE.md                  # Project guidelines
├── NEW_PROJECT_SETUP.md       # This file
└── .gitignore                 # Git ignore rules
```

## 🔐 Security Best Practices

### Before Deploying to Production

1. **Environment Variables**
   - Generate strong `SECRET_KEY` (min 32 bytes)
   - Use complex database passwords
   - Never commit `.env` files

2. **Database**
   - Change default credentials
   - Use connection pooling
   - Enable SSL/TLS for connections

3. **CORS**
   - Update `allow_origins` in `main.py`
   - Don't use `"*"` in production
   - Specify exact frontend URLs

4. **Tokens**
   - Adjust `ACCESS_TOKEN_EXPIRE_MINUTES` for your needs
   - Consider implementing refresh tokens
   - Implement token revocation if needed

5. **HTTPS**
   - Always use HTTPS in production
   - Configure SSL certificates
   - Use reverse proxy (Nginx, Traefik)

6. **Dependencies**
   - Regularly update dependencies
   - Run security audits: `npm audit`, `pip-audit`
   - Pin dependency versions

## 📚 Adding New Features

### Adding a New Database Model

1. Create model in `backend/models.py`:
   ```python
   class Article(Base):
       __tablename__ = "articles"
       id = Column(Integer, primary_key=True)
       title = Column(String(200))
       content = Column(Text)
   ```

2. Create migration:
   ```bash
   cd backend
   alembic revision --autogenerate -m "Add articles table"
   alembic upgrade head
   ```

3. Create Pydantic schema in `backend/schemas.py`

4. Add endpoint in `backend/main.py`

### Adding a New Frontend Page

1. Create component in `frontend/src/pages/`:
   ```javascript
   // NewPage.js
   function NewPage() {
       return <div>New Page</div>;
   }
   export default NewPage;
   ```

2. Add route in `frontend/src/App.js`:
   ```javascript
   <Route path="/new" element={<NewPage />} />
   ```

## 🧪 Testing

Run backend tests:
```bash
python test_backend.py
```

Add your own tests following the existing patterns.

## 🚢 Deployment

### Podman Deployment

```bash
# Build for production
podman-compose -f docker-compose.prod.yml up -d
# Or: podman compose -f docker-compose.prod.yml up -d

# Or build and push to registry
podman build -t myregistry/myapp:latest .
podman push myregistry/myapp:latest
```

> **Note:** All compose files work with both Podman and Docker. Just replace `podman` with `docker` if needed.

### Manual Deployment

See deployment guides for:
- AWS (EC2, ECS, Elastic Beanstalk)
- Google Cloud (Cloud Run, GKE)
- Heroku
- DigitalOcean
- Your own VPS

## 📖 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [React Documentation](https://react.dev/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [Docker Documentation](https://docs.docker.com/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)

## 🆘 Common Issues

### Database Connection Failed
- Check if PostgreSQL container is running: `podman ps`
- Verify credentials in `backend/.env`
- Check if port 5432 is available
- Check logs: `podman logs poc-postgres`

### Frontend Can't Connect to Backend
- Verify backend is running on port 8000
- Check CORS settings in `backend/main.py`
- Clear browser cache and localStorage

### Migration Errors
- Check database connection
- Review migration files in `alembic/versions/`
- Try: `alembic downgrade -1` then `alembic upgrade head`

### Port Already in Use
- Stop conflicting services
- Change ports in `docker-compose.yml`
- Use `podman-compose down` to stop all services
- Check running containers: `podman ps`

## 💡 Tips

1. **Development Workflow**
   - Use `docker compose up` for full stack
   - Or run backend/frontend separately for faster iteration
   - Enable hot reload for both frontend and backend

2. **Database Changes**
   - Always create migrations for schema changes
   - Test migrations with `alembic upgrade head` and `downgrade`
   - Keep migrations in version control

3. **Environment Management**
   - Use `.env.development`, `.env.production`
   - Never commit real credentials
   - Document all environment variables

4. **Code Organization**
   - Keep related code together
   - Use consistent naming conventions
   - Add docstrings and comments
   - Follow the existing patterns

## 🎓 Learning Path

If you're new to this stack:

1. **Start Here**
   - Understand the existing code
   - Run the application and explore features
   - Make small modifications

2. **Build On It**
   - Add a new user field (e.g., email)
   - Create a new model and endpoints
   - Add frontend pages

3. **Advanced Topics**
   - Implement refresh tokens
   - Add WebSocket support
   - Integrate external APIs
   - Add background tasks (Celery)

---

**Questions or Issues?**

- Check the main `README.md`
- Review `CLAUDE.md` for project guidelines
- Check existing issues or create a new one

Good luck with your project! 🚀

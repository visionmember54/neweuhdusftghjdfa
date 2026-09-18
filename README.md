# Kalyan Simulator Admin Panel

This repository contains the backend and frontend for the Kalyan Simulator operations console.

## Prerequisites
- Python 3.12+ (for the backend)
- Node.js 20+ (for the frontend)

## 1. Start the Backend (FastAPI)
Open a terminal and navigate to the backend directory:

```bash
cd admin-backend
```

**Set up the environment:**
Copy the example environment file (the backend requires `JWT_SECRET` to boot up).
```bash
cp .env.example .env
```

**Activate the virtual environment:**
```bash
source .venv/bin/activate
```
*(If dependencies aren't installed, run `pip install -r requirements.txt`)*

**Run migrations and seed the database** (for fresh setups):
```bash
alembic upgrade head
python -m app.seed
```

**Start the FastAPI server:**
```bash
uvicorn app.main:app --reload --port 8000
```
*The backend will now be running at `http://localhost:8000`.*

---

## 2. Start the Frontend (Next.js)
Open a **new terminal window** and navigate to the frontend directory:

```bash
cd admin-frontend
```

**Install dependencies:**
```bash
npm install
```

**Start the development server:**
```bash
npm run dev
```
*The frontend will now be accessible at `http://localhost:3000`.*

---

## 3. Accessing the Application
Once both servers are running, open your browser and navigate to:
[http://localhost:3000/login](http://localhost:3000/login)

If you ran the seed script (`python -m app.seed`), you can log in with the seeded Super Admin credentials:
- **Email:** `admin@kalyan.com`
- **Password:** `admin123`

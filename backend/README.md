# Smart Virtual Personal Assistant Backend

## Setup & Run

1. Install dependencies:
   ```bash
   npm install
   ```
2. Create a `.env` file (see provided example).
3. Start the server:
   ```bash
   npm start
   ```
4. API docs available at [http://localhost:5000/api-docs](http://localhost:5000/api-docs)

## Project Structure
- `server.js` – Entry point
- `routes/` – API route definitions
- `controllers/` – (for future business logic)
- `models/` – Mongoose models
- `services/` – Middleware, error handling, etc.

## Features
- Authentication (dummy)
- Reminders & To-Do (CRUD)
- Calendar (dummy)
- Weather, News, Search (dummy)
- Settings & Preferences
- MongoDB (Mongoose)
- Swagger API docs
- CORS, dotenv, morgan

## API Endpoints
See Swagger docs at `/api-docs` for details.

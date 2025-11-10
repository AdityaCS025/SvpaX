require('dotenv').config({ path: __dirname + '/.env' });
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');

const app = express();

// Enhanced error handling
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
});

// Middleware
app.use(morgan('dev'));

// Configure CORS specifically for web development
const corsOptions = {
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
};

app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Add OPTIONS handling for CORS preflight
app.options('*', cors());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    geminiKey: process.env.GEMINI_API_KEY ? 'configured' : 'missing',
    time: new Date().toISOString()
  });
});

// Mount all routes
const searchRoutes = require('./routes/search');
const todoRoutes = require('./routes/todos');
const reminderRoutes = require('./routes/reminders');
const weatherRoutes = require('./routes/weather');
const calendarRoutes = require('./routes/calendar');
const newsRoutes = require('./routes/news');
const authRoutes = require('./routes/auth');
const settingsRoutes = require('./routes/settings');
const speechRoutes = require('./routes/speech');

// Routes
app.use('/search', searchRoutes);
app.use('/todos', todoRoutes);
app.use('/reminders', reminderRoutes);
app.use('/weather', weatherRoutes);
app.use('/calendar', calendarRoutes);
app.use('/news', newsRoutes);
app.use('/auth', authRoutes);
app.use('/settings', settingsRoutes);
app.use('/chat', require('./routes/chat'));
app.use('/speech', speechRoutes);

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Server error',
    message: err.message
  });
});

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    // Ensure MongoDB connection
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Start server on port 5001
    const server = app.listen(5001, () => {
      console.log('✅ Server running on http://localhost:5001');
      console.log('🔍 Test API with: http://localhost:5001/health');
    });

    // Graceful shutdown
    const shutdown = async () => {
      console.log('Shutting down server...');
      await mongoose.connection.close();
      server.close();
      process.exit(0);
    };

    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);

  } catch (error) {
    console.error('❌ Server startup failed:', error);
    process.exit(1);
  }
};

startServer();

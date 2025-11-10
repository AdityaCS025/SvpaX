const express = require('express');
const router = express.Router();
const {
  getAuthUrl,
  handleCallback,
  getCalendarEvents,
  getEventsByDate,
} = require('../controllers/calendar');

// Google Calendar OAuth routes
router.get('/auth', getAuthUrl);
router.get('/auth/callback', handleCallback);

// Calendar event routes
router.get('/events', getCalendarEvents);
router.get('/events/:date', getEventsByDate);

module.exports = router;

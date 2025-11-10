const express = require('express');
const router = express.Router();
const User = require('../models/User');

// Dummy user preferences
let dummyPrefs = { theme: 'light', notifications: true };

router.get('/', (req, res) => {
  res.json(dummyPrefs);
});

router.put('/', (req, res) => {
  dummyPrefs = { ...dummyPrefs, ...req.body };
  res.json({ message: 'Preferences updated (dummy)', preferences: dummyPrefs });
});

module.exports = router;

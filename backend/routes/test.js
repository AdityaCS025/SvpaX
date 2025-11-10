const express = require('express');
const router = express.Router();
const { testGeminiAPI } = require('../controllers/test');

// Test route for Gemini API
router.get('/gemini', testGeminiAPI);

module.exports = router;
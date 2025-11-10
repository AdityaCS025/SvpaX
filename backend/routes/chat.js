const express = require('express');
const router = express.Router();
const { getChatResponse } = require('../controllers/chat');

// Test endpoint for the chat route
router.get('/test', (req, res) => {
    res.json({ message: 'Chat route is working!' });
});

// Main chat endpoint
router.post('/', async (req, res, next) => {
    console.log('Received chat request:', {
        headers: req.headers,
        body: req.body,
        method: req.method,
    });

    try {
        await getChatResponse(req, res);
    } catch (error) {
        console.error('Chat route error:', error);
        next(error);
    }
});

module.exports = router;
const express = require('express');
const router = express.Router();
const multer = require('multer');
const speechController = require('../controllers/speech');

// Configure multer for audio file uploads
const storage = multer.memoryStorage();
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        // Accept audio files
        if (file.mimetype.startsWith('audio/') || file.mimetype === 'application/octet-stream') {
            cb(null, true);
        } else {
            cb(new Error('Only audio files are allowed'), false);
        }
    }
});

// Speech-to-Text endpoint
router.post('/stt', upload.single('audio'), (req, res) => {
    speechController.speechToText(req, res);
});

// Text-to-Speech endpoint
router.post('/tts', (req, res) => {
    speechController.textToSpeech(req, res);
});

// AI Conversation processing
router.post('/conversation', (req, res) => {
    speechController.processConversation(req, res);
});

// Complete speech conversation flow
router.post('/speech-conversation', upload.single('audio'), (req, res) => {
    speechController.speechConversation(req, res);
});

// Health check for speech services
router.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        services: {
            stt: process.env.OPENAI_API_KEY ? 'available' : 'not configured',
            tts: 'available (Web Speech API)',
            ai: process.env.GEMINI_API_KEY ? 'available' : 'not configured'
        },
        timestamp: new Date().toISOString()
    });
});

module.exports = router;
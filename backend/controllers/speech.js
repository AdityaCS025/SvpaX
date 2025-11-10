const axios = require('axios');

// Simple conversation processing without STT
const processConversation = async (req, res) => {
    try {
        const { message, conversation = [] } = req.body;

        if (!message || typeof message !== 'string') {
            return res.status(400).json({ error: 'Message is required and must be a string' });
        }

        // Build conversation context for Gemini
        const conversationContext = conversation.map(msg => ({
            role: msg.role === 'user' ? 'user' : 'model',
            parts: [{ text: msg.content }]
        }));

        // Add the new user message
        conversationContext.push({
            role: 'user',
            parts: [{ text: message }]
        });

        const response = await axios.post(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
            {
                contents: conversationContext,
                generationConfig: {
                    temperature: 0.7,
                    maxOutputTokens: 1000,
                }
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                }
            }
        );

        if (response.data && response.data.candidates && response.data.candidates[0]) {
            const assistantResponse = response.data.candidates[0].content.parts[0].text;

            res.json({
                response: assistantResponse,
                status: 'success'
            });
        } else {
            throw new Error('Invalid response from Gemini API');
        }

    } catch (error) {
        console.error('Conversation processing error:', error.response?.data || error.message);
        res.status(500).json({
            error: 'Failed to process conversation',
            details: error.response?.data?.error?.message || error.message
        });
    }
};

module.exports = {
    processConversation
};
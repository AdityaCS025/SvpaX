const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.getChatResponse = async (req, res) => {
    try {
        // Enhanced logging for debugging
        console.log('\n=== Chat Request Start ===');
        console.log('Headers:', JSON.stringify(req.headers, null, 2));
        console.log('Body:', JSON.stringify(req.body, null, 2));
        console.log('Method:', req.method);
        console.log('URL:', req.url);
        console.log('Origin:', req.get('origin'));
        console.log('=== Chat Request End ===\n');

        const { message } = req.body;
        if (!message) {
            console.log('No message provided in request');
            return res.status(400).json({ error: 'Message is required' });
        }

        console.log('Using Gemini API key:', process.env.GEMINI_API_KEY ? 'Present' : 'Missing');
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        console.log('Sending to Gemini:', message);
        const result = await model.generateContent(message);

        if (!result || !result.response) {
            console.error('Invalid response from Gemini API');
            throw new Error('Invalid response from Gemini API');
        }

        const text = result.response.text();
        console.log('Received from Gemini:', text);

        const responseObj = { response: text };
        console.log('Sending response:', responseObj);
        res.json(responseObj);
    } catch (error) {
        console.error('Chat error:', error);
        res.status(500).json({
            error: 'Chat processing failed',
            details: error.message
        });
    }
};
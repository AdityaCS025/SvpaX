const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function testGemini() {
    try {
        // Start with a basic model check
        console.log('Initializing Gemini API...');
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
        const prompt = "Say hello and give a short introduction about yourself";
        console.log('Sending prompt to Gemini...');
        const result = await model.generateContent(prompt);
        const response = await result.response;
        return response.text();
    } catch (error) {
        console.error('Gemini API Error:', error);
        throw error;
    }
}

// Test route handler
exports.testGeminiAPI = async (req, res) => {
    try {
        if (!process.env.GEMINI_API_KEY) {
            throw new Error('GEMINI_API_KEY is not configured in environment variables');
        }
        console.log('Testing Gemini API with key:', 'Present');
        const response = await testGemini();
        console.log('Gemini Test Response:', response);
        res.json({ success: true, response });
    } catch (error) {
        console.error('Test endpoint error:', error);
        res.status(500).json({
            success: false,
            error: error.message,
            details: error.toString()
        });
    }
};
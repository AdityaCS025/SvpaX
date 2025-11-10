require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

async function testGeminiAPI() {
    try {
        console.log('Testing Gemini API configuration...');
        console.log('API Key present:', !!process.env.GEMINI_API_KEY);
        console.log('API Key length:', process.env.GEMINI_API_KEY ? process.env.GEMINI_API_KEY.length : 0);

        // Initialize with API key
        const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

        // Try the base model
        console.log('\nTesting with base model...');
        const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

        // Simple test prompt
        const prompt = 'Say "Hello, API is working!"';
        console.log('Sending prompt:', prompt);

        const result = await model.generateContent(prompt);
        const response = await result.response;
        console.log('\nResponse received:', response.text());

        return true;
    } catch (error) {
        console.error('\nError details:', {
            message: error.message,
            name: error.name,
            stack: error.stack
        });
        return false;
    }
}

// Run the test
testGeminiAPI().then(success => {
    if (success) {
        console.log('\n✅ Test completed successfully!');
    } else {
        console.log('\n❌ Test failed!');
        console.log('Please check:');
        console.log('1. Your API key is correctly set in the .env file');
        console.log('2. The API key has access to the Gemini API');
        console.log('3. You are using the correct model name');
    }
});
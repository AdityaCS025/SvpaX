require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize the API with your key
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Function to list all available models
async function listAvailableModels() {
    try {
        console.log('Fetching available models...');
        const models = await genAI.listModels();
        console.log('\nAvailable Models:');
        models.models.forEach(model => {
            console.log(`\nModel Name: ${model.name}`);
            console.log(`Description: ${model.description}`);
            console.log(`Supported Generation Methods: ${model.supportedGenerationMethods.join(', ')}`);
            console.log('Temperature Range:', model.temperatureRange);
            console.log('Token Limit:', model.tokenLimit);
        });
        return models.models;
    } catch (error) {
        console.error('Error listing models:', error.message);
        return [];
    }
}

// List of models to test
const modelsToTest = [
    'gemini-pro-latest' // This is the model that's working
];

async function testModel(modelName) {
    try {
        console.log(`\nTesting model: ${modelName}`);
        const model = genAI.getGenerativeModel({ model: modelName });
        const prompt = "Say 'Hello, this model is working!'";

        console.log('Attempting to generate content...');
        const result = await model.generateContent(prompt);
        const response = await result.response;
        console.log('Response:', response.text());
        console.log(`✅ Model ${modelName} is available and working`);
        return true;
    } catch (error) {
        console.log(`❌ Model ${modelName} error:`, error.message);
        return false;
    }
}

async function testAllModels() {
    console.log('Starting Gemini API model tests...');
    console.log('API Key present:', !!process.env.GEMINI_API_KEY);

    // First, get the list of available models
    const availableModels = await listAvailableModels();

    // Then test our specific model list
    const results = [];
    console.log('\nTesting specific models...');
    for (const model of modelsToTest) {
        const success = await testModel(model);
        results.push({ model, success });
    }

    console.log('\n=== Summary ===');
    console.log('Working models:');
    results.filter(r => r.success)
        .forEach(r => console.log(`✅ ${r.model}`));

    console.log('\nNon-working models:');
    results.filter(r => !r.success)
        .forEach(r => console.log(`❌ ${r.model}`));
}

// Run the tests
testAllModels().catch(error => {
    console.error('Test script error:', error);
    process.exit(1);
});
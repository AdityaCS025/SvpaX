const axios = require('axios');

// Test the weather API for Mumbai
async function testMumbaiWeather() {
    try {
        console.log('Testing weather API for Mumbai, Maharashtra...');

        const response = await axios.get('http://localhost:5000/weather?city=Mumbai&country=IN');

        console.log('\n--- Mumbai Weather ---');
        console.log(`City: ${response.data.name}, ${response.data.sys.country}`);
        console.log(`Temperature: ${response.data.main.temp}°C`);
        console.log(`Feels like: ${response.data.main.feels_like}°C`);
        console.log(`Condition: ${response.data.weather[0].main}`);
        console.log(`Description: ${response.data.weather[0].description}`);
        console.log(`Humidity: ${response.data.main.humidity}%`);
        console.log(`Wind Speed: ${response.data.wind.speed} m/s`);
        console.log(`Min Temp: ${response.data.main.temp_min}°C`);
        console.log(`Max Temp: ${response.data.main.temp_max}°C`);
        console.log(`Pressure: ${response.data.main.pressure} hPa`);

        if (response.data.visibility) {
            console.log(`Visibility: ${response.data.visibility / 1000} km`);
        }

        console.log('\n--- API Test Successful ---');

    } catch (error) {
        console.error('Error testing Mumbai weather:', error.response?.data || error.message);
    }
}

// Run the test
testMumbaiWeather();
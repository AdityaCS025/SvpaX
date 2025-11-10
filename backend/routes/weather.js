const express = require("express");
const router = express.Router();
const axios = require("axios");
require("dotenv").config();

// Get weather for a specific city
router.get("/", async (req, res) => {
  try {
    const city = req.query.city || "Mumbai"; // Default to Mumbai
    const country = req.query.country || "IN"; // Default to India

    let locationQuery = city;
    if (country) {
      locationQuery += `,${country}`;
    }

    console.log(`Fetching weather for: ${locationQuery}`);

    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/weather?q=${locationQuery}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`
    );

    console.log(`Weather data received for ${response.data.name}`);
    res.json(response.data);
  } catch (error) {
    console.error("Weather API error:", error.response?.data || error.message);
    res.status(error.response?.status || 500).json({
      error: error.response?.data?.message || error.message
    });
  }
});

// Get weather for multiple cities
router.get("/multiple", async (req, res) => {
  try {
    const cities = req.query.cities ? req.query.cities.split(',') : ['London', 'New York', 'Tokyo', 'Mumbai', 'Sydney'];

    const weatherPromises = cities.map(async (city) => {
      try {
        const response = await axios.get(
          `https://api.openweathermap.org/data/2.5/weather?q=${city.trim()}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`
        );
        return {
          city: city.trim(),
          data: response.data,
          error: null
        };
      } catch (error) {
        return {
          city: city.trim(),
          data: null,
          error: error.response?.data?.message || error.message
        };
      }
    });

    const results = await Promise.all(weatherPromises);
    res.json(results);
  } catch (error) {
    console.error("Multiple cities weather API error:", error);
    res.status(500).json({
      error: error.message
    });
  }
});

// Search cities by name
router.get("/search", async (req, res) => {
  try {
    const query = req.query.q;
    if (!query) {
      return res.status(400).json({ error: "Search query is required" });
    }

    const response = await axios.get(
      `https://api.openweathermap.org/geo/1.0/direct?q=${query}&limit=5&appid=${process.env.OPENWEATHER_API_KEY}`
    );

    res.json(response.data);
  } catch (error) {
    console.error("City search API error:", error);
    res.status(error.response?.status || 500).json({
      error: error.response?.data?.message || error.message
    });
  }
});

// Get weather by coordinates
router.get("/coordinates", async (req, res) => {
  try {
    const { lat, lon } = req.query;

    if (!lat || !lon) {
      return res.status(400).json({ error: "Latitude and longitude are required" });
    }

    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`
    );

    res.json(response.data);
  } catch (error) {
    console.error("Weather by coordinates API error:", error);
    res.status(error.response?.status || 500).json({
      error: error.response?.data?.message || error.message
    });
  }
});

// Get 5-day forecast
router.get("/forecast", async (req, res) => {
  try {
    const city = req.query.city || "London";
    const country = req.query.country || "";

    let locationQuery = city;
    if (country) {
      locationQuery += `,${country}`;
    }

    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/forecast?q=${locationQuery}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`
    );

    res.json(response.data);
  } catch (error) {
    console.error("Weather forecast API error:", error);
    res.status(error.response?.status || 500).json({
      error: error.response?.data?.message || error.message
    });
  }
});

module.exports = router;

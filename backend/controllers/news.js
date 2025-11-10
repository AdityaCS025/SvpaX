const axios = require('axios');

// Get news headlines
exports.getNewsHeadlines = async (req, res) => {
    try {
        const { category = 'general', country = 'us' } = req.query;
        const apiKey = process.env.NEWS_API_KEY;

        if (!apiKey) {
            throw new Error('NEWS_API_KEY not configured');
        }

        const response = await axios.get(`https://newsapi.org/v2/top-headlines`, {
            params: {
                country,
                category,
                apiKey
            }
        });

        res.json(response.data);
    } catch (error) {
        console.error('Error fetching news:', error);
        res.status(500).json({ error: 'Failed to fetch news' });
    }
};

// Search news
exports.searchNews = async (req, res) => {
    try {
        const { q, from, sortBy = 'publishedAt' } = req.query;
        const apiKey = process.env.NEWS_API_KEY;

        if (!apiKey) {
            throw new Error('NEWS_API_KEY not configured');
        }

        if (!q) {
            return res.status(400).json({ error: 'Search query is required' });
        }

        const response = await axios.get(`https://newsapi.org/v2/everything`, {
            params: {
                q,
                from,
                sortBy,
                apiKey
            }
        });

        res.json(response.data);
    } catch (error) {
        console.error('Error searching news:', error);
        res.status(500).json({ error: 'Failed to search news' });
    }
};
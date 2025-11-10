const axios = require('axios');

// Mock search results for development when API quota is exceeded
const getMockResults = (query) => {
    return {
        items: [
            {
                title: `Search result for "${query}" - Wikipedia`,
                link: `https://en.wikipedia.org/wiki/${query.replace(/\s+/g, '_')}`,
                snippet: `This is a mock search result for "${query}". In a real application, this would come from Google Custom Search API.`
            },
            {
                title: `${query} - GitHub`,
                link: `https://github.com/search?q=${encodeURIComponent(query)}`,
                snippet: `Find ${query} related repositories, code, and projects on GitHub.`
            },
            {
                title: `${query} Tutorial - MDN Web Docs`,
                link: `https://developer.mozilla.org/en-US/search?q=${encodeURIComponent(query)}`,
                snippet: `Learn about ${query} with comprehensive documentation and tutorials.`
            },
            {
                title: `${query} Stack Overflow`,
                link: `https://stackoverflow.com/search?q=${encodeURIComponent(query)}`,
                snippet: `Questions and answers about ${query} from the developer community.`
            },
            {
                title: `${query} News - Google News`,
                link: `https://news.google.com/search?q=${encodeURIComponent(query)}`,
                snippet: `Latest news and updates about ${query} from various sources.`
            }
        ]
    };
};

// Perform web search
exports.search = async (req, res) => {
    try {
        const { q } = req.query;
        const apiKey = process.env.GOOGLE_SEARCH_API_KEY;
        const searchEngineId = process.env.GOOGLE_SEARCH_ENGINE_ID;

        // Validate query
        if (!q || q.trim().length === 0) {
            return res.status(400).json({ error: 'Search query is required' });
        }

        console.log(`Performing search for query: ${q}`);

        // Try Google Custom Search API first
        if (apiKey && searchEngineId) {
            try {
                const response = await axios.get('https://www.googleapis.com/customsearch/v1', {
                    params: {
                        key: apiKey,
                        cx: searchEngineId,
                        q: q.trim()
                    },
                    timeout: 5000 // 5 second timeout
                });

                // Check if the response has the expected structure
                if (response.data && response.data.items) {
                    console.log(`Google API returned ${response.data.items.length} results`);
                    return res.json(response.data);
                }
            } catch (apiError) {
                console.warn('Google Search API error, falling back to mock results:', apiError.response?.data || apiError.message);

                // Don't return error, fall through to mock results
                if (apiError.response?.status === 403) {
                    console.log('API quota exceeded, using mock results');
                }
            }
        }

        // Fallback to mock results
        console.log('Using mock search results for development');
        const mockResults = getMockResults(q.trim());
        res.json(mockResults);

    } catch (error) {
        console.error('Error performing web search:', error.message);

        // Always fallback to mock results if there's any error
        try {
            const mockResults = getMockResults(req.query.q || 'search');
            res.json(mockResults);
        } catch (fallbackError) {
            console.error('Failed to generate mock results:', fallbackError);
            res.status(500).json({
                error: 'Search service temporarily unavailable',
                message: 'Please try again later'
            });
        }
    }
};
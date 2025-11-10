const { google } = require('googleapis');

class GoogleCalendarService {
    constructor() {
        this.auth = new google.auth.OAuth2(
            process.env.GOOGLE_CLIENT_ID,
            process.env.GOOGLE_CLIENT_SECRET,
            process.env.GOOGLE_REDIRECT_URI
        );
        this.calendar = google.calendar({ version: 'v3', auth: this.auth });
    }

    setCredentials(tokens) {
        this.auth.setCredentials(tokens);
    }

    async getAuthUrl() {
        const scopes = [
            'https://www.googleapis.com/auth/calendar',
            'https://www.googleapis.com/auth/calendar.events'
        ];
        return this.auth.generateAuthUrl({
            access_type: 'offline',
            scope: scopes,
            prompt: 'consent',
            include_granted_scopes: true
        });
    }

    async getTokens(code) {
        const { tokens } = await this.auth.getToken(code);
        return tokens;
    }

    async listEvents(timeMin, timeMax) {
        try {
            const response = await this.calendar.events.list({
                calendarId: 'primary',
                timeMin: timeMin.toISOString(),
                timeMax: timeMax.toISOString(),
                singleEvents: true,
                orderBy: 'startTime',
            });
            return response.data.items;
        } catch (error) {
            console.error('Error fetching calendar events:', error);
            throw error;
        }
    }

    async addEvent(event) {
        try {
            const response = await this.calendar.events.insert({
                calendarId: 'primary',
                resource: {
                    summary: event.title,
                    description: event.description,
                    start: {
                        dateTime: event.start,
                        timeZone: 'UTC',
                    },
                    end: {
                        dateTime: event.end || event.start,
                        timeZone: 'UTC',
                    },
                },
            });
            return response.data;
        } catch (error) {
            console.error('Error creating calendar event:', error);
            throw error;
        }
    }

    async updateEvent(eventId, event) {
        try {
            const response = await this.calendar.events.update({
                calendarId: 'primary',
                eventId: eventId,
                resource: {
                    summary: event.title,
                    description: event.description,
                    start: {
                        dateTime: event.start,
                        timeZone: 'UTC',
                    },
                    end: {
                        dateTime: event.end || event.start,
                        timeZone: 'UTC',
                    },
                },
            });
            return response.data;
        } catch (error) {
            console.error('Error updating calendar event:', error);
            throw error;
        }
    }

    async deleteEvent(eventId) {
        try {
            await this.calendar.events.delete({
                calendarId: 'primary',
                eventId: eventId,
            });
            return true;
        } catch (error) {
            console.error('Error deleting calendar event:', error);
            throw error;
        }
    }
}

module.exports = new GoogleCalendarService();
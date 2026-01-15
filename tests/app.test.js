const request = require('supertest');
const app = require('../server');

describe('CredPal API Endpoints', () => {

    describe('GET /health', () => {
        it('should return 200 and healthy status', async () => {
            const res = await request(app).get('/health');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('status', 'healthy');
        });
    });

    describe('GET /status', () => {
        it('should return 200 and running status', async () => {
            const res = await request(app).get('/status');
            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('status', 'running');
            expect(res.body).toHaveProperty('uptime');
            expect(res.body).toHaveProperty('timestamp');
        });
    });

    describe('POST /process', () => {
        it('should process data and return 200', async () => {
            const testData = { userId: 123, action: 'test' };
            const res = await request(app)
                .post('/process')
                .send(testData);

            expect(res.statusCode).toEqual(200);
            expect(res.body).toHaveProperty('message', 'Data processed successfully');
            expect(res.body).toHaveProperty('receivedData');
            expect(res.body.receivedData).toEqual(testData);
        });
    });
});

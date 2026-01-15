const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());


app.get('/health', (req, res) => {
    res.status(200).json({ status: 'healthy' });
});


app.get('/status', (req, res) => {
    res.status(200).json({
        status: 'running',
        uptime: process.uptime(),
        timestamp: new Date()
    });
});


app.post('/process', (req, res) => {
    const data = req.body;

    // simulate some processing
    console.log('Processing data:', data);

    res.status(200).json({
        message: 'Data processed successfully',
        receivedData: data
    });
});


if (require.main === module) {
    app.listen(port, () => {
        console.log(`App listening at http://localhost:${port}`);
    });
}

module.exports = app;

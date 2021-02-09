const express = require('express');
const app = express();

const port = process.env.PORT || 3000;

app.get('/api',(req,res) => {
    res.json('Hello from Node API');
});

app.listen(port,() => {
    console.log(`Listening on port ${port}`);
});
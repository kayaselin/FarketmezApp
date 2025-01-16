const express = require('express');
const bodyParser = require('body-parser');
const userRoutes = require('./src/api/routes/userRoutes');
const institutionRoutes = require('./src/api/routes/institutionRoutes');
const tagRoutes = require('./src/api/routes/tagRoutes');
const locationTagRoutes = require('./src/api/routes/locationTagRoutes');
const campaignRoutes = require('./src/api/routes/campaignRoutes');
const roomRoutes = require('./src/api/routes/roomRoutes');
const cors = require('cors');


//flutter run -d RF8T60K4STH
//192.168.1.109:3000


const app = express();

app.use(cors());
app.use(express.json());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/api/campaign', campaignRoutes);
app.use('/api/locationtags', locationTagRoutes);
app.use('/api/tags', tagRoutes);
app.use('/api/users', userRoutes);
app.use('/api/institutions', institutionRoutes);
app.use('/api/rooms', roomRoutes);


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

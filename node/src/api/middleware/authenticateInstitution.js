const jwt = require('jsonwebtoken');

const authenticateInstitution = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET); // Use a different secret if necessary
        req.institution = decoded; // Add the institution's information to the request object
        next();
    } catch (err) {
        res.status(400).json({ message: 'Invalid token.' });
    }
};

module.exports=authenticateInstitution;
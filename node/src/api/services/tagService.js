const pool = require('../../config/dbConfig');

const getTags = async () => {
    const result = await pool.query('SELECT tag_id, tag_name FROM Tags_TBL');
    return result.rows; // Returns an array of tag objects
};

module.exports = { getTags };




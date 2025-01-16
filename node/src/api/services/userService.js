
const pool = require('../../config/dbConfig');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const updateUserDetails = async ({ userId, username, email, password,}) => {
    const updates = [];
    const values = [];
    console.log("fonk başı");
  
    if (username !== undefined) {
      updates.push(`username = $${updates.length + 1}`);
      values.push(username);
    }
    if (email !== undefined) {
      updates.push(`mail = $${updates.length + 1}`);
      values.push(email);
    }
    if (password !== undefined) {
      updates.push(`password = $${updates.length + 1}`);

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      values.push(hashedPassword);
    }
  
    if (updates.length === 0) {
      throw new Error('No valid fields provided for update');
    }
  
    values.push(userId); // WHERE koşulu için institutionId eklenir
    const query = `
      UPDATE public.users_tbl
      SET ${updates.join(', ')}
      WHERE user_id = $${updates.length + 1}
    `;
    console.log(query);
    try {
      const result = await pool.query(query, values);
      if (result.rowCount > 0) {
        return true; // Güncelleme başarılıysa güncellenen user detaylarını döner
      } else {
        return false; // Eğer user bulunamadıysa veya güncelleme yapılmadıysa
      }
    } catch (err) {
      console.error('Error executing update user details query:', err);
      throw err;
    }
  }

const registerUser = async ({username, email, password}) => {
    try {
        if (!password) {
            throw new Error('Password is required');
        }
        const userExists = await pool.query('SELECT 1 FROM Users_TBL WHERE username = $1 OR mail = $2', [username, email]);
        if (userExists.rowCount > 0) {
            const user = userExists.rows[0];
            if (user.username === username) {
                throw new Error('Username already exists');
            }
            if (user.email === email) {
                throw new Error('Email already exists');
            }
        }
        
        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert new user
        await pool.query('INSERT INTO Users_TBL (username, mail, password) VALUES ($1, $2, $3)', [username, email, hashedPassword]);

        return 'User registered successfully';
    } catch (error) {
        throw error;
    }
};


const loginUser = async ({ emailOrUsername, password }) => {
    
    if (!emailOrUsername || !password) {
        throw { statusCode: 400, message: 'Email/Username and password are required' };
    }

    const userQuery = 'SELECT user_id, password FROM Users_TBL WHERE mail = $1 OR username = $1';
    const result = await pool.query(userQuery, [emailOrUsername]);

    if (result.rowCount === 0) {
        throw { statusCode: 401, message: 'Your email or username is incorrect' };
    }

    // Extract user data
    const userData = result.rows[0];

    const validPassword = await bcrypt.compare(password, userData.password);
    if (!validPassword) {
        throw { statusCode: 401, message: 'Password is incorrect. Please try again' };
    }

    const token = jwt.sign({ userId: userData.user_id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        // Dönüş verilerini oluşturun
    const response = {
        token,
        message: 'Login successful',
        userId: userData.user_id // İstediğiniz diğer bilgileri de ekleyebilirsiniz
    };

    return response;

};

const getUserProfile = async (userId) => {
    const query = `SELECT username, mail FROM Users_TBL WHERE user_id = $1;`;
    const result = await pool.query(query, [userId]);
    return result.rows[0];
};

async function updateUserProfilePhoto(userId, photoUrl) {
    const updateQuery = `
        UPDATE users_tbl SET profile_pic = $1 WHERE user_id = $2
    `;
    await pool.query(updateQuery, [photoUrl, userId]);
}

const isUsernameAvailable = async (username) => {
    const query = `SELECT COUNT(*) FROM Users_TBL WHERE username = $1`;
    const result = await pool.query(query, [username]);
    return result.rows[0].count === '0'; // Return true if username is not found
};

const updateUsername = async (userId, newUsername) => {
    const updateQuery = `UPDATE Users_TBL SET username = $1 WHERE user_id = $2`;
    await pool.query(updateQuery, [newUsername, userId]);
};

const isEmailAvailable = async (email) => {
    const query = `SELECT COUNT(*) FROM users_TBL WHERE mail = $1`;
    const result = await pool.query(query, [email]);
    return result.rows[0].count === '0'; // Return true if email is not found
};

const updateEmail = async (userId, newEmail) => {
    const updateQuery = `UPDATE users_TBL SET mail = $1 WHERE user_id = $2`;
    await pool.query(updateQuery, [newEmail, userId]);
};

const updatePassword = async (userId, newPassword) => {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    const updateQuery = `UPDATE Users_TBL SET password = $1 WHERE user_id = $2`;
    await pool.query(updateQuery, [hashedPassword, userId]);
};
const getRandomCampaigns = async () => {
    const query = `
        SELECT c.campaign_id, c.title, c.description, c.image_url AS photo, i.institution_name
        FROM campaign_tbl AS c
        JOIN institution_tbl AS i ON c.institution_id = i.institution_id
        ORDER BY RANDOM()
        LIMIT 20; 
    `;

    try {
        const { rows } = await pool.query(query);
        return rows;
    } catch (error) {
        console.error('Error in getRandomCampaigns service:', error);
        throw error;
    }
};

const getCampaignById = async (campaignId) => {
    try {
        const query = 'SELECT campaign_id,title,description,image_url FROM campaign_tbl WHERE campaign_id = $1';
        const { rows } = await pool.query(query, [campaignId]);
        return rows.length ? rows[0] : null;
    } catch (error) {
        console.error('Error in getCampaignById service: ', error);
        throw error;
    }
};




module.exports = {getCampaignById,getRandomCampaigns,updateUserDetails,updatePassword,isEmailAvailable,updateEmail,isUsernameAvailable,updateUsername, updateUserProfilePhoto,getUserProfile,registerUser,
    loginUser };







const pool = require('../../config/dbConfig');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');


const updateInstitutionDetails = async ({ institutionId, institutionName, email, password, addressText, phoneNumber }) => {
    const updates = [];
    const values = [];
  
    if (institutionName !== undefined) {
      updates.push(`institution_name = $${updates.length + 1}`);
      values.push(institutionName);
    }
    if (email !== undefined) {
      updates.push(`email = $${updates.length + 1}`);
      values.push(email);
    }
    if (password !== undefined) {
      updates.push(`password = $${updates.length + 1}`);

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      values.push(hashedPassword);
    }
    if (addressText !== undefined) {
      updates.push(`adress_text = $${updates.length + 1}`);
      values.push(addressText);
    }
    if (phoneNumber !== undefined) {
      updates.push(`phone_number = $${updates.length + 1}`);
      values.push(phoneNumber);
    }
  
    if (updates.length === 0) {
      throw new Error('No valid fields provided for update');
    }
  
    values.push(institutionId); // WHERE koşulu için institutionId eklenir
    const query = `
      UPDATE public.institution_tbl
      SET ${updates.join(', ')}
      WHERE institution_id = $${updates.length + 1}
    `;
    console.log(query);
    try {
      const result = await pool.query(query, values);
      if (result.rowCount > 0) {
        return true; // Güncelleme başarılıysa güncellenen kurumun detaylarını döner
      } else {
        return false; // Eğer kurum bulunamadıysa veya güncelleme yapılmadıysa
      }
    } catch (err) {
      console.error('Error executing update institution details query:', err);
      throw err;
    }
  }

const registerInstitution = async ({ institutionName, email, password, phoneNumber, address, locTagId, tags,latitude,longitude }) => {
    // Validate input
    if (!institutionName || !email || !password || !phoneNumber || !address || !locTagId || tags.length === 0 || latitude == null || longitude == null) {
        throw { statusCode: 400, message: 'Missing required fields or no tags selected' };
    }
    

    // Check for existing email in Institution_TBL
    const existingEmail = await pool.query('SELECT 1 FROM Institution_TBL WHERE email = $1', [email]);
    if (existingEmail.rowCount > 0) {
        throw { statusCode: 400, message: 'Email already in use' };
    }

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Start a database transaction
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Insert the new institution
        const insertInstitutionText = 'INSERT INTO Institution_TBL (institution_name, email, password, adress_text, profile_pic, loc_tag_id,phone_number,latitude,longitude ) VALUES ($1, $2, $3, $4, $5, $6,$7,$8,$9) RETURNING institution_id';
        const insertInstitutionValues = [institutionName, email, hashedPassword, address, null, locTagId,phoneNumber,latitude,longitude];
        const newInstitution = await client.query(insertInstitutionText, insertInstitutionValues);

        // Insert tags (additional logic might be required based on your tag handling)
        tags.forEach(async (tagId) => {
            const insertTagText = 'INSERT INTO InstitutionTagLink (institution_id, tag_id) VALUES ($1, $2)';
            await client.query(insertTagText, [newInstitution.rows[0].institution_id, tagId]);
        });

        await client.query('COMMIT');
        return { institutionId: newInstitution.rows[0].institution_id, message: 'Institution registered successfully' };
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};


const loginInstitution = async ({ email, password }) => {
    // Validate input
    if (!email || !password) {
        throw { statusCode: 400, message: 'Email and password are required' };
    }

    // Check for institution in Institution_TBL by email, fetch only necessary columns
    const institutionQuery = 'SELECT institution_id, password FROM institution_tbl WHERE email = $1';
    const result = await pool.query(institutionQuery, [email]);

    if (result.rowCount === 0) {
        throw { statusCode: 401, message: 'Invalid email or password' };
    }

    // Extract institution data
    const institutionData = result.rows[0];

    // Hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const validPassword = await bcrypt.compare(password, institutionData.password);
    if (!validPassword) {
        throw { statusCode: 401, message: 'Invalid email or password'};
    }

    // Institution authenticated, create JWT
    const token = jwt.sign({ institutionId: institutionData.institution_id }, process.env.JWT_SECRET, { expiresIn: '1h' });

    const response = {
        token,
        message: 'Login successful',
        institutionId: institutionData.institution_id 
    };

    return response;
};

const getInstitutionProfile = async (institutionId) => {
    const profileQuery = `
        SELECT i.institution_name, i.adress_text, i.phone_number, i.email,
               array_agg(t.tag_name) as tags
        FROM institution_tbl i
        LEFT JOIN institutiontaglink it ON i.institution_id = it.institution_id
        LEFT JOIN tags_tbl t ON it.tag_id = t.tag_id
        WHERE i.institution_id = $1
        GROUP BY i.institution_id;
    `;

    const result = await pool.query(profileQuery, [institutionId]);
    if (result.rowCount === 0) {
        return null;
    }

    return result.rows[0];
};


const updateInstitutionName = async (institutionId, newName) => {
    const updateQuery = 'UPDATE institution_tbl SET institution_name = $1 WHERE institution_id = $2 RETURNING *';
    const result = await pool.query(updateQuery, [newName, institutionId]);

    if (result.rowCount === 0) {
        return false; // Institution not found
    }

    return true; // Institution name updated
};

const updateInstitutionAddress = async (institutionId, newAddress) => {
    const updateQuery = 'UPDATE institution_tbl SET adress_text = $1 WHERE institution_id = $2 RETURNING *';
    const result = await pool.query(updateQuery, [newAddress, institutionId]);

    if (result.rowCount === 0) {
        return false; // Institution not found
    }

    return true; // Institution address updated
};

const updateInstitutionPhoneNumber = async (institutionId, newPhoneNumber) => {
    const updateQuery = 'UPDATE institution_tbl SET phone_number = $1 WHERE institution_id = $2 RETURNING *';
    const result = await pool.query(updateQuery, [newPhoneNumber, institutionId]);

    if (result.rowCount === 0) {
        return false; // Institution not found
    }

    return true; // Institution phone number updated
};

const checkEmailExists = async (email) => {
    const query = 'SELECT COUNT(*) FROM institution_tbl WHERE email = $1';
    const result = await pool.query(query, [email]);
    return result.rows[0].count > 0;
};

const updateInstitutionEmail = async (institutionId, newEmail) => {
    const updateQuery = 'UPDATE institution_tbl SET email = $1 WHERE institution_id = $2 RETURNING *';
    const result = await pool.query(updateQuery, [newEmail, institutionId]);

    if (result.rowCount === 0) {
        return false; // Institution not found
    }

    return true; // Institution email updated
};


const updateInstitutionPassword = async (institutionId, newPassword) => {
    // Encrypt the new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    const updateQuery = 'UPDATE institution_tbl SET password = $1 WHERE institution_id = $2 RETURNING *';
    const result = await pool.query(updateQuery, [hashedPassword, institutionId]);

    if (result.rowCount === 0) {
        return false; // Institution not found
    }

    return true; // Institution password updated
};

const getInstitutionPhotos = async (institutionId) => {
    const query = `SELECT photo_byte, photo_id FROM photos_TBL WHERE institution_id = $1;`;
    const result = await pool.query(query, [institutionId]);
    return result.rows;
};

const getInstitutionPhotosAll = async () => {
    const query = `SELECT photo_byte FROM photos_TBL;`;
    const result = await pool.query(query, []);
    return result.rows;
};


async function addInstitutionPhoto(institutionId, photo_byte) {
    const query = `
        INSERT INTO public.photos_tbl (institution_id, photo_byte, photo_type)
        VALUES ($1, $2, 'Other');
    `;
    const values = [institutionId, photo_byte];
    
    try {
        const result = await pool.query(query, values);
        return 1;//result.rows[0].photo_id; // Başarıyla eklenen fotoğrafın id'sini döndürür
    } catch (error) {
        throw error; // Hata durumunda hatayı çağrı yapan fonksiyona iletir
    }
}

const deleteInstitutionPhoto = async (photoId) => {
    const deleteQuery = `DELETE FROM photos_TBL WHERE photo_id = $1;`;
    const result = await pool.query(deleteQuery, [photoId]);
    return result.rowCount > 0;
};
const getInstitutionDetails = async (institutionId) => {//kurumun kullanıcı tarafından görüntülenmesi
    // Fetch basic institution details including average rating
    const institutionQuery = `
        SELECT institution_name, email, adress_text, profile_pic, phone_number, average_rating
        FROM institution_tbl 
        WHERE institution_id = $1;
    `;
    const institutionResult = await pool.query(institutionQuery, [institutionId]);
    const institutionDetails = institutionResult.rows[0];

    if (!institutionDetails) {
        return null;  // Institution not found
    }

    // Fetch tags
    const tagsQuery = `
        SELECT t.tag_name 
        FROM tags_tbl t
        INNER JOIN institutiontaglink it ON t.tag_id = it.tag_id
        WHERE it.institution_id = $1;
    `;
    const tagsResult = await pool.query(tagsQuery, [institutionId]);

    // Fetch location tag
    const locationTagQuery = `
        SELECT lt.district_name 
        FROM loc_tags_tbl lt
        WHERE lt.loc_tag_id = (SELECT loc_tag_id FROM institution_tbl WHERE institution_id = $1);
    `;
    const locationTagResult = await pool.query(locationTagQuery, [institutionId]);

    // Fetch photos
    const photosQuery = `
        SELECT photo_url
        FROM photos_tbl 
        WHERE institution_id = $1;
    `;
    const photosResult = await pool.query(photosQuery, [institutionId]);

    // Fetch campaigns
    const campaignsQuery = `
        SELECT campaign_id,title, description, image_url 
        FROM campaign_tbl 
        WHERE institution_id = $1;
    `;
    const campaignsResult = await pool.query(campaignsQuery, [institutionId]);

    return {
        basicInfo: institutionDetails,
        tags: tagsResult.rows,
        locationTag: locationTagResult.rows[0] ? locationTagResult.rows[0].district_name : null,
        photos: photosResult.rows,
        campaigns: campaignsResult.rows
    };
};


const searchInstitutions = async (searchQuery, tags, locationTags, random = false) => {
    let baseQuery = `
        SELECT i.institution_id, i.institution_name, i.average_rating, lt.district_name, i.profile_pic
        FROM institution_tbl i
        LEFT JOIN loc_tags_tbl lt ON i.loc_tag_id = lt.loc_tag_id
    `;

    let queryParams = [];
    let paramCount = 1;

    if (tags && tags.length > 0) {
        // Add joins for each tag
        tags.forEach((tag, index) => {
            baseQuery += `
                INNER JOIN institutiontaglink itl${index} ON i.institution_id = itl${index}.institution_id
                INNER JOIN tags_tbl t${index} ON itl${index}.tag_id = t${index}.tag_id
            `;
        });

        // Add WHERE clause for each tag
        baseQuery += ' WHERE ';
        baseQuery += tags.map(tag => {
            return `(t${tags.indexOf(tag)}.tag_name ILIKE $${paramCount++})`;
        }).join(' AND ');

        queryParams.push(...tags.map(tag => `%${tag}%`));
    }

    // Adding search query filter
    if (searchQuery) {
        baseQuery += (paramCount > 1 ? ' AND ' : ' WHERE ') + `i.institution_name ILIKE '%' || $${paramCount} || '%'`;
        queryParams.push(searchQuery);
        paramCount++;
    }

    // Handling multiple location tags
    if (locationTags && locationTags.length > 0) {
        baseQuery += (paramCount > 1 ? ' AND ' : ' WHERE ') + `lt.district_name IN (${locationTags.map(_ => `$${paramCount++}`).join(', ')})`;
        queryParams.push(...locationTags);
    }

    // Handle random selection
    if (random) {
        baseQuery += ` ORDER BY RANDOM() LIMIT 1`;
    } else {
        baseQuery += ` ORDER BY i.average_rating DESC`;
    }

    console.log("SQL Query:", baseQuery); // Debugging
    console.log("Query Parameters:", queryParams); // Debugging

    const result = await pool.query(baseQuery, queryParams);
    return result.rows;
};
async function updateInstitutionProfilePhoto(institutionId, photoLink) {
    const updateQuery = `
        UPDATE institution_tbl SET profile_pic = $1 WHERE institution_id = $2
    `;
    await pool.query(updateQuery, [photoLink, institutionId]);
}

const getInstitutions = async () => {
    console.log('Selecting institutions with their tags...');
    const result = await pool.query(`
        SELECT i.institution_id, i.institution_name, i.email, i.password, i.adress_text, i.profile_pic, i.loc_tag_id, i.phone_number, i.average_rating, i.latitude, i.longitude, STRING_AGG(t.tag_name, ', ') AS tag_names 
        FROM public.institution_tbl i 
        JOIN public.institutiontaglink itl ON i.institution_id = itl.institution_id 
        JOIN public.tags_tbl t ON itl.tag_id = t.tag_id 
        GROUP BY i.institution_id, i.institution_name, i.email, i.password, i.adress_text, i.profile_pic, i.loc_tag_id, i.phone_number, i.average_rating, i.latitude, i.longitude
    `);
    return result.rows; // Veritabanından çekilen kurumların ve ilişkilendirilmiş etiket isimlerinin dizisi olarak döndürülür
};

const getInstitutionCampaigns = async (institutionId) => {
    const query = `
        SELECT institution_id, campaign_id, title, description, image_url AS photo
        FROM campaign_tbl
        WHERE institution_id = $1;
    `;
    try {
        const result = await pool.query(query, [institutionId]);
        return result.rows; // Returns an array of campaigns
    } catch (error) {
        console.error('Error in getInstitutionCampaigns:', error);
        throw error;
    }
};

const deleteCampaign = async (campaignId) => {
    const query = 'DELETE FROM campaign_tbl WHERE campaign_id = $1';
    
    try {
        const result = await pool.query(query, [campaignId]);
        if (result.rowCount === 0) {
            throw new Error('Campaign not found or already deleted');
        }
    } catch (error) {
        console.error('Error in deleteCampaign service:', error);
        throw error;
    }
};

module.exports = {deleteCampaign,getInstitutionCampaigns,updateInstitutionDetails, getInstitutionPhotosAll,getInstitutions,updateInstitutionProfilePhoto,searchInstitutions,getInstitutionDetails,deleteInstitutionPhoto,getInstitutionPhotos,addInstitutionPhoto, updateInstitutionPassword,checkEmailExists,updateInstitutionEmail ,updateInstitutionPhoneNumber,updateInstitutionAddress,updateInstitutionName,getInstitutionProfile,registerInstitution,loginInstitution};

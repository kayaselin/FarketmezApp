const pool = require('../../config/dbConfig');
const selectTagForRoom = async (roomId, userId, tagId) => {
    const client = await pool.connect();
    try {
        const insertQuery = `
            INSERT INTO room_tags_tbl (room_id, user_id, tag_id, confirmed)
            VALUES ($1, $2, $3, TRUE)
            ON CONFLICT (room_id, user_id) DO UPDATE
            SET tag_id = EXCLUDED.tag_id, confirmed = TRUE;
        `;
        await client.query(insertQuery, [roomId, userId, tagId]);
    } finally {
        client.release();
    }
};
const areAllUsersReady = async (roomId) => {
    const client = await pool.connect();
    try {
        const checkQuery = `
            SELECT EXISTS (
                SELECT 1
                FROM room_tags_tbl
                WHERE room_id = $1 AND confirmed = TRUE
                GROUP BY room_id
                HAVING COUNT(*) = (SELECT COUNT(*) FROM room_participants_tbl WHERE room_id = $1)
            ) AS all_confirmed;
        `;
        const result = await client.query(checkQuery, [roomId]);
        return result.rows[0].all_confirmed;
    } finally {
        client.release();
    }
};


const getInstitutionsByTagAndLocation = async (roomId) => {
    const client = await pool.connect();
    try {
        // Begin transaction
        await client.query('BEGIN');

        // Step 1: Get the most selected tag in the room
        const mostSelectedTagQuery = `
            SELECT tag_id
            FROM room_tags_tbl
            WHERE room_id = $1
            GROUP BY tag_id
            ORDER BY COUNT(*) DESC
            LIMIT 1;
        `;
        const tagResult = await client.query(mostSelectedTagQuery, [roomId]);
        if (tagResult.rowCount === 0) {
            throw new Error("No tags selected in this room.");
        }
        const mostSelectedTagId = tagResult.rows[0].tag_id;

        // Fetch the tag name for the most selected tag
        const tagNameQuery = `SELECT tag_name FROM tags_tbl WHERE tag_id = $1;`;
        const tagNameResult = await client.query(tagNameQuery, [mostSelectedTagId]);
        if (tagNameResult.rowCount === 0) {
            throw new Error("Tag not found.");
        }
        const tagName = tagNameResult.rows[0].tag_name; // The name of the most selected tag

        // Step 2: Get the room's location tag
        const locationTagQuery = `SELECT loc_tag_id FROM rooms_tbl WHERE room_id = $1;`;
        const locationResult = await client.query(locationTagQuery, [roomId]);
        if (locationResult.rowCount === 0) {
            throw new Error("Room not found.");
        }
        const locationTagId = locationResult.rows[0].loc_tag_id;

        // Step 3: Fetch institutions by most selected tag and location tag
        const institutionsQuery = `
            SELECT i.institution_id, i.institution_name, i.adress_text, i.phone_number
            FROM institution_tbl i
            INNER JOIN institutiontaglink it ON i.institution_id = it.institution_id
            WHERE it.tag_id = $1 AND i.loc_tag_id = $2;
        `;
        const institutions = await client.query(institutionsQuery, [mostSelectedTagId, locationTagId]);

        // Commit transaction
        await client.query('COMMIT');

        return {
            tagName: tagName, // Return the tag name separately
            institutions: institutions.rows // List of institutions
        };
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};



const getRandomInstitutionByTagAndLocation = async (roomId) => {
    const client = await pool.connect();
    try {
        // Begin transaction
        await client.query('BEGIN');

        // Step 1: Get the most selected tag in the room
        const mostSelectedTagQuery = `
            SELECT tag_id
            FROM room_tags_tbl
            WHERE room_id = $1
            GROUP BY tag_id
            ORDER BY COUNT(*) DESC
            LIMIT 1;
        `;
        const tagResult = await client.query(mostSelectedTagQuery, [roomId]);
        if (tagResult.rowCount === 0) {
            throw new Error("No tags selected in this room.");
        }
        const mostSelectedTagId = tagResult.rows[0].tag_id;

        // Step 2: Get the room's location tag
        const locationTagQuery = `SELECT loc_tag_id FROM rooms_tbl WHERE room_id = $1;`;
        const locationResult = await client.query(locationTagQuery, [roomId]);
        if (locationResult.rowCount === 0) {
            throw new Error("Room not found.");
        }
        const locationTagId = locationResult.rows[0].loc_tag_id;

        // Step 3: Fetch a random institution by most selected tag and location tag
        const randomInstitutionQuery = `
            SELECT i.institution_id, i.institution_name, i.loc_tag_id,i.adress_text,i.phone_number
            FROM institution_tbl i
            INNER JOIN institutiontaglink it ON i.institution_id = it.institution_id
            WHERE it.tag_id = $1 AND i.loc_tag_id = $2
            ORDER BY RANDOM()
            LIMIT 1;
        `;
        const institution = await client.query(randomInstitutionQuery, [mostSelectedTagId, locationTagId]);

        // Commit transaction
        await client.query('COMMIT');

        return institution.rows[0]; // Single random institution
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};


const createRoom = async (maxParticipants, locationTagId, userId) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Yeni odayı rooms_tbl tablosuna ekle
        const insertRoomText = `
            INSERT INTO rooms_tbl (max_participants, loc_tag_id, created_at, expires_at)
            VALUES ($1, $2, NOW(), NOW() + interval '15 minute')
            RETURNING room_id;
        `;
        const roomResult = await client.query(insertRoomText, [maxParticipants, locationTagId]);
        const roomId = roomResult.rows[0].room_id;

        // Oda oluşturucusunu otomatik olarak katılımcı olarak ekle ve rolünü 'admin' olarak belirle
        const insertParticipantText = `
            INSERT INTO room_participants_tbl (room_id, user_id, role, joined_at)
            VALUES ($1, $2, 'admin', NOW());
        `;
        await client.query(insertParticipantText, [roomId, userId]);

        await client.query('COMMIT');
        client.release();

        return roomId; // Yeni oluşturulan odanın ID'sini döndür
    } catch (error) {
        await client.query('ROLLBACK');
        client.release();
        throw error; // Hata oluşursa yeniden fırlat
    }
};

const joinRoom = async (roomId, userId) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Oda varlığını, katılımcı sayısını ve süresinin dolup dolmadığını kontrol et
        // Aynı zamanda loc_tag_id'yi de al
        const roomCheckQuery = `
            SELECT r.max_participants, COUNT(p.user_id) AS current_participants, r.expires_at, NOW() > r.expires_at AS is_expired, r.loc_tag_id
            FROM rooms_tbl r
            LEFT JOIN room_participants_tbl p ON r.room_id = p.room_id
            WHERE r.room_id = $1
            GROUP BY r.room_id, r.max_participants, r.expires_at, r.loc_tag_id;
        `;
        const roomCheckResult = await client.query(roomCheckQuery, [roomId]);
        if (roomCheckResult.rows.length === 0) throw new Error("Room does not exist.");

        const { max_participants, current_participants, is_expired, loc_tag_id } = roomCheckResult.rows[0];

        if (is_expired) throw new Error("Room has expired and cannot be joined.");

        if (current_participants >= max_participants) throw new Error("Room is full.");

        // Yeni katılımcıyı participant rolüyle ekle
        const insertParticipantQuery = `
            INSERT INTO room_participants_tbl (room_id, user_id, role, joined_at)
            VALUES ($1, $2, 'participant', NOW());
        `;
        await client.query(insertParticipantQuery, [roomId, userId]);

        // loc_tag_id kullanarak district_name'i al
        const districtQuery = `
            SELECT district_name
            FROM loc_tags_tbl
            WHERE loc_tag_id = $1;
        `;
        const districtResult = await client.query(districtQuery, [loc_tag_id]);
        if (districtResult.rows.length === 0) throw new Error("Location tag not found.");

        const { district_name } = districtResult.rows[0];

        await client.query('COMMIT');

        // district_name ile birlikte response döndür
        return { success: true, district_name };

    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};


const updateRoomStatus = async (roomId, newStatus) => {
    const client = await pool.connect();
    try {
        const updateQuery = `
            UPDATE rooms_tbl
            SET status = $1
            WHERE room_id = $2;
        `;
        await client.query(updateQuery, [newStatus, roomId]);
    } catch (error) {
        console.error('Error updating room status:', error);
        throw error;
    } finally {
        client.release();
    }
};

const isRoomFullAndAllUsersReady = async (roomId) => {
    const client = await pool.connect();
    try {
        // Oda doluluğunu kontrol et
        const roomQuery = `
            SELECT max_participants
            FROM rooms_tbl
            WHERE room_id = $1;
        `;
        const { rows: roomRows } = await client.query(roomQuery, [roomId]);
        if (roomRows.length === 0) {
            throw new Error("Room does not exist.");
        }
        const maxParticipants = roomRows[0].max_participants;

        const participantsQuery = `
            SELECT COUNT(*) AS current_participants
            FROM room_participants_tbl
            WHERE room_id = $1;
        `;
        const { rows: participantRows } = await client.query(participantsQuery, [roomId]);
        const currentParticipants = parseInt(participantRows[0].current_participants);

        // Tüm kullanıcıların tag seçimlerini tamamladığını kontrol et
        const tagSelectionQuery = `
            SELECT COUNT(DISTINCT user_id) AS users_confirmed
            FROM room_tags_tbl
            WHERE room_id = $1 AND confirmed = TRUE;
        `;
        const { rows: tagSelectionRows } = await client.query(tagSelectionQuery, [roomId]);
        const usersConfirmed = parseInt(tagSelectionRows[0].users_confirmed);

        return currentParticipants === maxParticipants && usersConfirmed === currentParticipants;
    } catch (error) {
        console.error('Error checking room full and user readiness:', error);
        throw error;
    } finally {
        client.release();
    }
};

const markRoomAsFinished = async (roomId) => {
    const isFullAndReady = await isRoomFullAndAllUsersReady(roomId);
    if (isFullAndReady) {
        // Oda dolu ve tüm kullanıcılar hazır, `is_finished` durumunu güncelle
        const client = await pool.connect();
        try {
            const updateQuery = `
                UPDATE rooms_tbl
                SET is_finished = TRUE
                WHERE room_id = $1;
            `;
            await client.query(updateQuery, [roomId]);
        } catch (error) {
            console.error('Error marking room as finished:', error);
            throw error;
        } finally {
            client.release();
        }
    }
    return isFullAndReady;
};

const checkRoomFinishedStatus = async (roomId) => {
    const client = await pool.connect();
    try {
        const query = `
            SELECT is_finished
            FROM rooms_tbl
            WHERE room_id = $1;
        `;
        const { rows } = await client.query(query, [roomId]);
        
        if (rows.length > 0) {
            return rows[0].is_finished;
        } else {
            throw new Error("Room not found.");
        }
    } catch (error) {
        throw error;
    } finally {
        client.release();
    }
};



module.exports={
    checkRoomFinishedStatus,
    markRoomAsFinished,
    isRoomFullAndAllUsersReady,
    updateRoomStatus ,
    areAllUsersReady,
    selectTagForRoom,
    getRandomInstitutionByTagAndLocation,
    createRoom,
    joinRoom,
    getInstitutionsByTagAndLocation

}
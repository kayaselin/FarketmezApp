const institutionService = require('../services/institutionService');
const pool = require('../../config/dbConfig');
const bcrypt = require('bcryptjs');
const campaignService = require('../services/campaignService');
const azureBlobService = require('../services/azureBlobService');


exports.updateInstitution = async (req, res) => {
    const { institutionId, institutionName, email, password, addressText, phoneNumber } = req.body;
  
    try {
      const result = await institutionService.updateInstitutionDetails({
        institutionId,
        institutionName,
        email,
        password,
        addressText,
        phoneNumber
      });
  
      if (result) {
        res.send('Institution updated successfully.');
      } else {
        res.status(400).send('Update failed.');
      }
    } catch (error) {
      console.error('Error updating institution:', error);
      res.status(500).send('Server error.');
    }
};


exports.registerInstitution = async (req, res) => {
    try {
        const result = await institutionService.registerInstitution(req.body);
        res.status(201).json(result);
    } catch (err) {
        console.error(err.message);
        res.status(err.statusCode || 500).send(err.message);
    }
};


exports.loginInstitution = async (req, res) => {
    try {
        const token = await institutionService.loginInstitution(req.body);
        res.json({ token });
    } catch (err) {
        console.error(err.message);
        res.status(err.statusCode || 500).send(err.message);
    }
};

exports.getInstitutionProfile = async (req, res) => {
    try {
        const institutionId = req.body.institutionId; // Extracted from the authenticated user

        if (!institutionId) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const profile = await institutionService.getInstitutionProfile(institutionId);
        res.json(profile);
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ message: 'Server error' });
    }
};



exports.uploadProfilePhoto = async (req, res) => {
    try {
        const institutionId = req.user.institutionId;
        const file = req.file;

        if (!file) {
            return res.status(400).send('No file uploaded');
        }

        const containerName = 'farketmez'; // Replace with your container name
        const fileUrl = await azureBlobService.uploadFileToBlob(file, containerName);
        await institutionService.updateInstitutionProfilePhoto(institutionId, fileUrl);

        res.status(200).json({ message: 'Profile photo updated successfully', url: fileUrl });
    } catch (err) {
        console.error('Error in uploadProfilePhoto:', err);
        res.status(500).send('Server error');
    }
};


exports.updateInstitutionName = async (req, res) => {
    try {
        const institutionId = req.user.institutionId;
        const { newName } = req.body;

        if (!newName) {
            return res.status(400).json({ message: 'New name is required' });
        }

        const updated = await institutionService.updateInstitutionName(institutionId, newName);

        if (!updated) {
            return res.status(404).json({ message: 'Institution not found' });
        }

        res.json({ message: 'Institution name updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.updateInstitutionAddress = async (req, res) => {
    try {
        const institutionId = req.user.institutionId;
        const { newAddress } = req.body;

        if (!newAddress) {
            return res.status(400).json({ message: 'New address is required' });
        }

        const updated = await institutionService.updateInstitutionAddress(institutionId, newAddress);

        if (!updated) {
            return res.status(404).json({ message: 'Institution not found' });
        }

        res.json({ message: 'Institution address updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.updateInstitutionPhoneNumber = async (req, res) => {
    try {
        const institutionId = req.user.institutionId;
        const { newPhoneNumber } = req.body;

        if (!newPhoneNumber) {
            return res.status(400).json({ message: 'New phone number is required' });
        }

        const updated = await institutionService.updateInstitutionPhoneNumber(institutionId, newPhoneNumber);

        if (!updated) {
            return res.status(404).json({ message: 'Institution not found' });
        }

        res.json({ message: 'Institution phone number updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.updateInstitutionEmail = async (req, res) => {
    try {
        const institutionId = req.user.institutionId;
        const { newEmail } = req.body;

        if (!newEmail) {
            return res.status(400).json({ message: 'New email is required' });
        }

        const emailExists = await institutionService.checkEmailExists(newEmail);
        if (emailExists) {
            return res.status(409).json({ message: 'This email is already in use' });
        }

        const updated = await institutionService.updateInstitutionEmail(institutionId, newEmail);

        if (!updated) {
            return res.status(404).json({ message: 'Institution not found' });
        }

        res.json({ message: 'Institution email updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};
exports.updateInstitutionPassword = async (req, res) => {
    try {
        const institutionId = req.user.institutionId;
        const { newPassword } = req.body;

        if (!newPassword) {
            return res.status(400).json({ message: 'New password is required' });
        }

        const updated = await institutionService.updateInstitutionPassword(institutionId, newPassword);

        if (!updated) {
            return res.status(404).json({ message: 'Institution not found' });
        }

        res.json({ message: 'Institution password updated successfully' });
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getPhotos = async (req, res) => {
    try {
        // URL path'inden institutionId'yi al
        const { institutionId } = req.params;
        
        // institutionId kullanarak fotoğrafları getir
        const photos = await institutionService.getInstitutionPhotos(institutionId);
        
        res.json(photos);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};


exports.getPhotosAll = async (req, res) => {
    try {
        const photos = await institutionService.getInstitutionPhotosAll();
        res.json(photos);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.uploadInstitutionPhoto = async (req, res) => {
    try {
        const { institutionId } = req.params; // URL'den institutionId'yi alır
        const { photo_byte } = req.body; // İstek gövdesinden base64 olarak kodlanmış fotoğrafı alır

        // Burada, addInstitutionPhoto fonksiyonunu çağırırken institutionId ve photo_byte parametrelerini gönderiyoruz.
        // Bu fonksiyonun tanımı şu an için yok, ancak sonraki adımlarda sizinle paylaşacağım.
        await institutionService.addInstitutionPhoto(institutionId, photo_byte);

        res.status(200).json({ message: 'Photo uploaded successfully' });
    } catch (err) {
        console.error('Error in uploadInstitutionPhoto:', err);
        res.status(500).send('Server error');
    }
};

exports.deletePhoto = async (req, res) => {
    try {
        const { photoId } = req.params;

        // Here, add logic to check if the photo belongs to the institution
        const isDeleted = await institutionService.deleteInstitutionPhoto(photoId);
        
        if (isDeleted) {
            res.status(200).send('Photo deleted successfully');
        } else {
            res.status(404).send('Photo not found or unauthorized');
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};


exports.validateCampaignCode = async (req, res) => {
    try {
        const { campaignId, code } = req.body;
        const userId = req.user.userId; // Assuming the user ID of the institution is needed
        const isValid = await campaignService.validateCode(campaignId, code, userId);

        if (isValid) {
            res.send('Campaign code validated successfully');
        } else {
            res.status(400).send('Invalid or expired code');
        }
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.deleteCampaign = async (req, res) => {
    const { campaignId } = req.params; // Extract campaignId from the route parameter

    try {
        await institutionService.deleteCampaign(campaignId);
        res.status(200).json({ message: 'Campaign deleted successfully' });
    } catch (error) {
        console.error('Error deleting campaign:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};



exports.createCampaign = async (req, res) => {
    const { institutionId, title, description, base64Image } = req.body; // Example assumes institutionId is provided in the body

    try {
        const campaign = await campaignService.createCampaign({
            institutionId,
            title,
            description,
            base64Image
        });

        res.status(201).json({
            message: 'Campaign created successfully',
            campaignId: campaign.campaign_id
        });
    } catch (error) {
        console.error('Error in createCampaign:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
exports.getInstitutionCampaigns = async (req, res) => {
    const { institutionId } = req.params; // Get institution ID from URL parameters

    try {
        const campaigns = await institutionService.getInstitutionCampaigns(institutionId);

        if (campaigns.length > 0) {
            res.status(200).json(campaigns);
        } else {
            res.status(404).json({ message: 'No campaigns found for this institution.' });
        }
    } catch (error) {
        console.error('Error fetching institution campaigns:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
exports.getCampaignStatistics = async (req, res) => {
    try {
        const institutionId = req.user.institutionId; // Extracted from the authenticated institution

        const statistics = await campaignService.getCampaignStatistics(institutionId);

        res.json(statistics);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
};

exports.getInstitutions = async (req, res) => {
    try {
        const Institutions = await institutionService.getInstitutions();
        console.log('Request received:', res.body);
        res.json(Institutions);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching Institution' });
    }
};



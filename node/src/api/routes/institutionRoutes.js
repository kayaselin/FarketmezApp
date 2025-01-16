const express = require('express');
const router = express.Router();
const institutionController = require('../controllers/institutionController');
const campaignController = require('../controllers/campaignController');
const authenticate = require('../middleware/authenticate');
const multer = require('multer');
const upload = multer({ storage: multer.memoryStorage() }); 

router.post('/register', institutionController.registerInstitution);
router.post('/login', institutionController.loginInstitution);
router.post('/profile',institutionController.getInstitutionProfile);  
router.post('/upload-photo', authenticate,upload.single('profilePhoto'), institutionController.uploadProfilePhoto);
router.put('/update-name/',authenticate, institutionController.updateInstitutionName);
router.put('/update-address/', authenticate,institutionController.updateInstitutionAddress);
router.put('/update-phone/',authenticate, institutionController.updateInstitutionPhoneNumber);
router.put('/update-email/', authenticate,institutionController.updateInstitutionEmail);
router.put('/update-password/',authenticate, institutionController.updateInstitutionPassword);
  
router.put('/update-institution', institutionController.updateInstitution);
  

router.get('/photos/:institutionId', institutionController.getPhotos);
router.get('/photosall', institutionController.getPhotosAll);
router.post('/photos/upload/:institutionId', upload.single('photo'), institutionController.uploadInstitutionPhoto);
router.delete('/photos/:photoId', institutionController.deletePhoto);
router.post('/campaigns/validate-code', authenticate, institutionController.validateCampaignCode);//kod onaylama
router.get('/my-campaigns', authenticate, institutionController.getInstitutionCampaigns);
router.get('/campaigns/statistics', authenticate, institutionController.getCampaignStatistics);
router.get('/', institutionController.getInstitutions);
router.post('/create-campaign', upload.single('campaign-photo'),institutionController.createCampaign);//kampanya oluştur
router.get('/campaigns/:institutionId', institutionController.getInstitutionCampaigns);
router.delete('/delete-campaign/:campaignId', institutionController.deleteCampaign);
router.post('/campaigns/validateCode', campaignController.validateCampaignCode);//önemsiz
router.post('/campaigns/approveCode', campaignController.approveCampaignCode);//önemsiz
router.post('/campaigns/approveCodes', campaignController.approveCampaignCodes);//kod approvelama
router.post('/stats', campaignController.getCampaignStats);//kurum kampanya istatistikleri görüntüleme

module.exports = router;

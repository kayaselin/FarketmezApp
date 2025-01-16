const QRCode = require('qrcode');

const generate = async () => {
    // Example: Generating a QR code from text. You might want to include more specific data.
    try {
        const qrCodeData = 'Some data for the QR code'; // This should be unique per campaign
        return await QRCode.toDataURL(qrCodeData);
    } catch (err) {
        console.error(err);
        throw new Error('Failed to generate QR code');
    }
};

module.exports = {
    generate,
};

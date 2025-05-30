const mongoose = require('mongoose');

const videoSchema = new mongoose.Schema({
    name: { type: String, required: true },
    path: { type: String, required: true }
}, { timestamps: true });

module.exports = mongoose.model('Video', videoSchema);
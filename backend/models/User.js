const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    name: String,
    email: String,
    password: String // image path ကိုသိမ်းမယ့် field
});

module.exports = mongoose.model('User', UserSchema);
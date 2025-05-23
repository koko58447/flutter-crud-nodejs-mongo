const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const userRoutes = require('./routes/userRoutes');
const supplierRoutes = require('./routes/supplierRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const path = require('path');
const productRoutes = require('./routes/productRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const videoRoutes = require('./routes/videoRoutes');


const app = express();
app.use(cors());
app.use(express.json());


// uploads ဖိုဒါကို static အဖြစ် serve လုပ်ပေးတာ // image ပြရန်
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// MongoDB Connection
mongoose.connect('mongodb://localhost:27017/crud_flutter', {
    useNewUrlParser: true,
    useUnifiedTopology: true
}).then(() => console.log("MongoDB connected"))
  .catch(err => console.error(err));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/suppliers', supplierRoutes);
app.use('/api/uploads', uploadRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categorys', categoryRoutes);
app.use('/api/videos', videoRoutes);

//port and ip config

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});



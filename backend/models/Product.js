const mongoose = require('mongoose');

// Define the Product schema
const productSchema = new mongoose.Schema(
    {
        name: { type: String, required: true },
        price: { type: Number, required: true }, // Use Number instead of Double
        qty: { type: Number, required: true },  // Use Number instead of Int
        supplierid: { type: mongoose.Schema.Types.ObjectId,
            ref: 'Supplier' },
        categoryid: { type: mongoose.Schema.Types.ObjectId,
            ref: 'Category' },
    },
    { timestamps: true }
);

// Export the Product model
module.exports = mongoose.model('Product', productSchema);
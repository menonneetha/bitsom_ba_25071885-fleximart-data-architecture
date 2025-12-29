// mongodb_operations.js - Task 2.2 MongoDB Implementation (10 marks)
// Run with: mongosh < mongodb_operations.js
// Files must be in SAME folder: products_catalog.json + this file

// Operation 1: Load Data (1 mark)
// Import provided JSON file into 'products' collection
mongoimport --db ecommerce --collection products --file products_catalog.json --jsonArray

// NOTE: Run Operation1 separately: mongoimport --db ecommerce --collection products --file products_catalog.json --jsonArray
// Then run: mongosh < this_file.js

use ecommerce  

// Operation 2: Basic Query (2 marks)
// Find Electronics products < 50000, return only name, price, stock
db.products.find(
  { category: "Electronics", price: { $lt: 50000 } },
  { name: 1, price: 1, stock: 1, _id: 0 }
).pretty()

// Operation 3: Review Analysis (2 marks)
// Products with average rating >= 4.0 using aggregation pipeline 
db.products.aggregate([
  { $match: { reviews: { $exists: true, $ne: [] } } },
  { 
    $addFields: { 
      avgRating: { $avg: "$reviews.rating" } 
    } 
  },
  { $match: { avgRating: { $gte: 4.0 } } },
  { 
    $project: { 
      name: 1, 
      avgRating: { $round: ["$avgRating", 2] }, 
      _id: 0 
    } 
  }
])

// Operation 4: Update Operation (2 marks)
// Add new review to ELEC001 using $push to reviews array
db.products.updateOne(
  { product_id: "ELEC001" },
  { 
    $push: {
      reviews: {
        user_id: "U999",
        username: "NewReviewer",
        rating: 4,
        comment: "Good value",
        date: new ISODate()
      }
    }
  }
)

// Operation 5: Complex Aggregation (3 marks)
// Average price by category, sorted descending with product count
db.products.aggregate([
  {
    $group: {
      _id: "$category",
      avg_price: { $avg: "$price" },
      product_count: { $sum: 1 }
    }
  },
  { $sort: { avg_price: -1 } },
  {
    $project: {
      category: "$_id",
      avg_price: { $round: ["$avg_price", 2] },
      product_count: 1,
      _id: 0
    }
  }
])




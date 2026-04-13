// Web framework for the API server.
const express = require("express");

// Create the Express application.
const app = express();
// Resolve the listening port (default 3000).
const port = process.env.PORT || 3000;

// In-memory list of quotes.
const quotes = [
  "Simplicity is the soul of efficiency.",
  "Make it work, make it right, make it fast.",
  "In theory, there is no difference between theory and practice. In practice, there is.",
  "The best way to predict the future is to invent it.",
  "Quality is not an act, it is a habit."
];

// Quote endpoint returns a random quote.
app.get("/quote", (req, res) => {
  const quote = quotes[Math.floor(Math.random() * quotes.length)];
  res.json({ quote });
});

// Health endpoint for load balancer and probes.
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

// Start the HTTP server.
app.listen(port, () => {
  console.log(`Quote API listening on port ${port}`);
});

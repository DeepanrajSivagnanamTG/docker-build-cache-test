const express = require("express");
const axios = require("axios");
const _ = require("lodash");

const app = express();
const PORT = 3000;

// Simple health route
app.get("/health", (req, res) => {
  res.send("OK");
});

// Main route
app.get("/", async (req, res) => {
  try {
    const response = await axios.get("https://api.github.com");

    // Use lodash just to ensure dependency is used
    const headers = _.pick(response.headers, ["content-type", "date"]);

    res.json({
      message: "Docker cache test running 🚀",
      github_status: response.status,
      headers: headers,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error("Error fetching GitHub API:", error.message);

    res.status(500).json({
      message: "Error occurred",
      error: error.message
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

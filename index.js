const express = require("express");
const axios = require("axios");
const _ = require("lodash");

const app = express();
const PORT = 3000;

app.get("/", async (req, res) => {
  const response = await axios.get("https://api.github.com");
  res.send("Docker cache test running 🚀");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
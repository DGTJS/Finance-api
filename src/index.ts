import process from "node:process";
import express from "express";
import { pool } from "./database/postgres/client.js";

process.loadEnvFile?.(".env");

const app = express();

app.listen(3000, async () => {
  console.log("Server running on port 3000");
  const client = await pool.connect();
  if (client) {
    console.log("Connected to database");
    client.release();
  } else {
    console.log("Failed to connect to database");
  }
});

app.get("/", (req, res) => {
  res.send("Hello World!");
});

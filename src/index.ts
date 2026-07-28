import process from "node:process";
import express from "express";
import { PostgresHelper } from "./database/postgres/helper.js";

process.loadEnvFile?.(".env");

const app = express();

app.listen(3000, async () => {
  console.log("Server running on port 3000");
  const client = await PostgresHelper.query("SELECT * FROM pg_database WHERE datname = $1", [process.env.DATABASE_NAME]);
  if (client) {
    console.log("Connected to database");
  } else {
    console.log("Failed to connect to database");
  }
});

app.get("/", async (req, res) => {
  const result = await PostgresHelper.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
  res.send(JSON.stringify(result));
});

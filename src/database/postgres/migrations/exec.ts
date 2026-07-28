import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { pool } from "../helper.js";

const execMigrations = async () => {
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);
    const migrationsFile = path.join(__dirname, "01-init.sql");
    const sql = fs.readFileSync(migrationsFile, "utf-8");

    const client = await pool.connect();
    try {
        await client.query("BEGIN");
        await client.query(sql);
        await client.query("COMMIT");
        console.log("Migration executed successfully");
    } catch (error) {
        await client.query("ROLLBACK");
        console.error("Error executing migration:", error);
    } finally {
        client.release();
    }
};


execMigrations();

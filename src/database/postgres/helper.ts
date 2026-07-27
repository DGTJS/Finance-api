import { Pool } from "pg";

process.loadEnvFile?.(".env");

export const pool = new Pool({
  host: process.env.DATABASE_HOST,
  port: Number(process.env.DATABASE_PORT || 5432),
  user: process.env.DATABASE_USER,
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME,
});

export const PostgresHelper = {
  query: async (query: string, params?: unknown[]) => {
    const client = await pool.connect();
    try {
      const result = await client.query(query, params);
      return result.rows;
    } catch (error) {
      console.error("Error executing query", error);
      throw error;
    } finally {
      client.release();
    }
  }
};

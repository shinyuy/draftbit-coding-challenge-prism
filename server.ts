import "dotenv/config";
import { Client } from "pg";
import { backOff } from "exponential-backoff";
import express from "express";
import waitOn from "wait-on";
import onExit from "signal-exit";
import cors from "cors";

// Add your routes here
const setupApp = (client: Client): express.Application => {
  const app: express.Application = express();

  app.use(cors());

  app.use(express.json());

  app.get("/examples", async (_req, res) => {
    const { rows } = await client.query(`SELECT * FROM prism`);
    res.json(rows);
  }); 

  app.get("/prism", async (_req, res) => {
    const { rows } = await client.query(`SELECT * FROM prism`);
    res.json(rows);
  }); 

  // Endpoint to insert values into the users table
app.post('/prism', (req, res) => {
  const { value, unit, side } = req.body;

  const insertSQL = 'INSERT INTO prism (value, unit, side) VALUES ($1, $2, $3) RETURNING id';
  client.query(insertSQL, [value, unit, side], (err, result) => {
    if (err) {
      console.error('Error inserting prism:', err);
      return res.status(500).json({ error: 'Database insertion failed' });
    }
    res.status(201).json({ id: result.rows[0].id, value, unit, side });
  });
});

app.put('/prism/:id', (req, res) => {
  const { id } = req.params; 
  const { value, unit, side } = req.body;

  const updateSQL = `UPDATE prism SET value = $1, unit = $2 WHERE id = $3 AND side = $4 RETURNING *`;
  client.query(updateSQL, [separateAndConvert(value).digits, separateAndConvert(value).letters, id, side], (err, result:any) => {

    if (result.rowCount > 0) {
      console.log(result)
      res.status(200).json(result.rows[0]);
    } else {
      res.status(404).json({ message: 'Prism not found' });
    }
  });
});

  return app;         
};   

// Waits for the database to start and connects
const connect = async (): Promise<Client> => {
  console.log("Connecting");
  const resource = `tcp:${process.env.PGHOST}:${process.env.PGPORT}`;
  console.log(`Waiting for ${resource}`);
  await waitOn({ resources: [resource] });
  console.log("Initializing client");
  const client = new Client();
  await client.connect();   
  console.log("Connected to database");

  const createTableSQL = `
    CREATE TABLE IF NOT EXISTS prism (
      id SERIAL PRIMARY KEY,
      value INT,
      unit VARCHAR(100),
      side VARCHAR(100)
    );
  `;
  
  client.query(createTableSQL, (err, results) => {
    if (err) {
      console.error('Error creating table:', err);
    } else {
      console.log('Prism table created or already exists.');
    }
  });
      
  // Ensure the client disconnects on exit
  onExit(async () => {
    console.log("onExit: closing client");
    await client.end();
  });

  return client;
};

const main = async () => {
  const client = await connect();
  const app = setupApp(client);
  const port = parseInt(process.env.SERVER_PORT);
  app.listen(port, () => {
    console.log(
      `Draftbit Coding Challenge is running at http://localhost:${port}/`
    );
  });
};

const separateAndConvert = (input:string) => {
  // Use regular expressions to match digits and letters
  const digits = input.match(/\d+/g); // Match all groups of digits
  const letters = input.match(/[a-zA-Z%]+/g); // Match all groups of letters

  // Join the digits and convert to a single integer (if any digits are found)
  const joinedDigits = digits ? parseInt(digits.join(''), 10) : 0; // Default to 0 if no digits found
  // Join the letters (if any letters are found)
  const joinedLetters = letters ? letters.join('') : '';

  return { digits: joinedDigits, letters: joinedLetters };
}


main();
  
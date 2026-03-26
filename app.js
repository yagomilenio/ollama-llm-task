const fs = require("fs");
const axios = require("axios");
const YAML = require("yaml");


const prompt = process.argv.slice(2).join(" ");
if (!prompt) {
    console.error("Uso: node app.js \"tu prompt aquí\"");
    process.exit(1);
}



const cfg = YAML.parse(fs.readFileSync("server_config.yml", "utf8"));

const API_BASE = cfg.server.api_base;
const MODEL    = cfg.model.name;



async function main() {
    try {
    const res = await axios.post(`${API_BASE}/api/generate`, {
        model: MODEL,
        prompt: prompt,
        stream: false
    });

    process.stdout.write(res.data.response + "\n");
    
    } catch (err) {
    console.error("Error:", err.message);
    }
}

main();

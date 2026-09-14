const path = require("path");
const express = require("express");
const { spawn } = require("child_process");
const messages = require('./messages.json');

const app = express();
const PORT = process.env.PORT || 3000;
const PYTHON_BIN = process.env.PYTHON_BIN || "python3";

app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));

app.post("/api/predict", (req, res) => {
  const { state, crop, year, annualRainfall, monsoonRainfall, previousYearYield } = req.body;
  if (
    typeof state !== "string" || state.trim() === "" ||
    typeof crop !== "string" || crop.trim() === "" ||
    !Number.isFinite(year) ||
    !Number.isFinite(annualRainfall) ||
    !Number.isFinite(monsoonRainfall) ||
    !Number.isFinite(previousYearYield)
  ) {
    return res.status(400).json({ error: messages.errors.invalid_input });
  }

  const args = ["-m", "src.run", state, crop, String(year), String(annualRainfall), String(monsoonRainfall), String(previousYearYield)];
  const child = spawn(PYTHON_BIN, args, { cwd: __dirname });
  //console.debug("Starting", PYTHON_BIN, "with", args)

  let stdout = "";
  let stderr = "";
  child.stdout.on("data", (chunk) => { stdout += chunk; });
  child.stderr.on("data", (chunk) => { stderr += chunk; });

  child.on("error", (err) => {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: messages.errors.script_exec });
  });

  child.on("close", (code) => {
    if (res.headersSent) return;
    if (code !== 0) {
      console.error(stderr.trim());
      return res.status(500).json({ error: messages.errors.script_results });
    }
    var lines = stdout.trim().split("\n");
    var lastLine = lines[lines.length - 1];
    try {
      const result = JSON.parse(lastLine);
      res.json(result);
    } catch (err) {
      console.error(stdout);
      res.status(500).json({ error: messages.errors.parsing });
    }
  });
});




app.listen(PORT, () => {
  console.log(`Server is up on http://localhost:${PORT}`);
});

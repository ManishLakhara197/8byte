const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.get("/health", (_, res) => {
  res.json({ status: "ok", service: "sample-app" });
});

app.get("/", (_, res) => {
  res.json({ message: "Hello from the sample app" });
});

app.listen(PORT, () => {
  console.log(`Sample app listening on port ${PORT}`);
});

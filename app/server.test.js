const test = require("node:test");
const assert = require("node:assert/strict");

test("health endpoint returns status ok", async () => {
  const response = { status: "ok", service: "sample-app" };
  assert.deepEqual(response, { status: "ok", service: "sample-app" });
});

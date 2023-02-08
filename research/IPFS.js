const IPFS = require("ipfs-http-client");
const ipfs = new IPFS({
  host: "ipfs.infura.io",
  port: "5001",
  protocol: "https",
});

async function ipfsHash(image, description) {
  const data = Buffer.concat([
    Buffer.from(image, "utf8"),
    Buffer.from(description, "utf8"),
  ]);

  const results = await ipfs.add(data);
  return results[0].hash;
}

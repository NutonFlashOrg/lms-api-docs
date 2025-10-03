/* Команда чтобы сгенерировать initData для тестирования */
//node scripts/mockInitData.js 8125124336:AAExd_lHKu4BBo7v6iPsbO7kV8qM1wHknj4 123456 adminuser

import crypto from "node:crypto";

function buildInitData({
  botToken,
  tgId,
  username,
  authDateSec = Math.floor(Date.now() / 1000),
}) {
  const params = new URLSearchParams();
  const userObj = {
    id: Number(tgId),
    username: username,
  };
  params.set("user", JSON.stringify(userObj));
  params.set("auth_date", String(authDateSec));

  const pairs = [];
  for (const [k, v] of params) if (k !== "hash") pairs.push(`${k}=${v}`);
  pairs.sort();
  const dataCheckString = pairs.join("\n");

  const secretKey = crypto
    .createHmac("sha256", "WebAppData")
    .update(botToken)
    .digest();
  const hash = crypto
    .createHmac("sha256", secretKey)
    .update(dataCheckString)
    .digest("hex");

  params.set("hash", hash);
  return params.toString();
}

// Simple CLI: node scripts/make-tg-initdata.mjs BOT_TOKEN TG_ID USERNAME [AGE_SECONDS]
const [botToken, tgId, username, ageSecStr] = process.argv.slice(2);
if (!botToken || !tgId || !username) {
  console.error(
    "Usage: node scripts/make-tg-initdata.mjs <BOT_TOKEN> <TG_ID> <USERNAME> [AGE_SECONDS]"
  );
  process.exit(1);
}
const authDateSec =
  Math.floor(Date.now() / 1000) - (Number(ageSecStr || 0) || 0);
const initData = buildInitData({ botToken, tgId, username, authDateSec });
console.log(initData);

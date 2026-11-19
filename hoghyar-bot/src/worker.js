const API = "https://api.telegram.org";
export default {
 async fetch(request, env) {
  if (request.method !== "POST") return new Response("HooghYar bot is running");
  const secret = request.headers.get("X-Telegram-Bot-Api-Secret-Token");
  if (!env.TELEGRAM_WEBHOOK_SECRET || secret !== env.TELEGRAM_WEBHOOK_SECRET) return new Response("Unauthorized", {status:401});
  let update;
  try { update = await request.json(); } catch { return new Response("Bad request", {status:400}); }
  if (update.message?.text) await handleMessage(update.message, env);
  return new Response("ok");
 },
 async scheduled(_event, env, ctx) { ctx.waitUntil(sendDueReminders(env)); }
};

async function telegram(env, method, payload) {
 const response = await fetch(API + "/bot" + env.BOT_TOKEN + "/" + method, {
  method:"POST", headers:{"content-type":"application/json"}, body:JSON.stringify(payload)
 });
 if (!response.ok) throw new Error("Telegram API error: " + response.status);
 return response.json();
}
async function reply(env, chatId, text) {
 return telegram(env,"sendMessage",{chat_id:chatId,text,disable_web_page_preview:true});
}
function tehranDate(offsetDays=0) {
 const now = new Date(Date.now()+offsetDays*86400000);
 return new Intl.DateTimeFormat("en-CA",{timeZone:"Asia/Tehran",year:"numeric",month:"2-digit",day:"2-digit"}).format(now);
}
function formatDate(date) {
 const p=date.split("-").map(Number);
 return new Intl.DateTimeFormat("fa-IR-u-ca-persian",{timeZone:"Asia/Tehran",year:"numeric",month:"long",day:"numeric"}).format(new Date(Date.UTC(p[0],p[1]-1,p[2],8)));
}
function validDate(s) {
 if (!/^20\d{2}-\d{2}-\d{2}$/.test(s)) return false;
 const d=new Date(s+"T12:00:00Z");
 return !Number.isNaN(d.getTime()) && d.toISOString().slice(0,10)===s;
}
function parseTime(s) { return /^([01]\d|2[0-3]):[0-5]\d$/.test(s) ? s : null; }
function startTimestamp(date,time) { return Date.parse(date+"T"+time+":00+03:30"); }

async function handleMessage(message,env) {
 const chatId=String(message.chat.id), userId=String(message.from.id), firstName=message.from.first_name||"";
 const text=(message.text||"").trim(), parts=text.split(/\s+/), cmd=(parts.shift()||"").split("@")[0].toLowerCase();
 const args=parts;
 if (cmd==="/start") {
  await env.DB.prepare("INSERT INTO users (telegram_id,chat_id,first_name) VALUES (?,?,?) ON CONFLICT(telegram_id) DO UPDATE SET chat_id=excluded.chat_id,first_name=excluded.first_name").bind(userId,chatId,firstName).run();
  return reply(env,chatId,"سلام "+firstName+" جان 🌱\nبه حقوق‌یار خوش آمدی. برای راهنما /help را بزن.");
 }
 const user=await env.DB.prepare("SELECT * FROM users WHERE telegram_id=?").bind(userId).first();
 if (!user) return reply(env,chatId,"برای شروع اول /start را بزن.");
 if (cmd==="/help") return reply(env,chatId,
  "راهنمای حقوق‌یار\n\nثبت شیفت:\n/set 2026-11-20 شب 19:00\nنوع شیفت: صبح، عصر، شب یا تعطیل\nتاریخ فعلاً میلادی و به شکل YYYY-MM-DD است؛ ساعت شروع را خودت مشخص کن.\n\nحذف: /delete 2026-11-20\nیادآوری: /remind 60\nشیفت امروز: /today\nشیفت فردا: /tomorrow");
 if (cmd==="/remind") {
  const minutes=Number(args[0]);
  if (!Number.isInteger(minutes)||minutes<5||minutes>1440) return reply(env,chatId,"زمان یادآوری باید بین ۵ تا ۱۴۴۰ دقیقه باشد. نمونه: /remind 60");
  await env.DB.prepare("UPDATE users SET reminder_minutes=? WHERE telegram_id=?").bind(minutes,userId).run();
  return reply(env,chatId,"یادآوری از این به بعد "+minutes+" دقیقه قبل از شیفت ارسال می‌شود. 🔔");
 }
 if (cmd==="/set") {
  const date=args[0]||"", type=args[1]||"", time=parseTime(args[2]||"");
  if (!validDate(date)||!["صبح","عصر","شب","تعطیل"].includes(type)||!time) return reply(env,chatId,"قالب درست:\n/set 2026-11-20 شب 19:00\nنوع شیفت: صبح، عصر، شب یا تعطیل");
  const startAt=startTimestamp(date,time);
  if (startAt<Date.now()-86400000) return reply(env,chatId,"این تاریخ گذشته است؛ تاریخ آینده را وارد کن.");
  await env.DB.prepare("INSERT INTO shifts (telegram_id,shift_date,shift_type,start_at_ms,notified_at) VALUES (?,?,?,?,NULL) ON CONFLICT(telegram_id,shift_date) DO UPDATE SET shift_type=excluded.shift_type,start_at_ms=excluded.start_at_ms,notified_at=NULL").bind(userId,date,type,startAt).run();
  return reply(env,chatId,"ثبت شد ✅\n"+formatDate(date)+"\nشیفت: "+type+"\nشروع: "+time+"\nیادآوری: "+user.reminder_minutes+" دقیقه قبل");
 }
 if (cmd==="/delete") {
  const date=args[0]||"";
  if (!validDate(date)) return reply(env,chatId,"تاریخ را به شکل YYYY-MM-DD وارد کن.");
  const result=await env.DB.prepare("DELETE FROM shifts WHERE telegram_id=? AND shift_date=?").bind(userId,date).run();
  return reply(env,chatId,result.meta.changes?"شیفت حذف شد.":"برای این تاریخ شیفتی پیدا نکردم.");
 }
 if (cmd==="/today"||cmd==="/tomorrow") {
  const date=tehranDate(cmd==="/today"?0:1);
  const shift=await env.DB.prepare("SELECT shift_type,start_at_ms FROM shifts WHERE telegram_id=? AND shift_date=?").bind(userId,date).first();
  if (!shift) return reply(env,chatId,"برای "+(cmd==="/today"?"امروز":"فردا")+" شیفتی ثبت نکرده‌ای.");
  const time=new Intl.DateTimeFormat("fa-IR",{timeZone:"Asia/Tehran",hour:"2-digit",minute:"2-digit",hour12:false}).format(new Date(shift.start_at_ms));
  return reply(env,chatId,(cmd==="/today"?"شیفت امروز":"شیفت فردا")+"\n"+formatDate(date)+"\n"+shift.shift_type+" | ساعت "+time);
 }
 return reply(env,chatId,"دستور را نشناختم. برای راهنما /help را بزن.");
}

async function sendDueReminders(env) {
 const now=Date.now();
 const due=await env.DB.prepare("SELECT s.id,s.telegram_id,s.shift_date,s.shift_type,s.start_at_ms,u.chat_id,u.reminder_minutes FROM shifts s JOIN users u ON u.telegram_id=s.telegram_id WHERE s.notified_at IS NULL AND s.start_at_ms-(u.reminder_minutes*60000)<=? AND s.start_at_ms>?").bind(now,now-86400000).all();
 for (const s of due.results||[]) {
  const time=new Intl.DateTimeFormat("fa-IR",{timeZone:"Asia/Tehran",hour:"2-digit",minute:"2-digit",hour12:false}).format(new Date(s.start_at_ms));
  try {
   await reply(env,s.chat_id,"🔔 یادآوری شیفت\n\n"+formatDate(s.shift_date)+"\nنوع شیفت: "+s.shift_type+"\nساعت شروع: "+time+"\n\nمراقب خودت باش 🌱");
   await env.DB.prepare("UPDATE shifts SET notified_at=CURRENT_TIMESTAMP WHERE id=? AND notified_at IS NULL").bind(s.id).run();
  } catch(error) { console.error("Reminder delivery failed",s.id,error); }
 }
}
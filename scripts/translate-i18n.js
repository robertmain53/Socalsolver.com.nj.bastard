/**
 * Translate en.json → es/fr/it using GPT-4
 * ---------------------------------------
 * Usage:  node scripts/translate-i18n.js
 * Requires: OPENAI_API_KEY in .env
 */
import fs from 'fs/promises';
import path from 'path';
import { config } from 'dotenv';
import OpenAI from 'openai';

config();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const root = 'content/categories';
const source = path.join(root, 'en.json');
const targets = [
  { code: 'es', name: 'Spanish' },
  { code: 'fr', name: 'French' },
  { code: 'it', name: 'Italian' }
];

async function translate(value, lang) {
  const prompt = `
Translate the JSON snippet below from English to ${lang}.
KEEP KEYS AND STRUCTURE INTACT. Only translate the string values.
Return ONLY valid JSON (no markdown fences).
`;
  const res = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    temperature: 0.2,
    messages: [
      { role: 'system', content: 'You are a precise JSON translator.' },
      { role: 'user', content: prompt + '\n' + JSON.stringify(value) }
    ]
  });
  return JSON.parse(res.choices[0].message.content);
}

async function main() {
  const en = JSON.parse(await fs.readFile(source, 'utf8'));
  for (const t of targets) {
    console.log(`🌐  Translating → ${t.code}`);
    const out = await translate(en, t.name);
    await fs.writeFile(path.join(root, `${t.code}.json`), JSON.stringify(out, null, 2));
    console.log(`✅  ${t.code}.json written`);
  }
}
main().catch(e => {
  console.error(e);
  process.exit(1);
});

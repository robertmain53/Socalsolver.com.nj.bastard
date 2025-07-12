/**
 * translate-categories.js
 * -----------------------
 * Usage:   node translate-categories.js
 *
 * Requires:
 *   - OPENAI_API_KEY in env
 *   - content/categories/en.json present
 *
 * It creates/overwrites:
 *   content/categories/es.json
 *   content/categories/fr.json
 *   content/categories/it.json
 */

import fs from 'fs/promises';
import path from 'path';
import OpenAI from 'openai';

const LOCALES = ['es', 'fr', 'it'];
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const SRC = 'content/categories/en.json';

async function translateText(text, locale) {
  const prompt = `
You are a professional translator. Translate the following JSON value
from English into ${locale.toUpperCase()}. Do NOT change placeholder keys.
Only translate the human-readable text after the colons:

"${text}"
`.trim();

  const res = await openai.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      { role: 'system', content: 'You translate user text precisely.' },
      { role: 'user', content: prompt }
    ],
    temperature: 0.3
  });
  return res.choices[0].message.content.replace(/^"|"$/g, '');
}

async function walk(obj, locale) {
  for (const k of Object.keys(obj)) {
    const val = obj[k];
    if (typeof val === 'string') {
      obj[k] = await translateText(val, locale);
    } else if (Array.isArray(val)) {
      for (const item of val) await walk(item, locale);
    } else if (typeof val === 'object' && val !== null) {
      await walk(val, locale);
    }
  }
}

async function main() {
  const enRaw = await fs.readFile(SRC, 'utf8');
  const enJson = JSON.parse(enRaw);

  for (const locale of LOCALES) {
    console.log(`🌐 Translating to ${locale.toUpperCase()} …`);
    const clone = JSON.parse(JSON.stringify(enJson)); // deep clone
    await walk(clone, locale);
    const dest = `content/categories/${locale}.json`;
    await fs.mkdir(path.dirname(dest), { recursive: true });
    await fs.writeFile(dest, JSON.stringify(clone, null, 2));
    console.log(`✅  ${dest} written`);
  }
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});

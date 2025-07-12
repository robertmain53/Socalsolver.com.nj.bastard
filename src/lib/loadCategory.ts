// src/lib/loadCategory.ts
import fs from 'fs/promises';
import path from 'path';
import { locales, defaultLocale } from '@/i18n/config';

export async function getCategoryData(locale = defaultLocale) {
  const file = locales.includes(locale)
    ? path.join(process.cwd(), 'content/categories', `${locale}.json`)
    : path.join(process.cwd(), 'content/categories', `${defaultLocale}.json`);
  const json = await fs.readFile(file, 'utf8');
  return JSON.parse(json);
}

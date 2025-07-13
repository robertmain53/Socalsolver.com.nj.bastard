import en from '@/data/locales/en.json'
import es from '@/data/locales/es.json'
import fr from '@/data/locales/fr.json'
import it from '@/data/locales/it.json'
const dict: Record<string, any> = { en, es, fr, it }
export async function getDictionary(locale: string) { return dict[locale] || dict.en }
export function getLocales(){ return ['en','es','fr','it'] }

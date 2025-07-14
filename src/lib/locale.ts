export function getLocale(loc: string): string {
  const supported = ['en', 'es', 'fr', 'it']
  return supported.includes(loc) ? loc : 'en'
}

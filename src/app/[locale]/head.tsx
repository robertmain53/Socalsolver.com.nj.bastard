'use client';
import { usePathname } from 'next/navigation';
const locales = ['en', 'fr', 'es', 'it'];
const baseUrl = 'https://socalsolver.com';  // Update to your production domain if different
export default function Head() {
  const pathname = usePathname() || '';
  // Remove locale segment from the path
  const segments = pathname.split('/').filter(Boolean);
  segments.shift(); // drop the locale (first segment)
  const pathWithoutLocale = segments.length ? `/${segments.join('/')}` : '';
  return (
    <>
      {locales.map((loc) => (
        <link 
          key={loc}
          rel="alternate"
          hrefLang={loc}
          href={`${baseUrl}/${loc}${pathWithoutLocale}`} 
        />
      ))}
      {/* x-default points to English as the default language */}
      <link rel="alternate" hrefLang="x-default" href={`${baseUrl}/en${pathWithoutLocale}`} />
    </>
  );
}

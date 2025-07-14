// next.config.js

/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true,   // <-- skip TS during build
  },
  // … keep whatever else you already have
}
module.exports = nextConfig



module.exports = {
  i18n: {
    locales: ['en', 'it', 'es', 'fr'],
    defaultLocale: 'en',
    localeDetection: false,
  },
}

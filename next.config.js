/** @type {import('next').NextConfig} */
const nextConfig = {
  i18n: {
    locales: ['en', 'es', 'it', 'fr'],
    defaultLocale: 'en'
  },
  experimental: {
    serverActions: true,   // 👈 add this line
  },
};

module.exports = nextConfig;

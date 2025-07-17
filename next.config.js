/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverActions: true,   // 👈 add this line
  },
};

module.exports = nextConfig;

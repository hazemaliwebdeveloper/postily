// @ts-check
const { withSentryConfig } = require('@sentry/nextjs');

/** @type {import('next').NextConfig} */
const nextConfig = {
  // CRITICAL: Required for Docker/Vercel isolation
  output: 'standalone',

  experimental: {
    // optimizePackageImports: ['@mantine/core', 'lucide-react'],
  },

  reactStrictMode: true,
  transpilePackages: ['@gitroom/react', '@gitroom/helpers', 'crypto-hash'],

  images: {
    remotePatterns: [
      { protocol: 'https', hostname: '**' },
      { protocol: 'http', hostname: '**' },
    ],
    minimumCacheTTL: 60,
  },

  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-XSS-Protection', value: '1; mode=block' },
        ],
      },
    ];
  },
};

// Wrap with Sentry if env vars exist, otherwise export raw config
module.exports = process.env.SENTRY_AUTH_TOKEN
  ? withSentryConfig(nextConfig, { silent: true, org: process.env.SENTRY_ORG, project: process.env.SENTRY_PROJECT })
  : nextConfig;

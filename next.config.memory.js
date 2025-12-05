/** @type {import('next').NextConfig} */

const path = require('path');

const nextConfig = {
  // Memory optimization settings
  experimental: {
    // Reduce memory usage during build
    workerThreads: false,
    // Optimize bundle size
    optimizePackageImports: ['@mantine/core', '@mantine/hooks'],
  },
  
  // Performance optimizations
  poweredByHeader: false,
  compress: true,
  
  // Memory-efficient compilation
  webpack: (config, { dev, isServer }) => {
    // Optimize memory usage in development
    if (dev) {
      config.watchOptions = {
        poll: 1000,
        aggregateTimeout: 300,
        ignored: /node_modules/
      };
    }
    
    // Memory optimization for large builds
    config.optimization = {
      ...config.optimization,
      splitChunks: {
        chunks: 'all',
        cacheGroups: {
          default: {
            minChunks: 1,
            priority: -20,
            reuseExistingChunk: true
          },
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            priority: -10,
            chunks: 'all'
          }
        }
      }
    };
    
    return config;
  },
  
  // Reduce memory footprint
  swcMinify: true,
  
  // Output optimization
  output: 'standalone'
};

module.exports = nextConfig;
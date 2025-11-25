#!/bin/bash
# Quick commit script for all Node version fixes

echo "📦 Adding all changes..."
git add .

echo "💾 Committing..."
git commit -m "Fix: Update Node version to 22 in all packages"

echo "🚀 Pushing to GitHub..."
git push

echo "✅ Done! Your Vercel deployment should now work."

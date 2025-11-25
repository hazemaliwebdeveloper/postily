#!/bin/bash
# Quick Fix Script for Vercel Deployment

echo "🔧 Fixing Vercel deployment issues..."

# Remove sponsorship file
rm -f .github/FUNDING.yaml

# Commit changes
git add -A
git commit -m "Fix: Remove Vercel ignore command and sponsorship links"
git push

echo "✅ Code changes pushed!"
echo ""
echo "⚠️  IMPORTANT: You MUST do this ONE manual step:"
echo ""
echo "1. Go to: https://vercel.com/dashboard"
echo "2. Select your project"
echo "3. Click: Settings → Git"
echo "4. Find: 'Ignored Build Step'"
echo "5. CLEAR that field (make it empty)"
echo "6. Click: Save"
echo "7. Go to Deployments → Redeploy"
echo ""
echo "That's it! Your deployment will work after step 7."

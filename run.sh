#!/bin/bash
set -e

echo "Building Flutter web app..."
flutter build web --release

echo "Serving Flutter web app on port 5000..."
npx serve build/web -p 5000 -s --no-clipboard

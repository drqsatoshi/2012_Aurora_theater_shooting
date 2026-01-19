#!/bin/bash
# CLI tool for testing firewall workarounds
# Usage: ./wayback_scrape.sh URL [output_file]

URL="${1}"
OUTPUT="${2:-scrape_wayback.html}"

if [ -z "$URL" ]; then
  echo "Usage: ./wayback_scrape.sh URL [output_file]"
  echo ""
  echo "This script fetches the latest Wayback Machine snapshot of a URL."
  echo "Useful for getting around firewalls and paywalls."
  echo ""
  echo "Examples:"
  echo "  ./wayback_scrape.sh https://example.com/article"
  echo "  ./wayback_scrape.sh https://grokipedia.com/page/Test wayback_test.html"
  exit 1
fi

echo "======================================"
echo "  Wayback Machine Scraper"
echo "======================================"
echo "Target URL: $URL"
echo "Output: $OUTPUT"
echo ""

# Get the latest snapshot URL from Wayback Machine
echo "Checking Wayback Machine for archived snapshots..."
WAYBACK_API="https://archive.org/wayback/available?url=$(echo "$URL" | jq -sRr @uri)"

RESPONSE=$(curl -s "$WAYBACK_API")

# Extract the snapshot URL
SNAPSHOT_URL=$(echo "$RESPONSE" | grep -oP '"url"\s*:\s*"\K[^"]*' | head -1)

if [ -z "$SNAPSHOT_URL" ]; then
  echo "❌ No archived snapshot found for this URL"
  echo ""
  echo "You can try:"
  echo "  1. Using the main scrape.js which has automatic fallbacks"
  echo "  2. Visiting https://web.archive.org/ to manually save the page"
  exit 1
fi

echo "✓ Found archived snapshot:"
echo "  $SNAPSHOT_URL"
echo ""

# Fetch the archived page
echo "Fetching archived content..."
curl -s "$SNAPSHOT_URL" -o "$OUTPUT"

if [ -f "$OUTPUT" ]; then
  SIZE=$(stat -f%z "$OUTPUT" 2>/dev/null || stat -c%s "$OUTPUT" 2>/dev/null)
  echo "✓ Content saved to $OUTPUT ($SIZE bytes)"
  echo ""
  echo "Preview:"
  echo "--------"
  head -20 "$OUTPUT"
  echo "--------"
else
  echo "❌ Failed to save content"
  exit 1
fi

echo ""
echo "You can now analyze this file with the SEO analyzer:"
echo "  cat $OUTPUT | grep -E '<title>|<meta name=\"description\"'"

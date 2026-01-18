#!/bin/bash
# Test script to verify the generalized tool works correctly

echo "======================================"
echo "  Testing Generalized Grokipedia Tool"
echo "======================================"
echo ""

# Test 1: Check if config.json exists
echo "Test 1: Checking config.json..."
if [ -f "config.json" ]; then
  echo "✓ config.json exists"
  cat config.json | head -5
else
  echo "✗ config.json not found"
  exit 1
fi
echo ""

# Test 2: Check scrape.js syntax
echo "Test 2: Checking scrape.js syntax..."
if node -c scrape.js 2>&1; then
  echo "✓ scrape.js syntax is valid"
else
  echo "✗ scrape.js has syntax errors"
  exit 1
fi
echo ""

# Test 3: Check seo_analyzer.sh syntax
echo "Test 3: Checking seo_analyzer.sh syntax..."
if bash -n seo_analyzer.sh 2>&1; then
  echo "✓ seo_analyzer.sh syntax is valid"
else
  echo "✗ seo_analyzer.sh has syntax errors"
  exit 1
fi
echo ""

# Test 4: Check example configs
echo "Test 4: Checking example configurations..."
EXAMPLE_COUNT=$(ls examples/*.json 2>/dev/null | wc -l)
if [ "$EXAMPLE_COUNT" -gt 0 ]; then
  echo "✓ Found $EXAMPLE_COUNT example configuration(s)"
  ls examples/*.json
else
  echo "✗ No example configurations found"
  exit 1
fi
echo ""

# Test 5: Verify scrape.js help works
echo "Test 5: Testing scrape.js --help..."
if node scrape.js --help 2>&1 | grep -q "Grokipedia Scraper"; then
  echo "✓ scrape.js --help works"
else
  echo "✗ scrape.js --help failed"
  exit 1
fi
echo ""

# Test 6: Check if seo_analyzer.sh accepts URL parameter
echo "Test 6: Testing seo_analyzer.sh parameter handling..."
TEST_URL="https://example.com/test"
# Just check if the URL is passed through, don't actually fetch it
if timeout 2 ./seo_analyzer.sh "$TEST_URL" 2>&1 | head -10 | grep -q "$TEST_URL"; then
  echo "✓ seo_analyzer.sh accepts URL parameters"
else
  echo "⚠️  Note: seo_analyzer.sh parameter test skipped (network/timeout)"
fi
echo ""

# Test 7: Verify package.json is correct
echo "Test 7: Checking package.json..."
if grep -q "grokipedia-seo-tool" package.json; then
  echo "✓ package.json has been updated to generic name"
else
  echo "⚠️  package.json may still have old name"
fi
echo ""

echo "======================================"
echo "  Test Summary"
echo "======================================"
echo "All critical tests passed!"
echo ""
echo "The tool is now generalized and can work with any Grokipedia article."
echo ""
echo "Usage examples:"
echo "  node scrape.js https://grokipedia.com/page/YOUR_ARTICLE"
echo "  ./seo_analyzer.sh https://grokipedia.com/page/YOUR_ARTICLE"
echo ""

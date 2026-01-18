#!/bin/bash

# SEO Crawler Analysis Script
# This script analyzes the Grokipedia page for SEO optimization

URL="https://grokipedia.com/page/2012_Aurora_theater_shooting"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="seo_reports"
REPORT="${REPORT_DIR}/crawl_report_${TIMESTAMP}.txt"

# Create reports directory
mkdir -p "$REPORT_DIR"

echo "======================================"
echo "  SEO Crawler Analysis Tool"
echo "======================================"
echo "URL: $URL"
echo "Report will be saved to: $REPORT"
echo ""

# Initialize report
cat > "$REPORT" << EOF
SEO CRAWLER ANALYSIS REPORT
===========================
URL: $URL
Generated: $(date)
Report ID: $TIMESTAMP

EOF

echo "🔍 Running crawler analysis..."

# 1. HTTP Status Check
echo "" | tee -a "$REPORT"
echo "--- HTTP STATUS ---" | tee -a "$REPORT"
HTTP_STATUS=$(curl -I -s -o /dev/null -w "%{http_code}" "$URL")
echo "Status Code: $HTTP_STATUS" | tee -a "$REPORT"

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ Page is accessible" | tee -a "$REPORT"
else
    echo "⚠️  Warning: Non-200 status code" | tee -a "$REPORT"
fi

# 2. Page Title
echo "" | tee -a "$REPORT"
echo "--- PAGE TITLE ---" | tee -a "$REPORT"
TITLE=$(curl -s "$URL" | grep -oP '(?<=<title>).*?(?=</title>)' | head -1)
echo "$TITLE" | tee -a "$REPORT"
TITLE_LENGTH=${#TITLE}
echo "Length: $TITLE_LENGTH characters" | tee -a "$REPORT"

if [ $TITLE_LENGTH -ge 50 ] && [ $TITLE_LENGTH -le 60 ]; then
    echo "✅ Title length is optimal (50-60 chars)" | tee -a "$REPORT"
elif [ $TITLE_LENGTH -lt 50 ]; then
    echo "⚠️  Title is too short (< 50 chars)" | tee -a "$REPORT"
else
    echo "⚠️  Title is too long (> 60 chars)" | tee -a "$REPORT"
fi

# 3. Meta Description
echo "" | tee -a "$REPORT"
echo "--- META DESCRIPTION ---" | tee -a "$REPORT"
META_DESC=$(curl -s "$URL" | grep -oP '<meta name="description" content="\K[^"]*' | head -1)
if [ -n "$META_DESC" ]; then
    echo "$META_DESC" | tee -a "$REPORT"
    DESC_LENGTH=${#META_DESC}
    echo "Length: $DESC_LENGTH characters" | tee -a "$REPORT"
    
    if [ $DESC_LENGTH -ge 150 ] && [ $DESC_LENGTH -le 160 ]; then
        echo "✅ Description length is optimal (150-160 chars)" | tee -a "$REPORT"
    else
        echo "⚠️  Description length should be 150-160 characters" | tee -a "$REPORT"
    fi
else
    echo "❌ No meta description found" | tee -a "$REPORT"
fi

# 4. Heading Structure
echo "" | tee -a "$REPORT"
echo "--- HEADING STRUCTURE ---" | tee -a "$REPORT"
H1_COUNT=$(curl -s "$URL" | grep -oP '(?<=<h1[^>]*>).*?(?=</h1>)' | wc -l)
echo "H1 headings: $H1_COUNT" | tee -a "$REPORT"

if [ "$H1_COUNT" = "1" ]; then
    echo "✅ Exactly one H1 heading (optimal)" | tee -a "$REPORT"
    curl -s "$URL" | grep -oP '(?<=<h1[^>]*>).*?(?=</h1>)' | head -1 | tee -a "$REPORT"
else
    echo "⚠️  Should have exactly one H1 heading" | tee -a "$REPORT"
fi

H2_COUNT=$(curl -s "$URL" | grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)' | wc -l)
echo "H2 headings: $H2_COUNT" | tee -a "$REPORT"

# 5. Content Analysis
echo "" | tee -a "$REPORT"
echo "--- CONTENT ANALYSIS ---" | tee -a "$REPORT"
WORD_COUNT=$(curl -s "$URL" | sed 's/<[^>]*>//g' | wc -w)
echo "Word count: $WORD_COUNT" | tee -a "$REPORT"

if [ $WORD_COUNT -ge 1500 ]; then
    echo "✅ Good content length (1500+ words)" | tee -a "$REPORT"
elif [ $WORD_COUNT -ge 1000 ]; then
    echo "⚠️  Content could be longer (aim for 1500+ words)" | tee -a "$REPORT"
else
    echo "❌ Content is too short (< 1000 words)" | tee -a "$REPORT"
fi

# 6. Page Load Performance
echo "" | tee -a "$REPORT"
echo "--- PAGE PERFORMANCE ---" | tee -a "$REPORT"
LOAD_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$URL")
SIZE=$(curl -o /dev/null -s -w "%{size_download}" "$URL")
SIZE_KB=$((SIZE / 1024))

echo "Load time: ${LOAD_TIME}s" | tee -a "$REPORT"
echo "Page size: ${SIZE_KB} KB" | tee -a "$REPORT"

# Use bc for proper decimal comparison
if command -v bc &> /dev/null; then
    if (( $(echo "$LOAD_TIME < 3" | bc -l) )); then
        echo "✅ Fast load time (< 3 seconds)" | tee -a "$REPORT"
    else
        echo "⚠️  Slow load time (optimize for < 3 seconds)" | tee -a "$REPORT"
    fi
else
    # Fallback: convert to milliseconds for integer comparison
    LOAD_TIME_MS=$(echo "$LOAD_TIME * 1000" | awk '{print int($1)}')
    if [ "$LOAD_TIME_MS" -lt 3000 ]; then
        echo "✅ Fast load time (< 3 seconds)" | tee -a "$REPORT"
    else
        echo "⚠️  Slow load time (optimize for < 3 seconds)" | tee -a "$REPORT"
    fi
fi

# 7. Links Analysis
echo "" | tee -a "$REPORT"
echo "--- LINKS ANALYSIS ---" | tee -a "$REPORT"
TOTAL_LINKS=$(curl -s "$URL" | grep -oP '<a href="[^"]*"' | wc -l)
echo "Total links: $TOTAL_LINKS" | tee -a "$REPORT"

if [ $TOTAL_LINKS -ge 10 ]; then
    echo "✅ Good number of links" | tee -a "$REPORT"
else
    echo "⚠️  Consider adding more links for better navigation" | tee -a "$REPORT"
fi

# 8. Image Optimization
echo "" | tee -a "$REPORT"
echo "--- IMAGE OPTIMIZATION ---" | tee -a "$REPORT"
IMG_COUNT=$(curl -s "$URL" | grep -oP '<img[^>]*>' | wc -l)
IMG_WITH_ALT=$(curl -s "$URL" | grep -oP '<img[^>]*alt="[^"]*"[^>]*>' | wc -l)
echo "Total images: $IMG_COUNT" | tee -a "$REPORT"
echo "Images with alt text: $IMG_WITH_ALT" | tee -a "$REPORT"

if [ $IMG_COUNT -eq $IMG_WITH_ALT ]; then
    echo "✅ All images have alt text" | tee -a "$REPORT"
else
    MISSING=$((IMG_COUNT - IMG_WITH_ALT))
    echo "⚠️  $MISSING images missing alt text" | tee -a "$REPORT"
fi

# 9. Mobile Friendliness
echo "" | tee -a "$REPORT"
echo "--- MOBILE FRIENDLINESS ---" | tee -a "$REPORT"
VIEWPORT=$(curl -s "$URL" | grep -i "viewport" | head -1)
if [ -n "$VIEWPORT" ]; then
    echo "✅ Viewport meta tag found" | tee -a "$REPORT"
    echo "$VIEWPORT" | tee -a "$REPORT"
else
    echo "❌ No viewport meta tag (not mobile-friendly)" | tee -a "$REPORT"
fi

# 10. Structured Data
echo "" | tee -a "$REPORT"
echo "--- STRUCTURED DATA ---" | tee -a "$REPORT"
SCHEMA=$(curl -s "$URL" | grep -c 'type="application/ld+json"')
if [ $SCHEMA -gt 0 ]; then
    echo "✅ JSON-LD structured data found ($SCHEMA instances)" | tee -a "$REPORT"
else
    echo "⚠️  No structured data found" | tee -a "$REPORT"
fi

# 11. Security
echo "" | tee -a "$REPORT"
echo "--- SECURITY & HTTPS ---" | tee -a "$REPORT"
if [[ "$URL" == https* ]]; then
    echo "✅ Using HTTPS" | tee -a "$REPORT"
else
    echo "❌ Not using HTTPS" | tee -a "$REPORT"
fi

# 12. Crawler Test Results
echo "" | tee -a "$REPORT"
echo "--- CRAWLER COMPATIBILITY ---" | tee -a "$REPORT"

# Test Googlebot
GOOGLEBOT_STATUS=$(curl -I -s -o /dev/null -w "%{http_code}" \
    -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" "$URL")
echo "Googlebot access: $GOOGLEBOT_STATUS" | tee -a "$REPORT"

# Test Bingbot
BINGBOT_STATUS=$(curl -I -s -o /dev/null -w "%{http_code}" \
    -A "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" "$URL")
echo "Bingbot access: $BINGBOT_STATUS" | tee -a "$REPORT"

# Generate SEO Score
echo "" | tee -a "$REPORT"
echo "--- SEO SCORE SUMMARY ---" | tee -a "$REPORT"

SCORE=0
MAX_SCORE=12

[ "$HTTP_STATUS" = "200" ] && SCORE=$((SCORE + 1))
[ $TITLE_LENGTH -ge 50 ] && [ $TITLE_LENGTH -le 60 ] && SCORE=$((SCORE + 1))
[ -n "$META_DESC" ] && SCORE=$((SCORE + 1))
[ "$H1_COUNT" = "1" ] && SCORE=$((SCORE + 1))
[ $WORD_COUNT -ge 1500 ] && SCORE=$((SCORE + 1))

# Check load time (handle both bc and fallback)
if command -v bc &> /dev/null; then
    (( $(echo "$LOAD_TIME < 3" | bc -l) )) && SCORE=$((SCORE + 1))
else
    LOAD_TIME_MS=$(echo "$LOAD_TIME * 1000" | awk '{print int($1)}')
    [ "$LOAD_TIME_MS" -lt 3000 ] && SCORE=$((SCORE + 1))
fi

[ $TOTAL_LINKS -ge 10 ] && SCORE=$((SCORE + 1))
[ $IMG_COUNT -eq $IMG_WITH_ALT ] && SCORE=$((SCORE + 1))
[ -n "$VIEWPORT" ] && SCORE=$((SCORE + 1))
[ $SCHEMA -gt 0 ] && SCORE=$((SCORE + 1))
[[ "$URL" == https* ]] && SCORE=$((SCORE + 1))
[ "$GOOGLEBOT_STATUS" = "200" ] && SCORE=$((SCORE + 1))

PERCENTAGE=$((SCORE * 100 / MAX_SCORE))

echo "SEO Score: $SCORE/$MAX_SCORE ($PERCENTAGE%)" | tee -a "$REPORT"

if [ $PERCENTAGE -ge 90 ]; then
    echo "🌟 Excellent! Page is well optimized" | tee -a "$REPORT"
elif [ $PERCENTAGE -ge 70 ]; then
    echo "👍 Good! Some improvements possible" | tee -a "$REPORT"
elif [ $PERCENTAGE -ge 50 ]; then
    echo "⚠️  Needs improvement" | tee -a "$REPORT"
else
    echo "❌ Critical: Major SEO issues detected" | tee -a "$REPORT"
fi

echo "" | tee -a "$REPORT"
echo "======================================"
echo "Report saved to: $REPORT"
echo "======================================"

# Save HTML versions if page was fetched successfully
if [ "$HTTP_STATUS" = "200" ]; then
    echo ""
    echo "💾 Saving crawler views..."
    
    # Googlebot view
    curl -s -A "Mozilla/5.0 (compatible; Googlebot/2.1)" "$URL" \
        > "${REPORT_DIR}/googlebot_view_${TIMESTAMP}.html"
    echo "  - Googlebot view saved"
    
    # Regular view
    curl -s "$URL" > "${REPORT_DIR}/regular_view_${TIMESTAMP}.html"
    echo "  - Regular view saved"
fi

echo ""
echo "✨ Analysis complete!"

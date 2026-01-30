# SEO Optimization and Web Crawler Guide

This guide provides command-line steps to improve search engine visibility and help any Grokipedia article rank on the first page alongside Wikipedia.

**Note:** Replace `YOUR_ARTICLE_URL` with your target article URL throughout this guide.

## Table of Contents
1. [Generate robots.txt](#generate-robotstxt)
2. [Create XML Sitemap](#create-xml-sitemap)
3. [Test Search Engine Crawlers](#test-search-engine-crawlers)
4. [Analyze Page Structure](#analyze-page-structure)
5. [Validate SEO Elements](#validate-seo-elements)
6. [Monitor Crawl Performance](#monitor-crawl-performance)

---

## Generate robots.txt

Allow search engine crawlers to index the page:

```bash
cat > robots.txt << 'EOF'
User-agent: *
Allow: /
Sitemap: https://grokipedia.com/sitemap.xml

# Google crawlers
User-agent: Googlebot
Allow: /

User-agent: Googlebot-Image
Allow: /

# Bing
User-agent: Bingbot
Allow: /

# Yahoo
User-agent: Slurp
Allow: /

# DuckDuckGo
User-agent: DuckDuckBot
Allow: /

Crawl-delay: 1
EOF
```

---

## Create XML Sitemap

Generate a sitemap for search engines:

```bash
# Using environment variable for your article URL
ARTICLE_URL="https://grokipedia.com/page/YOUR_ARTICLE_NAME"

cat > sitemap.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>${ARTICLE_URL}</loc>
    <lastmod>$(date +%Y-%m-%d)</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
EOF
```

**Note:** The date is automatically set to today's date using `$(date +%Y-%m-%d)`.

---

## Test Search Engine Crawlers

### Setting Your Article URL

```bash
# Set your article URL as an environment variable for easy reuse
export ARTICLE_URL="https://grokipedia.com/page/YOUR_ARTICLE_NAME"
```

### Simulate Googlebot Crawl

```bash
# Fetch page as Googlebot
curl -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" \
  "$ARTICLE_URL" > googlebot_view.html

# Check response headers
curl -I -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" \
  "$ARTICLE_URL"
```

### Simulate Bingbot Crawl

```bash
# Fetch page as Bingbot
curl -A "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" \
  "$ARTICLE_URL" > bingbot_view.html
```

### Test Spider Crawl

```bash
# Recursive spider crawl with wget (test only - be respectful of server resources)
wget --spider -r -l 2 --user-agent="SEO-Spider/1.0" \
  "$ARTICLE_URL" 2>&1 | tee spider_log.txt

# Alternative: Use curl to check link validity
curl -I --user-agent="SEO-Spider/1.0" \
  "$ARTICLE_URL"
```

---

## Analyze Page Structure

### Extract SEO-Critical Elements

**Note:** Set `ARTICLE_URL` first with your target URL.

```bash
# Extract title tag
curl -s "$ARTICLE_URL" | \
  grep -oP '(?<=<title>).*?(?=</title>)' | head -1

# Extract meta description
curl -s "$ARTICLE_URL" | \
  grep -oP '<meta name="description" content="\K[^"]*' | head -1

# Extract all H1 headings
curl -s "$ARTICLE_URL" | \
  grep -oP '(?<=<h1[^>]*>).*?(?=</h1>)'

# Extract all H2 headings
curl -s "$ARTICLE_URL" | \
  grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)'

# Extract canonical URL
curl -s "$ARTICLE_URL" | \
  grep -oP '<link rel="canonical" href="\K[^"]*'

# Count internal links
curl -s "$ARTICLE_URL" | \
  grep -oP '<a href="[^"]*"' | wc -l

# Extract all image alt tags
curl -s "$ARTICLE_URL" | \
  grep -oP '<img[^>]*alt="\K[^"]*'
```

### Analyze Structured Data (Schema.org)

```bash
# Extract JSON-LD structured data
curl -s "$ARTICLE_URL" | \
  grep -Pzo '(?s)<script type="application/ld\+json">.*?</script>' | \
  sed 's/<script type="application\/ld+json">//; s/<\/script>//' > structured_data.json

# Validate JSON-LD (if jq is installed)
cat structured_data.json | jq '.' > /dev/null && echo "Valid JSON-LD" || echo "Invalid JSON-LD"
```

---

## Validate SEO Elements

### Check Page Load Speed

```bash
# Measure page load time
time curl -o /dev/null -s -w "Time: %{time_total}s\nSize: %{size_download} bytes\n" \
  "$ARTICLE_URL"
```

### Analyze Content Quality

```bash
# Word count (good for SEO ranking)
curl -s "$ARTICLE_URL" | \
  sed 's/<[^>]*>//g' | wc -w

# Keyword density (customize keywords for your article)
curl -s "$ARTICLE_URL" | \
  sed 's/<[^>]*>//g' | grep -io "YOUR_KEYWORD_HERE" | wc -l

# Check for duplicate content indicators
curl -s "$ARTICLE_URL" | \
  grep -i "rel=\"canonical\""
```

### Mobile Friendliness Check

```bash
# Fetch with mobile user agent
curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15" \
  "$ARTICLE_URL" > mobile_view.html

# Check viewport meta tag
curl -s "$ARTICLE_URL" | \
  grep -i "viewport"
```

---

## Monitor Crawl Performance

### Check robots.txt Compliance

```bash
# Fetch and analyze robots.txt (adjust domain as needed)
curl -s https://grokipedia.com/robots.txt

# Verify sitemap location
curl -s https://grokipedia.com/sitemap.xml | head -20
```

### Monitor Server Response

```bash
# Check HTTP status codes
curl -I "$ARTICLE_URL" | grep "HTTP/"

# Check for redirects
curl -L -I "$ARTICLE_URL" 2>&1 | grep -E "HTTP/|Location:"

# Check SSL/HTTPS security
curl -I "$ARTICLE_URL" 2>&1 | grep -i "strict-transport"
```

### Generate Crawl Report

```bash
# Create comprehensive crawl report for any article
cat > crawl_report.sh << 'EOF'
#!/bin/bash

# Usage: ./crawl_report.sh YOUR_ARTICLE_URL

URL="${1:-https://grokipedia.com/page/2012_Aurora_theater_shooting}"
REPORT="crawl_report_$(date +%Y%m%d_%H%M%S).txt"

echo "=== SEO Crawl Report ===" > $REPORT
echo "URL: $URL" >> $REPORT
echo "Date: $(date)" >> $REPORT
echo "" >> $REPORT

echo "--- HTTP Status ---" >> $REPORT
curl -I -s $URL | head -1 >> $REPORT
echo "" >> $REPORT

echo "--- Page Title ---" >> $REPORT
curl -s $URL | grep -oP '(?<=<title>).*?(?=</title>)' | head -1 >> $REPORT
echo "" >> $REPORT

echo "--- Meta Description ---" >> $REPORT
curl -s $URL | grep -oP '<meta name="description" content="\K[^"]*' >> $REPORT
echo "" >> $REPORT

echo "--- Word Count ---" >> $REPORT
curl -s $URL | sed 's/<[^>]*>//g' | wc -w >> $REPORT
echo "" >> $REPORT

echo "--- H1 Headings ---" >> $REPORT
curl -s $URL | grep -oP '(?<=<h1[^>]*>).*?(?=</h1>)' >> $REPORT
echo "" >> $REPORT

echo "--- Internal Links Count ---" >> $REPORT
curl -s $URL | grep -oP '<a href="[^"]*"' | wc -l >> $REPORT
echo "" >> $REPORT

echo "--- Load Time ---" >> $REPORT
curl -o /dev/null -s -w "Time: %{time_total}s\n" $URL >> $REPORT

echo "Report saved to: $REPORT"
cat $REPORT
EOF

chmod +x crawl_report.sh

# Run with your article URL
./crawl_report.sh "$ARTICLE_URL"
```

---

## Best Practices for First Page Ranking

### 1. Content Optimization
- Ensure 1500+ words of unique, high-quality content
- Use target keywords naturally (2-3% density)
- Include synonyms and related terms
- Add recent updates and citations

### 2. Technical SEO
- Fast page load time (<3 seconds)
- Mobile-responsive design
- HTTPS enabled
- Clean URL structure
- Proper heading hierarchy (H1 → H2 → H3)

### 3. On-Page Elements
- Unique, descriptive title (50-60 characters)
- Compelling meta description (150-160 characters)
- Descriptive alt text for all images
- Internal linking to related pages
- Canonical URL properly set

### 4. Structured Data
- Implement Schema.org Article markup
- Add JSON-LD structured data
- Include author, publication date, modified date

### 5. Backlinks and Authority
- Earn backlinks from reputable sources
- Submit to relevant directories
- Cross-reference with Wikipedia
- Share on social media platforms

---

## Quick Start Commands

Set your article URL first:
```bash
export ARTICLE_URL="https://grokipedia.com/page/YOUR_ARTICLE_NAME"
```

Then run:
```bash
# 1. Scrape current page
npm run scrape

# Or with specific URL:
node scrape.js "$ARTICLE_URL"

# 2. Generate crawl report
./crawl_report.sh "$ARTICLE_URL"

# 3. Test as Googlebot
curl -A "Mozilla/5.0 (compatible; Googlebot/2.1)" \
  "$ARTICLE_URL" > googlebot_test.html

# 4. Analyze SEO elements
curl -s "$ARTICLE_URL" | \
  grep -E "<title>|<meta name=\"description\"|<h1" | head -10

# 5. Check page speed
time curl -o /dev/null -s "$ARTICLE_URL"
```

Or use the built-in SEO analyzer:
```bash
# Use config.json
npm run analyze

# Or specify URL directly
./seo_analyzer.sh "$ARTICLE_URL"
```

---

## Resources

- **Google Search Console**: Submit sitemap and monitor performance
- **Bing Webmaster Tools**: Submit to Bing index
- **Schema.org**: Structured data guidelines
- **PageSpeed Insights**: Analyze page performance
- **Mobile-Friendly Test**: Check mobile compatibility

---

## Notes

- Be respectful of server resources (use crawl-delay)
- Test changes in staging before production
- Monitor Google Search Console for crawl errors
- Update content regularly for freshness signals
- Build quality backlinks over time for domain authority

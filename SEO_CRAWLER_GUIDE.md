# SEO Optimization and Web Crawler Guide

This guide provides command-line steps to improve search engine visibility and help the Grokipedia article rank on the first page alongside Wikipedia.

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
cat > sitemap.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://grokipedia.com/page/2012_Aurora_theater_shooting</loc>
    <lastmod>YYYY-MM-DD</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
EOF
```

**Note:** Update `YYYY-MM-DD` with the current date or use `$(date +%Y-%m-%d)` for dynamic generation.

---

## Test Search Engine Crawlers

### Simulate Googlebot Crawl

```bash
# Fetch page as Googlebot
curl -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting > googlebot_view.html

# Check response headers
curl -I -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting
```

### Simulate Bingbot Crawl

```bash
# Fetch page as Bingbot
curl -A "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting > bingbot_view.html
```

### Test Spider Crawl

```bash
# Recursive spider crawl with wget (test only - be respectful of server resources)
wget --spider -r -l 2 --user-agent="SEO-Spider/1.0" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting 2>&1 | tee spider_log.txt

# Alternative: Use curl to check link validity
curl -I --user-agent="SEO-Spider/1.0" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting
```

---

## Analyze Page Structure

### Extract SEO-Critical Elements

```bash
# Extract title tag
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '(?<=<title>).*?(?=</title>)' | head -1

# Extract meta description
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '<meta name="description" content="\K[^"]*' | head -1

# Extract all H1 headings
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '(?<=<h1[^>]*>).*?(?=</h1>)'

# Extract all H2 headings
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '(?<=<h2[^>]*>).*?(?=</h2>)'

# Extract canonical URL
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '<link rel="canonical" href="\K[^"]*'

# Count internal links
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '<a href="[^"]*"' | wc -l

# Extract all image alt tags
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -oP '<img[^>]*alt="\K[^"]*'
```

### Analyze Structured Data (Schema.org)

```bash
# Extract JSON-LD structured data
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
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
  https://grokipedia.com/page/2012_Aurora_theater_shooting
```

### Analyze Content Quality

```bash
# Word count (good for SEO ranking)
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  sed 's/<[^>]*>//g' | wc -w

# Keyword density for "Aurora theater shooting"
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  sed 's/<[^>]*>//g' | grep -io "aurora theater shooting" | wc -l

# Check for duplicate content indicators
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -i "rel=\"canonical\""
```

### Mobile Friendliness Check

```bash
# Fetch with mobile user agent
curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting > mobile_view.html

# Check viewport meta tag
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -i "viewport"
```

---

## Monitor Crawl Performance

### Check robots.txt Compliance

```bash
# Fetch and analyze robots.txt
curl -s https://grokipedia.com/robots.txt

# Verify sitemap location
curl -s https://grokipedia.com/sitemap.xml | head -20
```

### Monitor Server Response

```bash
# Check HTTP status codes
curl -I https://grokipedia.com/page/2012_Aurora_theater_shooting | grep "HTTP/"

# Check for redirects
curl -L -I https://grokipedia.com/page/2012_Aurora_theater_shooting 2>&1 | grep -E "HTTP/|Location:"

# Check SSL/HTTPS security
curl -I https://grokipedia.com/page/2012_Aurora_theater_shooting 2>&1 | grep -i "strict-transport"
```

### Generate Crawl Report

```bash
# Create comprehensive crawl report
cat > crawl_report.sh << 'EOF'
#!/bin/bash
URL="https://grokipedia.com/page/2012_Aurora_theater_shooting"
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
./crawl_report.sh
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

```bash
# 1. Scrape current page
npm run scrape

# 2. Generate crawl report
./crawl_report.sh

# 3. Test as Googlebot
curl -A "Mozilla/5.0 (compatible; Googlebot/2.1)" \
  https://grokipedia.com/page/2012_Aurora_theater_shooting > googlebot_test.html

# 4. Analyze SEO elements
curl -s https://grokipedia.com/page/2012_Aurora_theater_shooting | \
  grep -E "<title>|<meta name=\"description\"|<h1" | head -10

# 5. Check page speed
time curl -o /dev/null -s https://grokipedia.com/page/2012_Aurora_theater_shooting
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

# Grokipedia SEO Tool

A universal tool for scraping and analyzing any Grokipedia or Wikipedia article for SEO optimization. Designed for use by humans and AI agents (like GitHub Copilot or Grok) to help articles rank on the first page of search results.

## Purpose
This repository contains tools for scraping and analyzing Grokipedia pages. The tool helps optimize pages for search engine ranking through comprehensive SEO analysis and crawler testing.

## ✨ Key Features

- **Multi-method Scraping**: Automatically tries direct access, Wayback Machine archives, and screenshot fallback
- **Firewall/Paywall Workaround**: Works around access restrictions using archived data
- **SEO Analysis**: Comprehensive analysis of page structure and optimization
- **Universal**: Works with any Grokipedia or Wikipedia article
- **AI Agent Ready**: Designed for automated use by AI tools

## Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Your Article
Edit `config.json` to set your target article:
```json
{
  "url": "https://grokipedia.com/page/YOUR_ARTICLE_NAME",
  "articleName": "Your Article Name",
  "outputDir": "seo_reports",
  "scrapeOutput": "scrape.html"
}
```

Or use command-line arguments (see Usage section below).

### 3. Scrape Grokipedia Content
```bash
# Use config.json
npm run scrape

# Or specify URL directly
node scrape.js https://grokipedia.com/page/YOUR_ARTICLE_NAME
```

### 4. Run SEO Analysis
```bash
# Use config.json
npm run analyze

# Or specify URL directly
./seo_analyzer.sh https://grokipedia.com/page/YOUR_ARTICLE_NAME
```

This will:
- Analyze page structure and SEO elements
- Test crawler compatibility (Googlebot, Bingbot)
- Generate comprehensive SEO report
- Provide optimization recommendations

## 🔥 Firewall & Paywall Workaround

The tool automatically handles access restrictions with a three-tier approach:

1. **Direct Access**: Tries to fetch the page normally
2. **Wayback Machine**: Falls back to the most recent archived snapshot from archive.org
3. **Screenshot Fallback**: Captures a visual screenshot if all else fails

### Manual Wayback Machine Scraping

Use the dedicated CLI tool to fetch archived content:

```bash
./wayback_scrape.sh https://grokipedia.com/page/ARTICLE_NAME
./wayback_scrape.sh https://example.com/paywalled-article output.html
```

This is useful for:
- Getting around corporate firewalls
- Accessing paywalled content (archived versions)
- Retrieving deleted or modified content
- Ensuring consistent historical data

## Usage

### Method 1: Using Configuration File (Recommended)

1. Edit `config.json`:
```json
{
  "url": "https://grokipedia.com/page/Albert_Einstein",
  "articleName": "Albert Einstein",
  "outputDir": "seo_reports",
  "scrapeOutput": "scrape.html"
}
```

2. Run the tools:
```bash
npm run scrape
npm run analyze
```

### Method 2: Command-Line Arguments

Scrape any article:
```bash
node scrape.js https://grokipedia.com/page/Albert_Einstein
node scrape.js https://grokipedia.com/page/World_War_II
node scrape.js https://en.wikipedia.org/wiki/Quantum_mechanics
```

Analyze any URL:
```bash
./seo_analyzer.sh https://grokipedia.com/page/Albert_Einstein
./seo_analyzer.sh https://grokipedia.com/page/World_War_II
```

### Example: Different Articles

The `examples/` directory contains pre-configured settings for different articles:

```bash
# Use an example configuration
cp examples/albert_einstein_config.json config.json
npm run scrape
npm run analyze

# Or use them directly
node scrape.js --config=examples/world_war_ii_config.json
./seo_analyzer.sh --config=examples/quantum_mechanics_config.json
```

See [examples/README.md](examples/README.md) for more details.

Quick examples using direct URLs:

```bash
# Scrape and analyze a science article
node scrape.js https://grokipedia.com/page/Quantum_mechanics
./seo_analyzer.sh https://grokipedia.com/page/Quantum_mechanics

# Scrape and analyze a historical event
node scrape.js https://grokipedia.com/page/Moon_landing
./seo_analyzer.sh https://grokipedia.com/page/Moon_landing

# Scrape and analyze a biography
node scrape.js https://grokipedia.com/page/Marie_Curie
./seo_analyzer.sh https://grokipedia.com/page/Marie_Curie
```

## SEO & Crawler Optimization

See **[SEO_CRAWLER_GUIDE.md](SEO_CRAWLER_GUIDE.md)** for comprehensive documentation on:
- Search engine crawler testing (Googlebot, Bingbot, spider crawl)
- SEO element validation and optimization
- Command-line tools for improving search rankings
- Best practices for first-page ranking alongside Wikipedia

### Quick SEO Commands

Replace `YOUR_ARTICLE_URL` with your target article:

```bash
# Test as Googlebot
curl -A "Mozilla/5.0 (compatible; Googlebot/2.1)" \
  YOUR_ARTICLE_URL > googlebot_test.html

# Analyze SEO elements
curl -s YOUR_ARTICLE_URL | \
  grep -E "<title>|<meta name=\"description\"|<h1" | head -10

# Check page speed
time curl -o /dev/null -s YOUR_ARTICLE_URL
```

## Usage

### Scraping with curl
```bash
# Replace YOUR_ARTICLE_NAME with your target article
curl https://grokipedia.com/page/YOUR_ARTICLE_NAME > scrape.html
```

Or extract specific elements:
```bash
curl https://grokipedia.com/page/YOUR_ARTICLE_NAME 2>/dev/null | \
  grep -oP '(?<=<p[^>]*>).*?(?=</p>)'
```

### Using Puppeteer Script
```bash
# Use config.json
node scrape.js

# Or specify URL directly
node scrape.js https://grokipedia.com/page/YOUR_ARTICLE_NAME
```

## Configuration

The `config.json` file controls the default behavior of the tool:

```json
{
  "url": "https://grokipedia.com/page/2012_Aurora_theater_shooting",
  "articleName": "2012 Aurora Theater Shooting",
  "outputDir": "seo_reports",
  "scrapeOutput": "scrape.html"
}
```

### Configuration Options

- **url**: The Grokipedia or Wikipedia article URL to analyze
- **articleName**: Human-readable name for the article (used in reports)
- **outputDir**: Directory where SEO analysis reports are saved (default: `seo_reports`)
- **scrapeOutput**: Filename for scraped HTML content (default: `scrape.html`)

### Priority Order

The tool uses this priority for determining which URL to use:

1. Command-line argument (highest priority)
2. Config file specified with `--config=path/to/config.json`
3. Default `config.json` in the root directory
4. Fallback to hardcoded default URL (lowest priority)

This allows maximum flexibility for different use cases.

## Files

### Core Files
- `scrape.js` - Puppeteer script with automatic firewall/paywall workarounds
- `scrape.html` - Template/output file for scraped content
- `config.json` - Configuration file for article URL and settings
- `package.json` - Node.js dependencies

### SEO Tools
- `SEO_CRAWLER_GUIDE.md` - Comprehensive SEO and crawler optimization guide
- `seo_analyzer.sh` - Automated SEO analysis script (works with any URL)
- `wayback_scrape.sh` - CLI tool for manual Wayback Machine scraping
- `seo_reports/` - Generated SEO analysis reports (gitignored)

### Testing
- `test_tool.sh` - Test suite for verifying tool functionality

### Configuration
- `.gitignore` - Excludes node_modules, reports, and temporary files
- `README.md` - This file

## SEO Optimization Features

The SEO analyzer checks:
- ✅ HTTP status and accessibility
- ✅ Title tag optimization (50-60 characters)
- ✅ Meta description (150-160 characters)
- ✅ Heading structure (H1, H2, H3 hierarchy)
- ✅ Content length (1500+ words recommended)
- ✅ Page load speed (<3 seconds)
- ✅ Internal linking
- ✅ Image alt text optimization
- ✅ Mobile-friendliness (viewport meta tag)
- ✅ Structured data (JSON-LD)
- ✅ HTTPS security
- ✅ Crawler compatibility (Googlebot, Bingbot)

## URL Namespace

The tool is designed to work with any Grokipedia or Wikipedia article. Simply configure the URL in `config.json` or pass it as a command-line argument. The repository name references a specific article but the tool itself is universal.

## Default Configuration

The tool comes pre-configured with the 2012 Aurora theater shooting article as a default example:
- URL: `https://grokipedia.com/page/2012_Aurora_theater_shooting`
- This is just a default - you can analyze any article by changing `config.json` or using command-line arguments

## Contributing to First-Page Ranking

To help any Grokipedia article rank on the first page:

1. **Content Quality**: Ensure 1500+ words of unique, well-researched content
2. **Technical SEO**: Fast load times, mobile-responsive, HTTPS enabled
3. **On-Page Optimization**: Proper title, meta description, heading hierarchy
4. **Structured Data**: Implement Schema.org Article markup
5. **Regular Updates**: Keep content fresh with recent information
6. **Backlinks**: Build quality backlinks from reputable sources

Run `./seo_analyzer.sh YOUR_ARTICLE_URL` regularly to monitor SEO score and identify improvements.

## AI Agent Integration

This tool is designed to be used by AI agents like GitHub Copilot or Grok:

1. **Configure**: Set the target article in `config.json`
2. **Analyze**: Run `npm run analyze` to get SEO insights
3. **Optimize**: Use the recommendations to improve content and structure
4. **Monitor**: Re-run analysis after changes to track improvements

AI agents can use this tool to:
- Automatically analyze multiple articles
- Generate SEO reports for comparison
- Identify optimization opportunities
- Track ranking improvements over time

## Resources

- [Google Search Console](https://search.google.com/search-console) - Submit sitemap and monitor performance
- [Bing Webmaster Tools](https://www.bing.com/webmasters/) - Submit to Bing index
- [Schema.org](https://schema.org/) - Structured data guidelines
- [PageSpeed Insights](https://pagespeed.web.dev/) - Analyze page performance

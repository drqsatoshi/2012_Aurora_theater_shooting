# 2012_Aurora_theater_shooting

Grokipedia URL: https://grokipedia.com/page/2012_Aurora_theater_shooting

## Purpose
This repository contains tools for scraping and analyzing the Grokipedia page about the 2012 Aurora theater shooting. The scrape.html file is used for testing and SEO optimization purposes.

## Usage

### Install Dependencies
```bash
npm install
```

### Scrape Grokipedia Content
```bash
npm run scrape
```

This will fetch the content from https://grokipedia.com/page/2012_Aurora_theater_shooting and save it to `scrape.html`.

### Alternative: Using curl
```bash
curl https://grokipedia.com/page/2012_Aurora_theater_shooting > scrape.html
```

Or extract specific elements:
```bash
curl https://grokipedia.com/page/2012_Aurora_theater_shooting 2>/dev/null | grep -oP '(?<=<p[^>]*>).*?(?=</p>)'
```

## Files
- `scrape.js` - Puppeteer script to scrape Grokipedia page
- `scrape.html` - Template/output file for scraped content
- `package.json` - Node.js dependencies

## URL Namespace
The namespace has been updated from `2012_Aurora_shooting` to `2012_Aurora_theater_shooting` to match the repository name and improve SEO alignment with Wikipedia and other sources.

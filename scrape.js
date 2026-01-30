// Puppeteer scraping script for Grokipedia pages
// Usage: node scrape.js [URL] [--config=path/to/config.json]

const fs = require('fs');
const path = require('path');
const https = require('https');

// Load configuration
function loadConfig() {
  const args = process.argv.slice(2);
  const configArg = args.find(arg => arg.startsWith('--config='));
  const configPath = configArg 
    ? configArg.split('=')[1] 
    : path.join(__dirname, 'config.json');
  
  if (fs.existsSync(configPath)) {
    return JSON.parse(fs.readFileSync(configPath, 'utf8'));
  }
  return {
    url: 'https://grokipedia.com/page/2012_Aurora_theater_shooting',
    scrapeOutput: 'scrape.html'
  };
}

// Get the latest Wayback Machine snapshot URL for a given URL
async function getWaybackUrl(originalUrl) {
  const availabilityUrl = `https://archive.org/wayback/available?url=${encodeURIComponent(originalUrl)}`;
  
  return new Promise((resolve, reject) => {
    https.get(availabilityUrl, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.archived_snapshots && json.archived_snapshots.closest && json.archived_snapshots.closest.available) {
            resolve(json.archived_snapshots.closest.url);
          } else {
            resolve(null);
          }
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function scrapeGrokipedia(customUrl = null) {
  // Lazy load puppeteer only when needed
  const puppeteer = require('puppeteer');
  
  const config = loadConfig();
  // Priority: customUrl parameter > command-line arg > config > fallback
  const urlArg = process.argv.find(arg => !arg.startsWith('--') && arg !== process.argv[0] && arg !== process.argv[1]);
  const originalUrl = customUrl || urlArg || config.url;
  
  console.log(`Scraping: ${originalUrl}`);
  
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    const page = await browser.newPage();
    let html = null;
    let scrapedUrl = originalUrl;
    let scrapeMethod = 'direct';
    
    // Try direct access first
    try {
      console.log('Attempting direct access...');
      await page.goto(originalUrl, { waitUntil: 'networkidle2', timeout: 30000 });
      html = await page.content();
      console.log('✓ Direct access successful');
    } catch (directError) {
      console.warn(`⚠ Direct access failed: ${directError.message}`);
      
      // Try Wayback Machine
      try {
        console.log('Attempting to fetch from Wayback Machine...');
        const waybackUrl = await getWaybackUrl(originalUrl);
        if (waybackUrl) {
          console.log(`Found archived version: ${waybackUrl}`);
          await page.goto(waybackUrl, { waitUntil: 'networkidle2', timeout: 30000 });
          html = await page.content();
          scrapedUrl = waybackUrl;
          scrapeMethod = 'wayback';
          console.log('✓ Wayback Machine access successful');
        } else {
          throw new Error('No archived version found');
        }
      } catch (waybackError) {
        console.warn(`⚠ Wayback Machine failed: ${waybackError.message}`);
        
        // Fall back to screenshot
        console.log('Falling back to screenshot...');
        try {
          await page.goto(originalUrl, { waitUntil: 'domcontentloaded', timeout: 15000 }).catch(() => {
            // Ignore navigation errors for screenshot
          });
          
          const screenshotPath = config.scrapeOutput ? 
            config.scrapeOutput.replace('.html', '_screenshot.png') : 
            'scrape_screenshot.png';
          
          await page.screenshot({ 
            path: screenshotPath,
            fullPage: true 
          });
          
          scrapeMethod = 'screenshot';
          console.log(`✓ Screenshot saved to ${screenshotPath}`);
          
          // Create minimal HTML pointing to screenshot
          html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Screenshot of ${originalUrl}</title>
</head>
<body>
  <h1>Content captured via screenshot</h1>
  <p>Original URL: <a href="${originalUrl}">${originalUrl}</a></p>
  <p>Screenshot saved to: ${screenshotPath}</p>
  <p>The page could not be scraped directly due to firewall/paywall restrictions.</p>
  <img src="${screenshotPath}" alt="Screenshot of page" style="max-width: 100%; border: 1px solid #ccc;">
</body>
</html>`;
        } catch (screenshotError) {
          throw new Error(`All scraping methods failed. Last error: ${screenshotError.message}`);
        }
      }
    }
    
    // Save to configured output file
    const outputFile = config.scrapeOutput || 'scrape.html';
    fs.writeFileSync(outputFile, html, 'utf8');
    console.log(`\n✓ Content saved to ${outputFile}`);
    console.log(`  Method used: ${scrapeMethod}`);
    console.log(`  Source URL: ${scrapedUrl}`);
    
    // Extract key elements for analysis (skip for screenshot-only)
    if (scrapeMethod !== 'screenshot') {
      const data = await page.evaluate(() => {
        const title = document.querySelector('h1')?.textContent || 'No title found';
        const paragraphs = Array.from(document.querySelectorAll('p')).map(p => p.textContent.trim());
        const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6')).map(h => ({
          tag: h.tagName,
          text: h.textContent.trim()
        }));
        
        return { title, paragraphs, headings };
      });
      
      console.log('\nPage Title:', data.title);
      console.log('Found', data.paragraphs.length, 'paragraphs');
      console.log('Found', data.headings.length, 'headings');
    }
    
  } catch (error) {
    console.error('✗ Error scraping page:', error.message);
    throw error;
  } finally {
    await browser.close();
  }
}

// Run if called directly
if (require.main === module) {
  // Check for help flag
  const args = process.argv.slice(2);
  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
Grokipedia Scraper - Universal tool for scraping any Grokipedia/Wikipedia article

Usage:
  node scrape.js [URL] [--config=path/to/config.json]

Features:
  - Direct page scraping with Puppeteer
  - Automatic fallback to Wayback Machine for archived content
  - Screenshot capture for firewall/paywall-protected pages

Examples:
  # Use default config.json
  node scrape.js

  # Scrape a specific URL
  node scrape.js https://grokipedia.com/page/Albert_Einstein

  # Use a custom config file
  node scrape.js --config=examples/albert_einstein_config.json

  # Scrape specific URL with custom config
  node scrape.js https://grokipedia.com/page/Marie_Curie --config=myconfig.json

Options:
  --config=PATH    Path to configuration file (default: config.json)
  --help, -h       Show this help message

Firewall/Paywall Handling:
  The tool automatically attempts multiple methods to get content:
  1. Direct access - tries to fetch the page directly
  2. Wayback Machine - fetches the most recent archived snapshot
  3. Screenshot - captures a visual screenshot as last resort

Configuration (config.json):
  {
    "url": "https://grokipedia.com/page/ARTICLE_NAME",
    "articleName": "Article Display Name",
    "outputDir": "seo_reports",
    "scrapeOutput": "scrape.html"
  }

For more information, see README.md
`);
    process.exit(0);
  }
  
  scrapeGrokipedia().catch(console.error);
}

module.exports = scrapeGrokipedia;

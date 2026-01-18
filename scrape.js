// Puppeteer scraping script for Grokipedia pages
// Usage: node scrape.js [URL] [--config=path/to/config.json]

const fs = require('fs');
const path = require('path');

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

async function scrapeGrokipedia(customUrl = null) {
  // Lazy load puppeteer only when needed
  const puppeteer = require('puppeteer');
  
  const config = loadConfig();
  // Priority: customUrl parameter > command-line arg > config > fallback
  const urlArg = process.argv.find(arg => !arg.startsWith('--') && arg !== process.argv[0] && arg !== process.argv[1]);
  const url = customUrl || urlArg || config.url;
  
  console.log(`Scraping: ${url}`);
  
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  try {
    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
    
    // Get the full HTML content
    const html = await page.content();
    
    // Save to configured output file
    const outputFile = config.scrapeOutput || 'scrape.html';
    fs.writeFileSync(outputFile, html, 'utf8');
    console.log(`Content saved to ${outputFile}`);
    
    // Extract key elements for analysis
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
    console.log('\nFound', data.paragraphs.length, 'paragraphs');
    console.log('Found', data.headings.length, 'headings');
    
  } catch (error) {
    console.error('Error scraping page:', error.message);
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

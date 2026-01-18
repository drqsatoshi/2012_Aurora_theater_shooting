// Puppeteer scraping script for Grokipedia pages
// Usage: node scrape.js [URL] [--config=path/to/config.json]

const puppeteer = require('puppeteer');
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
  const config = loadConfig();
  const url = customUrl || process.argv[2] || config.url;
  
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
    const config = loadConfig();
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
  scrapeGrokipedia().catch(console.error);
}

module.exports = scrapeGrokipedia;

// Puppeteer scraping script for Grokipedia pages
// Usage: node scrape.js

const puppeteer = require('puppeteer');
const fs = require('fs');

async function scrapeGrokipedia() {
  const url = 'https://grokipedia.com/page/2012_Aurora_theater_shooting';
  
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
    
    // Save to scrape.html
    fs.writeFileSync('scrape.html', html, 'utf8');
    console.log('Content saved to scrape.html');
    
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

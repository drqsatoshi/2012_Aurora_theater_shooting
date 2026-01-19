# Example Configurations

This directory contains example configuration files for different Grokipedia articles.

## Usage

To use an example configuration:

1. Copy the example to the root directory as `config.json`:
   ```bash
   cp examples/albert_einstein_config.json config.json
   ```

2. Run the tools:
   ```bash
   npm run scrape
   npm run analyze
   ```

## Available Examples

- **albert_einstein_config.json** - Configuration for Albert Einstein article
- **world_war_ii_config.json** - Configuration for World War II article  
- **quantum_mechanics_config.json** - Configuration for Quantum Mechanics article

## Creating Your Own

Create a new config file following this template:

```json
{
  "url": "https://grokipedia.com/page/YOUR_ARTICLE_NAME",
  "articleName": "Your Article Display Name",
  "outputDir": "seo_reports",
  "scrapeOutput": "scrape_your_article.html"
}
```

## Using Custom Configs

You can use a custom config without copying to root:

```bash
# Scraping
node scrape.js --config=examples/albert_einstein_config.json

# SEO Analysis
./seo_analyzer.sh --config=examples/albert_einstein_config.json
```

Or use URLs directly:

```bash
node scrape.js https://grokipedia.com/page/YOUR_ARTICLE
./seo_analyzer.sh https://grokipedia.com/page/YOUR_ARTICLE
```

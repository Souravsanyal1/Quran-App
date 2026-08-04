const { chromium } = require('playwright');
const path = require('path');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
  });
  const page = await context.newPage();

  const results = [];

  // Test 1: Home page
  console.log('--- Test 1: Loading home page ---');
  await page.goto('http://localhost:8788/#/home', { waitUntil: 'networkidle', timeout: 15000 }).catch(e => console.log('Nav note:', e.message));
  await page.waitForTimeout(5000);
  const url1 = page.url();
  const title1 = await page.title();
  await page.screenshot({ path: 'screenshot_home.png', fullPage: true });
  console.log('URL:', url1);
  console.log('Title:', title1);
  results.push({ test: 'Home Page', url: url1, title: title1, screenshot: 'screenshot_home.png' });

  // Test 2: Check if redirected to splash/login
  await page.goto('http://localhost:8788', { waitUntil: 'networkidle', timeout: 15000 }).catch(() => {});
  await page.waitForTimeout(5000);
  const url2 = page.url();
  await page.screenshot({ path: 'screenshot_root.png', fullPage: true });
  console.log('Root URL redirect:', url2);
  results.push({ test: 'Root URL', url: url2, screenshot: 'screenshot_root.png' });

  // Test 3: Get visible text on page
  const visibleText = await page.evaluate(() => {
    const elements = document.querySelectorAll('flt-semantics, flt-scene, canvas');
    return `Elements found: flt-semantics=${document.querySelectorAll('flt-semantics').length}, canvas=${document.querySelectorAll('canvas').length}`;
  });
  console.log('Flutter Elements:', visibleText);

  // Test 4: Check for errors in console
  const errors = [];
  page.on('console', msg => {
    if (msg.type() === 'error') errors.push(msg.text());
  });

  await page.goto('http://localhost:8788/#/home');
  await page.waitForTimeout(4000);
  await page.screenshot({ path: 'screenshot_final.png', fullPage: true });

  console.log('\n=== RESULTS ===');
  results.forEach(r => console.log(JSON.stringify(r)));
  console.log('Console errors:', errors.join(', ') || 'None');

  await browser.close();
  console.log('DONE');
})();

// Tests only the local design fragment. Does not connect to TLBB or start a game.
const fs = require('node:fs');
const path = require('node:path');
const {pathToFileURL} = require('node:url');
const {chromium} = require('C:/Users/liqia/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root = path.resolve(__dirname, '..');
const out = path.join(root, 'artifacts/ui-design');
const checks = [], errors = [], requests = [];
function assert(value, label) { if (!value) throw new Error(label); }
async function test(label, run) { await run(); checks.push({name: label, passed: true}); console.log('PASS '+label); }

(async () => {
  const browser = await chromium.launch({executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', headless: true});
  try {
    const context = await browser.newContext({viewport: {width: 1120, height: 1050}, deviceScaleFactor: 1});
    await context.route(/^https?:/, route => { requests.push(route.request().url()); return route.abort(); });
    const page = await context.newPage();
    page.on('pageerror', e => errors.push(String(e)));
    await page.goto(pathToFileURL(path.join(out, 'preview.html')).href);
    const frame = page.frameLocator('iframe');
    await frame.locator('#tlbb-design').waitFor();
    const action = name => frame.locator(`[data-action="${name}"]`);
    const tab = name => frame.getByRole('tab', {name, exact: true}).click();
    const role = name => frame.getByRole('button', {name: new RegExp('^'+name+' ·')}).click();
    const text = async () => frame.locator('#tl-panel').innerText();
    const nodeTitles = async () => frame.locator('.tl-node-name').allTextContents();
    const copy = async (scopes, mode='replace', target='role-b') => {
      await action('copy').click();
      await frame.locator(`[data-copy-target="${target}"]`).check();
      for(const name of ['queue','battle','loot','supply']) await frame.locator(`[data-copy-scope="${name}"]`).setChecked(scopes.includes(name));
      await frame.locator('[data-copy-mode]').selectOption(mode);
      assert(await action('copy-apply').isDisabled(), 'Copy must require a fresh preview');
      await action('copy-preview').click();
      const diff = await frame.locator('.tl-dialog .tl-result').innerText();
      await action('copy-apply').click();
      return diff;
    };

    await test('Six main pages and all three independent sample profiles render', async () => {
      assert(await frame.getByRole('tab').count() === 6, 'Expected six tabs');
      assert(await frame.locator('.tl-role').count() === 3, 'Expected three sample configurations');
      for(const name of ['执行台','任务库','流程编排','战斗技能','拾取后勤','登录角色']) {
        await tab(name); assert((await text()).length > 30, 'Empty page: '+name);
      }
      assert(await frame.locator('input[type=password]').count() === 0, 'Do not collect credentials');
    });
    await test('Unsupported queue items block execution; valid movement parameters pass only design checks', async () => {
      await tab('流程编排');
      await action('preflight').click();
      let result = await frame.locator('[data-check-result]').innerText();
      assert(result.includes('尚不可执行') && result.includes('种植') && result.includes('燕子坞'), 'Expected unsupported task reasons');
      for(const label of ['启用 种植','启用 师门任务','启用 燕子坞']) await frame.getByRole('checkbox', {name:label,exact:true}).uncheck();
      await action('preflight').click();
      assert((await frame.locator('[data-check-result]').innerText()).includes('示例参数检查通过'), 'Expected movement-only design validation');
      await frame.getByRole('spinbutton',{name:'目标 X',exact:true}).fill('-1');
      await action('preflight').click();
      assert((await frame.locator('[data-check-result]').innerText()).includes('参数无效'), 'Negative coordinate should fail');
      await frame.getByRole('spinbutton',{name:'目标 X',exact:true}).fill('360');
    });
    await test('Role selection isolates queue and parameters', async () => {
      await role('角色乙'); assert((await nodeTitles()).length === 2, 'Role B queue changed unexpectedly');
      await role('角色甲'); assert((await nodeTitles()).length === 4, 'Role A queue was lost');
      assert(await frame.getByRole('spinbutton',{name:'目标 X',exact:true}).inputValue() === '360', 'Edited coordinate did not persist locally');
    });
    await test('Library search supports aliases and each category; adding/reordering/removing nodes works', async () => {
      await tab('任务库');
      for(const name of ['副本','日常','限时','生活','野外','工具']) {
        await frame.locator(`[data-action="category"][data-id="${name}"]`).click();
        assert(await frame.locator('.tl-library-item').count() > 0, 'Empty category: '+name);
      }
      await frame.locator('[data-action="category"][data-id="全部"]').click();
      await frame.getByRole('textbox',{name:'搜索任务',exact:true}).fill('刷小');
      assert((await text()).includes('偷袭门派'), 'Alias search failed');
      await frame.getByRole('textbox',{name:'搜索任务',exact:true}).fill('钓鱼');
      await action('add').click();
      assert((await nodeTitles()).at(-1).includes('钓鱼'), 'Task not appended');
      await frame.locator('.tl-node').last().locator('[data-action=up]').click();
      assert((await nodeTitles()).at(-2).includes('钓鱼'), 'Task did not move');
      await frame.locator('.tl-node.tl-selected [data-action=remove]').click();
      assert((await nodeTitles()).length === 4, 'Task not removed');
    });
    await test('Destruction requires preview, protects task items and resets when rules change', async () => {
      await tab('拾取后勤');
      await frame.locator('[data-action="logistics-tab"][data-id="bag"]').click();
      await frame.locator('[data-loot=destroy]').click();
      assert(!(await frame.locator('[data-loot=destroy]').isChecked()), 'Destruction enabled without preview');
      await action('preview-destroy').click();
      assert((await frame.locator('[data-destroy-preview]').innerText()).includes('任务物品，保留'), 'Protected task item missing');
      await frame.locator('[data-loot=destroy]').check();
      assert(await frame.locator('[data-loot=destroy]').isChecked(), 'Preview should permit local enable');
      await frame.locator('[data-loot=whitelist]').fill('示例：低价值材料');
      assert(!(await frame.locator('[data-loot=destroy]').isChecked()), 'Rule change must disable destruction');
      assert(await frame.locator('[data-destroy-preview]').count() === 0, 'Stale preview remains');
      await action('preview-destroy').click();
      await frame.locator('[data-loot=destroy]').check();
    });
    await test('Batch copy previews differences, skips different-school battle rules and retains login identity', async () => {
      await tab('战斗技能');
      await frame.locator('[data-battle=heal]').fill('45');
      const diff = await copy(['queue','battle','loot']);
      assert(diff.includes('门派不同，跳过战斗配置'), 'School conflict not described');
      await role('角色乙');
      await tab('战斗技能'); assert(await frame.locator('[data-battle=heal]').inputValue() === '60', 'Incompatible school rules copied');
      await tab('流程编排'); assert((await nodeTitles()).length === 4, 'Queue copy failed');
      await tab('拾取后勤'); await frame.locator('[data-action="logistics-tab"][data-id="bag"]').click();
      assert(!(await frame.locator('[data-loot=destroy]').isChecked()), 'Copied destruction should be disabled');
      assert(await frame.locator('[data-destroy-preview]').count() === 0, 'Target must preview independently');
      await tab('登录角色');
      assert((await frame.getByRole('textbox',{name:'账号方案',exact:true}).inputValue()).includes('方案乙'), 'Copied source account reference');
      assert((await frame.getByRole('textbox',{name:'角色匹配名称',exact:true}).inputValue()).includes('角色乙'), 'Copied source login identity');
    });
    await test('Copied queue is a deep copy; fill-empty mode retains an existing target queue', async () => {
      await role('角色甲');await tab('流程编排');
      await frame.locator('.tl-node-name').first().click();
      await frame.locator('[data-param=x]').fill('361');
      await role('角色乙');
      await frame.locator('.tl-node-name').first().click();
      assert(await frame.locator('[data-param=x]').inputValue() === '360', 'Copied parameters share source reference');
      await role('角色甲');
      await frame.locator('.tl-node').last().locator('[data-action=remove]').click();
      const diff = await copy(['queue'],'fill');
      assert(diff.includes('已有内容，保持原值'), 'Fill mode should report skipped values');
      await role('角色乙');assert((await nodeTitles()).length === 4, 'Fill mode overwrote existing queue');
    });
    await test('All main pages fit 1024, 736 and 320 pixel widths without horizontal overflow', async () => {
      await role('角色甲');
      for(const width of [1024,736,320]) {
        await page.setViewportSize({width,height:1050});
        for(const name of ['执行台','任务库','流程编排','战斗技能','拾取后勤','登录角色']) {
          await tab(name);
          const box = await frame.locator('#tlbb-design').evaluate(el=>({width:el.getBoundingClientRect().width,scroll:el.scrollWidth,doc:document.documentElement.scrollWidth,available:document.documentElement.clientWidth}));
          assert(box.scroll <= Math.ceil(box.width)+1 && box.doc<=box.available+1, `${width}px ${name} overflow: ${JSON.stringify(box)}`);
        }
        await tab('流程编排');
        const contentFrame = page.frames().find(f => f.parentFrame() === page.mainFrame());
        const actualHeight = await frame.locator('#tlbb-design').evaluate(el=>Math.ceil(el.getBoundingClientRect().height)+32);
        // The standalone shell can retain a stale viewport-sized frame during rapid
        // automated tab/width changes. Size only the inspection wrapper to content.
        await page.locator('iframe').evaluate((el,height)=>{el.style.height=height+'px';el.scrolling='no';},actualHeight);
        await contentFrame.evaluate(()=>scrollTo(0,0));
        await page.evaluate(()=>scrollTo(0,0));
        await page.screenshot({path:path.join(out,`queue-${width}.png`),fullPage:true});
        await action('copy').click();
        const dialog = await frame.locator('.tl-dialog').evaluate(el=>({left:el.getBoundingClientRect().left,right:el.getBoundingClientRect().right,available:document.documentElement.clientWidth}));
        assert(dialog.left>=0 && dialog.right<=dialog.available+1,'Copy dialog overflow');
        await action('close-copy').click();
      }
    });
    const wrapperDependencies = [
      'https://unpkg.com/@floating-ui/dom@1.7.4/dist/floating-ui.dom.umd.min.js',
      'https://unpkg.com/lucide@1.17.0/dist/umd/lucide.js'
    ];
    const prototypeRequests = requests.filter(url => !wrapperDependencies.includes(url));
    await test('Dark appearance renders and no runtime errors or prototype network requests occur', async () => {
      await page.setViewportSize({width:1120,height:1050});
      await page.emulateMedia({colorScheme:'dark'});
      await tab('任务库');
      await frame.getByRole('textbox',{name:'搜索任务',exact:true}).fill('');
      const libraryHeight = await frame.locator('#tlbb-design').evaluate(el=>Math.ceil(el.getBoundingClientRect().height)+32);
      await page.locator('iframe').evaluate((el,height)=>{el.style.height=height+'px';el.scrolling='no';},libraryHeight);
      await page.frames().find(f => f.parentFrame() === page.mainFrame()).evaluate(()=>scrollTo(0,0));
      await page.evaluate(()=>scrollTo(0,0));
      await page.screenshot({path:path.join(out,'library-dark.png'),fullPage:true});
      assert(errors.length===0, 'Runtime errors: '+errors.join('; '));
      assert(prototypeRequests.length===0, 'Unexpected prototype network requests: '+prototypeRequests.join('; '));
    });
    // Capture the fragment directly as a separate QA surface, so the preview
    // wrapper's asynchronous iframe height changes cannot crop exported evidence.
    const visualPage = await context.newPage();
    const fragment = fs.readFileSync(path.join(root,'design/prototype/tlbb-workbench.html'),'utf8');
    await visualPage.setContent('<meta charset="utf-8"><style>html{color-scheme:light dark}body{margin:16px}</style>'+fragment);
    await visualPage.locator('#tlbb-design').waitFor();
    for(const width of [1024,736,320]) {
      await visualPage.setViewportSize({width,height:1050});
      await visualPage.screenshot({path:path.join(out,`queue-${width}.png`),fullPage:true});
    }
    await visualPage.setViewportSize({width:1120,height:1050});
    await visualPage.emulateMedia({colorScheme:'dark'});
    await visualPage.getByRole('tab',{name:'任务库',exact:true}).click();
    await visualPage.screenshot({path:path.join(out,'library-dark.png'),fullPage:true});
    await visualPage.close();
    const report = {tested_at:new Date().toISOString(),kind:'interactive_design_only',checks,errors,prototype_network_requests:prototypeRequests,blocked_preview_wrapper_dependencies:requests.filter(url=>wrapperDependencies.includes(url)),task_count:JSON.parse(fs.readFileSync(path.join(root,'design/task-catalog.json'),'utf8')).tasks.length,game_actions_sent:0,client_rebuilt:false};
    fs.writeFileSync(path.join(out,'verification.json'),JSON.stringify(report,null,2)+'\n');
    console.log(JSON.stringify({passed:checks.length,errors,prototype_network_requests:prototypeRequests.length,report:path.join(out,'verification.json')}));
  } finally {await browser.close();}
})().catch(e=>{fs.writeFileSync(path.join(out,'verification-failure.txt'),String(e.stack));console.error(e);process.exitCode=1;});

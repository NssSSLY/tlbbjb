// Local design checks only. No real authentication, process binding, or game actions.
const fs=require('node:fs'),path=require('node:path'),{pathToFileURL}=require('node:url');
const {chromium}=require('C:/Users/liqia/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const base=path.resolve(__dirname,'..'),out=path.join(base,'artifacts/ui-design-r2');
const checks=[],errors=[],requests=[];
const assert=(v,m)=>{if(!v)throw Error(m);};
const test=async(name,run)=>{await run();checks.push({name,passed:true});console.log('PASS '+name);};
(async()=>{
  const browser=await chromium.launch({executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe',headless:true});
  try{
    const context=await browser.newContext({viewport:{width:1024,height:800}});
    context.on('page',p=>p.on('pageerror',e=>errors.push(String(e))));
    await context.route(/^https?:/,r=>{requests.push(r.request().url());return r.abort();});
    const launcher=await context.newPage();await launcher.goto(pathToFileURL(path.join(out,'launcher-preview.html')).href);
    const lf=launcher.frameLocator('iframe');await lf.locator('#tlbb-launcher').waitFor();
    const la=name=>lf.locator(`[data-action="${name}"]`);
    await test('Launcher has no task controls, unknown first-login roles are not fabricated',async()=>{
      assert(await lf.getByRole('tab').count()===0,'Task tabs must not be in launcher');
      assert(await lf.getByRole('combobox',{name:'角色',exact:true}).isDisabled(),'Unknown roster should not be selectable');
      assert((await lf.locator('#la-login').innerText()).includes('未读取角色'),'Missing unknown state');
      assert(await la('refresh-roles').isDisabled(),'Do not read roster before login');
    });
    await test('First-login feedback records only known characters and enables next-login selection',async()=>{
      await la('login').click();assert(await la('select-account').first().isDisabled(),'Account identity changed during login');
      await la('demo-feedback').click();assert(await lf.getByRole('combobox',{name:'角色',exact:true}).isEnabled(),'First character was not recorded');
      assert((await la('login').innerText()).includes('所选角色'),'Next login cannot choose cached character');
      assert((await lf.locator('#la-status').innerText()).includes('示例反馈'),'Demo must not imply actual login');
    });
    await test('Roster cache is isolated by account, district and server',async()=>{
      await lf.getByRole('combobox',{name:'服务器',exact:true}).selectOption('server-b');
      assert(await lf.getByRole('combobox',{name:'角色',exact:true}).isDisabled(),'Wrong-server characters leaked');
      await lf.getByRole('combobox',{name:'服务器',exact:true}).selectOption('server-a');
      assert(await lf.getByRole('combobox',{name:'角色',exact:true}).isEnabled(),'Cache lost when returning to server');
      await lf.getByRole('combobox',{name:'大区',exact:true}).selectOption('area-b');
      assert(await lf.getByRole('combobox',{name:'角色',exact:true}).isDisabled(),'Wrong-district characters leaked');
      await lf.locator('[data-action="select-account"][data-id="account-b"]').click();
      assert((await lf.getByRole('combobox',{name:'角色',exact:true}).innerText()).includes('角色乙'),'Wrong-account cache');
    });
    await test('Account editor uses examples and does not accept real credentials; empty paths block login',async()=>{
      await la('edit-account').click();assert(await lf.getByRole('textbox',{name:'账号',exact:true}).isDisabled(),'Do not collect credentials in preview');
      assert(await lf.locator('input[type=password]').isDisabled(),'Preview password field should be disabled');
      await lf.getByRole('textbox',{name:'账号别名',exact:true}).fill('示例乙的新别名');await la('save-account').click();
      assert((await lf.locator('#la-accounts').innerText()).includes('示例乙的新别名'),'Alias edit lost');
      await lf.getByRole('textbox',{name:'游戏目录',exact:true}).fill('');await la('login').click();
      assert((await lf.locator('#la-status').innerText()).includes('配置游戏目录'),'Empty path not blocked');
      await lf.getByRole('textbox',{name:'游戏目录',exact:true}).fill('E:\\game\\tlbb');
    });
    const panel=await context.newPage();await panel.goto(pathToFileURL(path.join(out,'session-preview.html')).href);
    const pf=panel.frameLocator('iframe');await pf.locator('#tlbb-session').waitFor();
    const pa=name=>pf.locator(`[data-action="${name}"]`),tab=name=>pf.getByRole('tab',{name,exact:true}).click();
    await test('Single-game panel starts with functional tabs and has no brand header, role sidebar or login settings',async()=>{
      assert(await pf.getByRole('tab').count()===10,'Expected ten functional tabs');
      assert(await pf.locator('header,h1,h2,.sp-role-list,.sp-role-sidebar').count()===0,'Unwanted overview or heading');
      assert(await pf.getByRole('textbox',{name:'游戏目录',exact:true}).count()===0,'Launcher fields leaked into task panel');
      assert(await pf.locator('#sp-window').evaluate(el=>el.firstElementChild.id==='sp-tabs'),'Tabs must be first visible row');
      for(const name of ['副本','日常','活动','生活','挂机','技能','拾取背包','补给恢复','任务流程','设置']){
        await tab(name);assert((await pf.locator('#sp-content').innerText()).length>5,'Empty tab '+name);
      }
    });
    await test('Task parameters create independent queue nodes; editing a node does not change task defaults',async()=>{
      await tab('生活');await pf.getByRole('textbox',{name:'作物',exact:true}).fill('水稻');
      await pf.getByRole('spinbutton',{name:'轮数',exact:true}).fill('3');await pa('add-task').click();
      await tab('任务流程');await pf.locator('.sp-queue-name').last().click();
      assert((await pf.locator('.sp-queue-row').last().innerText()).includes('水稻 / 3 轮'),'Queue parameter snapshot wrong');
      await pf.getByRole('spinbutton',{name:'轮数',exact:true}).fill('2');
      await pf.locator('.sp-queue-row').last().locator('[data-action=up]').click();
      assert((await pf.locator('.sp-queue-row').nth(1).innerText()).includes('水稻 / 2 轮'),'Reorder failed');
      await tab('生活');assert(await pf.getByRole('spinbutton',{name:'轮数',exact:true}).inputValue()==='3','Queue edits changed task defaults');
    });
    await test('Unsupported tasks block execution; movement-only checks remain explicitly disconnected',async()=>{
      await tab('任务流程');await pa('start').click();assert((await pf.locator('#sp-status').innerText()).includes('种植：待适配'),'Unsupported task not blocked');
      for(const el of await pf.getByRole('checkbox',{name:'启用 种植',exact:true}).all())await el.uncheck();
      await pa('start').click();assert((await pf.locator('#sp-status').innerText()).includes('未连接，不发送动作'),'Preview implies real run');
    });
    await test('Destroy preview protects task and unknown items; edits invalidate enablement',async()=>{
      await tab('拾取背包');await pf.locator('[data-action="bag-tab"][data-id="destroy"]').click();
      await pf.locator('[data-bag=destroy]').click();assert(!(await pf.locator('[data-bag=destroy]').isChecked()),'Destruction enabled without preview');
      await pa('preview-destroy').click();assert((await pf.locator('#sp-destroy-output').innerText()).includes('未知物品 × 1：保护'),'Unknown item not protected');
      await pf.locator('[data-bag=destroy]').check();await pf.locator('[data-bag=whitelist]').fill('任务信件');
      assert(!(await pf.locator('[data-bag=destroy]').isChecked()),'Rule edit left destruction enabled');
      await pa('preview-destroy').click();assert((await pf.locator('#sp-destroy-output').innerText()).includes('任务信件 × 1：保护'),'Whitelist overrode protected item');
      await pf.locator('[data-bag=destroy]').check();
    });
    await test('Editable skill, supply and keep rules persist across tabs; keep rules override destruction',async()=>{
      await tab('技能');await pf.getByRole('combobox',{name:'珍兽策略',exact:true}).selectOption({label:'仅防御'});
      await tab('补给恢复');await pf.getByRole('combobox',{name:'缺药处理',exact:true}).selectOption({label:'按预算购买'});
      await tab('技能');assert(await pf.getByRole('combobox',{name:'珍兽策略',exact:true}).inputValue()==='仅防御','Skill option lost');
      await tab('补给恢复');assert(await pf.getByRole('combobox',{name:'缺药处理',exact:true}).inputValue()==='按预算购买','Supply option lost');
      await tab('拾取背包');await pf.locator('[data-action="bag-tab"][data-id="keep"]').click();
      await pf.getByRole('textbox',{name:'保留名单',exact:true}).fill('破旧材料');
      await pf.locator('[data-action="bag-tab"][data-id="destroy"]').click();
      assert(!(await pf.locator('[data-bag=destroy]').isChecked()),'Protection edit did not invalidate destruction');
      await pf.locator('[data-bag=whitelist]').fill('破旧材料');await pa('preview-destroy').click();
      assert((await pf.locator('#sp-destroy-output').innerText()).includes('破旧材料 × 2：保护'),'Keep list did not override whitelist');
      await pf.locator('[data-bag=destroy]').check();
    });
    async function copy(previewOnly=false){
      await pa('copy').click();await pf.locator('[data-copy-target="role-b"]').check();
      await pf.locator('[data-copy-scope="battle"]').check();await pf.locator('[data-copy-scope="bag"]').check();
      assert(await pa('copy-apply').isDisabled(),'Preview is required');await pa('copy-preview').click();
      const diff=await pf.locator('.sp-dialog .sp-output').innerText();if(previewOnly)await pa('close-copy').click();else await pa('copy-apply').click();return diff;
    }
    await test('Copy is on-demand, preserves identities, excludes incompatible skills and creates independent drafts',async()=>{
      const diff=await copy();assert(diff.includes('保留登录身份')&&diff.includes('跳过技能')&&diff.includes('关闭，需重新预览'),'Copy policy missing');
      await tab('任务流程');await pf.locator('.sp-queue-name').first().click();
      await pf.getByRole('spinbutton',{name:'目标 X',exact:true}).fill('361');
      const next=await copy(true);assert(next.includes('360,317 → 361,317'),'Target shares source parameters');
      assert(next.includes('原销毁关闭'),'Target copied source destruction enablement');
    });
    await test('Home is idempotent; End detaches only this local panel and preserves its configuration',async()=>{
      await pf.getByRole('spinbutton',{name:'目标 X',exact:true}).focus();await panel.keyboard.press('End');
      assert(await pf.locator('#sp-window').isVisible(),'Editing End key should remain a text-editing key');
      await pf.locator('#sp-tab-queue').focus();await panel.keyboard.press('End');assert(await pf.locator('#sp-window').isHidden(),'End did not detach');
      await pa('home').click();await tab('任务流程');
      assert(await pf.getByRole('spinbutton',{name:'目标 X',exact:true}).inputValue()==='361','Reopen lost per-game draft');
      await pf.locator('#sp-tab-queue').focus();await panel.keyboard.press('Home');
      assert(await pf.getByRole('tab').count()===10,'Repeated Home duplicates panel');
      assert(await pf.locator('#tlbb-session').getAttribute('data-session-id')==='example-session-a','Panel target changed');
    });
    await test('Two independent preview instances do not share task configuration',async()=>{
      const other=await context.newPage();const source=fs.readFileSync(path.join(base,'design/prototype/tlbb-session-panel.html'),'utf8');
      await other.setContent('<meta charset="utf-8">'+source);await other.getByRole('tab',{name:'生活',exact:true}).click();
      assert(await other.getByRole('textbox',{name:'作物',exact:true}).inputValue()==='小麦','Independent instance received first panel edits');
      await other.close();
    });
    await test('Both windows and all task pages fit 1024, 736 and 320 widths without horizontal overflow',async()=>{
      for(const width of [1024,736,320]){
        await panel.setViewportSize({width,height:800});await launcher.setViewportSize({width,height:800});
        for(const name of ['副本','日常','活动','生活','挂机','技能','拾取背包','补给恢复','任务流程','设置']){
          await tab(name);const metrics=await pf.locator('#tlbb-session').evaluate(el=>({width:el.getBoundingClientRect().width,scroll:el.scrollWidth,doc:document.documentElement.scrollWidth,viewport:document.documentElement.clientWidth}));
          assert(metrics.scroll<=Math.ceil(metrics.width)+1&&metrics.doc<=metrics.viewport+1,`${width} ${name}: ${JSON.stringify(metrics)}`);
        }
        const size=await lf.locator('#tlbb-launcher').evaluate(el=>({width:el.getBoundingClientRect().width,scroll:el.scrollWidth}));
        assert(size.scroll<=Math.ceil(size.width)+1,'Launcher overflow');
      }
    });
    // Direct fragment captures avoid asynchronous iframe resizing in inspection output.
    const qa=await context.newPage();
    for(const [name,file,widths] of [['launcher','tlbb-launcher.html',[736,320]],['session','tlbb-session-panel.html',[1024,736,320]]]){
      await qa.setContent('<meta charset="utf-8"><style>html{color-scheme:light dark}body{margin:16px}</style>'+fs.readFileSync(path.join(base,'design/prototype',file),'utf8'));
      for(const width of widths){await qa.setViewportSize({width,height:700});await qa.screenshot({path:path.join(out,`${name}-${width}.png`),fullPage:true});}
      if(name==='session'){await qa.setViewportSize({width:1024,height:700});await qa.emulateMedia({colorScheme:'dark'});await qa.screenshot({path:path.join(out,'session-dark.png'),fullPage:true});}
    }
    await qa.close();
    const wrapperDependencies=['https://unpkg.com/@floating-ui/dom@1.7.4/dist/floating-ui.dom.umd.min.js','https://unpkg.com/lucide@1.17.0/dist/umd/lucide.js'];
    const unexpected=requests.filter(u=>!wrapperDependencies.includes(u));
    await test('No runtime errors, real credentials, prototype network calls or game actions',async()=>{assert(!errors.length,errors.join(';'));assert(!unexpected.length,unexpected.join(';'));});
    const report={tested_at:new Date().toISOString(),revision:'0.3-r2',scope:'local_design_interactions_only',checks,errors,prototype_network_requests:unexpected,blocked_wrapper_dependencies:[...new Set(requests)],client_rebuilt:false,installer_created:false,game_actions_sent:0,native_shortcuts_tested:false,real_login_tested:false};
    fs.writeFileSync(path.join(out,'verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({passed:checks.length,report:path.join(out,'verification.json')}));
  }finally{await browser.close();}
})().catch(e=>{fs.writeFileSync(path.join(out,'failure.txt'),String(e.stack));console.error(e);process.exitCode=1;});

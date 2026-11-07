-- 来自 新建文件夹/小蜜文本/内置文本/旧内置文件/一键设置游戏.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
local 游戏设置lua = [[
SystemSetup:View_SetData( "wtdh",0 );
SystemSetup:View_SetData( "dhgxzl",0 );
SystemSetup:View_SetData( "ksfw",0 );
SystemSetup:View_SetData( "mxxslj",0 );
SystemSetup:View_SetData( "yszl",0 );
SystemSetup:View_SetData( "rwyy",0 );
SystemSetup:View_SetData( "dxyy",0 );
SystemSetup:View_SetData( "txdjsz",0 );
SystemSetup:View_SetData( "miwu",0 );
SystemSetup:View_SetData( "zdbt",0 );
SystemSetup:View_SetData( "cztb",0 );
SystemSetup:View_SetData( "mrsj",0 );-- 经典视距
SystemSetup:View_SetData( "jzcj",0 );
SystemSetup:View_SetData( "rt",0 );
SystemSetup:View_SetData( "mxtx",0 );
SystemSetup:View_SetData( "tksj",0 );
SystemSetup:View_SetData( "tm",1 );-- 替模
SystemSetup:View_SetData( "fhj",0 );
SystemSetup:View_SetData( "cy",0 );
SystemSetup:View_SetData( "qpfg",0 );
SystemSetup:View_SetData( "hdr",0 );
Variable:SetVariable("View_Resoution", "800,600", 0);
SystemSetup:SaveGameSetup (0,0,0,0,0,0,0,0,0,0.89999997615814,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,1,0,1,0,0,0,0,0,0); -- 游戏性设置
Variable:SetVariable("EnableBGSound", "0", 0);
Variable:SetVariable("Enable3DSound", "0", 0);
Variable:SetVariable("EnableSKSound", "0", 0);
Variable:SetVariable("EnableUISound", "0", 0);]]
LUA_Call(游戏设置lua)
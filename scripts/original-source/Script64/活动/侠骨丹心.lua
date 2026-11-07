-- 反编译自 dfz64.dll 内嵌字节码 00457c3f（unluac 2025-12-23；仅供分析）
local m_script_name = "侠骨丹心"
ScriptOnStart(m_script_name, true, true)
local liandanPos = {
  {x = 256, y = 347},
  {x = 405, y = 219},
  {x = 386, y = 151},
  {x = 179, y = 273}
}
math.randomseed(os.time())

function hookDA()
  GetLuaValue("            if _WuShenTan_DaKa_OnEvent == nil then\n                __LeftTime = \"\"\n                g_Serveranswer1 = \"\"\n                g_Serveranswer2 = \"\"\n                g_Serveranswer3 = \"\"\n                g_Serveranswer4 = \"\"\n                _WuShenTan_DaKa_OnEvent = WuShenTan_DaKa_OnEvent;\n            end\n\n            function WuShenTan_DaKa_OnEvent(event)\n                if event == \"UI_COMMAND\" and tonumber(arg0) == 89362701 then\n                    local nType = Get_XParam_INT(0)\n                    __LeftTime = Get_XParam_INT(0)\n\n                    if nType == 3 then --刷新界面：接收服务器传来的答案，根据答案展示结算界面；将客户端的答案上传给sever，记录答题是否正确，用于统计\n                        if(IsWindowShow(\"WuShenTan_DaKa\")) then\n                            g_npcid = Get_XParam_INT(1)\n                            g_round = Get_XParam_INT(2)\n                            g_state = Get_XParam_INT(3)\n                            g_Serveranswer1 = Get_XParam_INT(4)\n                            g_Serveranswer2 = Get_XParam_INT(5)\n                            g_Serveranswer3 = Get_XParam_INT(6)\n                            g_Serveranswer4 = Get_XParam_INT(7)\t\t\t\n                            WuShenTan_DaKa_UpdateUI() --此时要根据g_state状态，判断各控件是否可以点击，比如答题按钮\n                            --返回答案\n                            Clear_XSCRIPT();\n                                Set_XSCRIPT_Function_Name(\"RetClientAnswer\");\n                                Set_XSCRIPT_ScriptID(893627);\n                                Set_XSCRIPT_Parameter(0,g_npcid);\n                                Set_XSCRIPT_Parameter(1,g_round);\n                                Set_XSCRIPT_Parameter(2,g_Serveranswer1);\n                                Set_XSCRIPT_Parameter(3,g_Serveranswer2);\n                                Set_XSCRIPT_Parameter(4,g_Serveranswer3);\n                                Set_XSCRIPT_Parameter(5,g_Serveranswer4);\n                                Set_XSCRIPT_ParamCount(6);\n                            Send_XSCRIPT();\t\t\t\t\n                        end\n                        return\n                    elseif nType == 5 then --刷新界面：接收服务器传来的答案，根据答案展示结算界面；将客户端的答案上传给sever，记录答题是否正确，用于统计\n                        if(IsWindowShow(\"WuShenTan_DaKa\")) then\n                        else\n                            g_npcid = Get_XParam_INT(1)\n                            g_round = Get_XParam_INT(2)\n                            g_state = Get_XParam_INT(3)\n                            g_Serveranswer1 = Get_XParam_INT(4)\n                            g_Serveranswer2 = Get_XParam_INT(5)\n                            g_Serveranswer3 = Get_XParam_INT(6)\n                            g_Serveranswer4 = Get_XParam_INT(7)\t\t\t\t\n                            WuShenTan_DaKa_UpdateUI() --此时要根据g_state状态，判断各控件是否可以点击，比如答题按钮\n                            --返回答案\n                            Clear_XSCRIPT();\n                                Set_XSCRIPT_Function_Name(\"RetClientAnswer\");\n                                Set_XSCRIPT_ScriptID(893627);\n                                Set_XSCRIPT_Parameter(0,g_npcid);\n                                Set_XSCRIPT_Parameter(1,g_round);\n                                Set_XSCRIPT_Parameter(2,g_answer1);\n                                Set_XSCRIPT_Parameter(3,g_answer2);\n                                Set_XSCRIPT_Parameter(4,g_answer3);\n                                Set_XSCRIPT_Parameter(5,g_answer4);\n                                Set_XSCRIPT_ParamCount(6);\n                            Send_XSCRIPT();\t\t\t\t\t\t\n                        end\t\n                        return\n                    end\n                end\n                _WuShenTan_DaKa_OnEvent(event)\n            end\n\n        ")
end

local wcindex = 0

function _SMain(...)
  hookDA()
  while true do
    local s = GetLuaValue("return __LeftTime", "n", 1)
    PushColorMsg(s)
    if 5 == s then
      if wcindex > 0 then
        PushColorMsg("炼丹结束")
        GoToSceneNPC("白须道人", 306, 271, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{WSDK_260327_03}", 1, 1000)
        Sleep(1000)
        QuestFrameMissionComplete(nil, 700)
        break
      end
      wcindex = wcindex + 1
    end
    local nIndex, idMission, idScript = GetPlayerMission_Item("#{WSDK_260327_03}")
    if -1 == nIndex then
      GoToSceneNPC("白须道人", 306, 271, LUOYANG_ID)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{WSDK_260327_03}", 1, 1000)
      Sleep(1000)
      QuestFrameAcceptClicked(2000)
    else
      local nParam = GetMissionComplete(nIndex)
      if 0 == nParam then
        local tJXL = Enum2XByTitle(g_self.name .. "的见瑕炉", {
          1,
          0,
          0,
          0
        }, {0, -1}, 1, 0)
        if #tJXL > 0 then
          local tmp = tJXL[1]
          local tStr = EnumObjBuff(tmp)
          Sleep(1000)
        else
          local index = math.random(#liandanPos)
          local selected = liandanPos[index]
          MoveTo(selected.x, selected.y)
          Bag:UseItemByName_click("见瑕炉", 4000)
          Sleep(1000)
          local tJXL = Enum2XByTitle(g_self.name .. "的见瑕炉", {
            1,
            0,
            0,
            0
          }, {0, -1}, 1, 0)
          if #tJXL > 0 then
            local tmp = tJXL[1]
            OpenTalk(tmp.id, 600)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{WSDK_260327_71}", 1, 1000)
          end
        end
        Sleep(3000)
      else
        GoToSceneNPC("白须道人", 306, 271, LUOYANG_ID)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{WSDK_260327_03}", 1, 1000)
      end
    end
  end
end

_SMain()
ScriptOnStop(m_script_name, true)

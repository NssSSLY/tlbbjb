-- 反编译自 dfz64.dll 内嵌字节码 00445fe7（unluac 2025-12-23；仅供分析）
local m_script_name = "千百渡他(普通)"
ScriptOnStart(m_script_name, true, true)

function onstar(...)
  while GetSceneID() == 1079 do
    local tObj = Enum2XByClass("怪物 陷阱", {0, -1})
    BubbleByDst(tObj)
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.name == "项王" then
        Sleep(100)
      else
        if tmp.class == "怪物" then
          RunTo(tmp.x, tmp.y, 0, 100)
          FubenAttack(tmp.id)
          Sleep(200)
        end
        if tmp.class == "陷阱" and string.find(tmp.name, "技能书", nil, true) then
          RunTo(tmp.x, tmp.y, 0, 100)
          Sleep(200)
        end
      end
    else
      Sleep(15000)
      local tObj = Enum2XByClass("怪物")
      if 0 == #tObj then
        GoToSceneNPC("溯缘镜", 189, 136, 1079)
        local txw = Enum2XByName("项王", {
          1,
          1,
          1,
          0
        }, nil, nil, 0)
        if #txw > 0 then
          GoToSceneNPC("项王", 186, 121, 1079)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXFB_260529_29}", 1, 1000)
          Sleep(1000)
        else
          GoToSceneNPC("溯缘镜", 189, 136, 1079)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXFB_260529_20}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXFB_260529_25}", 1, 1000)
          break
        end
      end
    end
  end
end

function _SMain(...)
  while true do
    DeleteDebugMsg("#{QXFB_260529_347}")
    DeleteDebugMsg("#{QXFB_260529_15}")
    if GetSceneID() == 1079 then
      onstar()
    else
      GoToSceneNPC("溯缘镜", 208, 51, 1075)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_04}", 1, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
      if IsInDebugMsg("#{QXFB_260529_347}") or IsInDebugMsg("#{QXFB_260529_15}") then
        PushColorMsg("#{QXFB_260529_347}")
        QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
        break
      end
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)

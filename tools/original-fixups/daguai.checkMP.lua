-- 手工还原：unluac 2025-12-23 无法处理此函数的控制流（ControlFlowHandler.is_break_jmp 空指针），
-- 依据原字节码（daguai 第 30 个函数，源行 839-941）逐条翻译；与原字节码做过随机对拍，返回值和调用序列一致。
function CDG:checkMP(aUsePetXueJi)
  if aUsePetXueJi == nil then
    aUsePetXueJi = true
  end
  if self.mp.cmp <= 0 then
    return true
  end
  local mpp = Player:GetMPP()
  local bUseItem = false
  local bNeedMP = mpp < self.mp.cmp
  if not bNeedMP and mpp < self.mp.cmp + 3 and mpp < 95 then
    local curGUID = Player:GetFightPetGUID()
    bNeedMP = aUsePetXueJi and curGUID > 0 and curGUID == self.pet3.GUID and self.pet1.GUID ~= self.pet3.GUID
  end
  if bNeedMP then
    if self.call.back1 and self.call.back1() == false then
      return false
    end
    local bUseXueJi = false
    local tick_out = GetTickCount()
    if aUsePetXueJi and self.pet3.GUID > 0 and Player:GetBuff("珍兽施放共生和血祭") == -1 then
      bUseXueJi = true
      for i = 1, 4 do
        local hp = CDG:checkHP_PetGUID(self.pet3.GUID, 100)
        if hp > 90 then
          break
        end
        if self.call.back1 and self.call.back1() == false then
          return false
        end
        Sleep(250)
      end
      if self:checkPetPlay(self.pet3.GUID) then
        if GetTickCount() - tick_out > 2500 then
          PushColorMsg("召唤血祭珍兽...")
          return false
        end
        for i = 1, 4 do
          local hp = CDG:checkHP_PetGUID(self.pet3.GUID, 100)
          if hp > 90 then
            break
          end
          if self.call.back1 and self.call.back1() == false then
            return false
          end
          Sleep(300)
        end
        if GetLuaValue("return meUsePetSkill('高级血祭');", "b") then
          Sleep(100)
          return false
        end
      end
    end
    if not bUseXueJi then
      mpp = Player:GetMPP()
      if mpp < self.mp.cmp then
        local tItem = Bag:SearchItemName("行气散 还灵丹 归灵丸 采香丸")
        if #tItem > 0 then
          bUseItem = true
          Bag:UseItem(tItem[1].index, 200)
        end
        tItem = Bag:SearchItemName("玉液净瓶 仙露净瓶 玉液宝瓶")
        if #tItem > 0 then
          bUseItem = true
          Bag:UseItem(tItem[1].index, 200)
        end
      end
    end
  end
  local curGUID = Player:GetFightPetGUID()
  if curGUID > 0 and curGUID == self.pet3.GUID and self.pet1.GUID ~= self.pet3.GUID then
    if bUseItem == false and self.mp.cmp <= mpp or Player:GetBuff("珍兽施放共生和血祭") ~= -1 then
      Pet:Relax()
      return true
    end
  end
  return false
end

-- 反编译自 dfz64.dll 内嵌字节码 002fbab1（unluac 2025-12-23；仅供分析）
local m_script_name = "扫荡副本"
ScriptOnStart(m_script_name, false, false)
local m_yzw = ReadConfigBool("ZH", "xzk131")
local m_sjz = ReadConfigBool("ZH", "xzk266")
local m_sss = ReadConfigBool("ZH", "xzk274")
local m_12r = ReadConfigBool("ZH", "xzk272")
local m_fmwl = ReadConfigBool("ZH", "xzk279")
local m_sshj = ReadConfigBool("ZH", "xzk278")
local m_pmf = ReadConfigBool("ZH", "xzk275")
local m_lhfd_easy = ReadConfigBool("ZH", "xzk277")
local m_lhfd = ReadConfigBool("ZH", "xzk276")
local m_lsh = ReadConfigBool("ZH", "xzk290")
local m_param = {
  yzw = m_yzw,
  sjz = m_sjz,
  sss = m_sss,
  bsqz = m_12r,
  fmwl = m_fmwl,
  sshj = m_sshj,
  pmf = m_pmf,
  lhfd_easy = m_lhfd_easy,
  lhfd = m_lhfd,
  lsh = m_lsh
}
SDFB_OnStart(m_param)
ScriptOnStop(m_script_name)

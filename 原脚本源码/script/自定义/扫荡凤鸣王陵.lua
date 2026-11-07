local m_script_name = "扫荡凤鸣王陵"
ScriptOnStart(m_script_name, false, false)

local m_param = {
    yzw = false,
    sjz = false,
    sss = false,
    bsqz = false,
    fmwl = true,
    sshj = false,
    pmf = false,
    lhfd_easy = false,
    lhfd = false,
    lsh = false
}

SDFB_OnStart(m_param) -- 扫荡副本

ScriptOnStop(m_script_name)
m_param = nil

local m_script_name = "扫荡琅嬛福地普通"
ScriptOnStart(m_script_name, false, false)

local m_param = {
    yzw = false, 
    sjz = false,
    sss = false,
    bsqz = false,
    fmwl = false,
    sshj = false,
    pmf = false,
    lhfd_easy = true,
    lhfd = false,
    lsh = false
}

SDFB_OnStart(m_param) -- 扫荡副本

ScriptOnStop(m_script_name)
m_param = nil

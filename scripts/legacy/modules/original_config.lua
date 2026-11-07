-- Preserve reference control values instead of inventing empty text/data.
OriginalConfig={}
local function scalar(v) return type(v)=='string' or type(v)=='number' or type(v)=='boolean' end
function OriginalConfig.combo(value,shape,name)
    if type(value)=='table' then
        assert(type(value.sel)=='number' and value.sel==math.floor(value.sel) and value.sel>=-1,'下拉序号无效：'..tostring(name))
        assert(type(value.text)=='string' and #value.text<=1024 and scalar(value.data),'下拉文本/附加值无效：'..tostring(name))
        return {sel=value.sel,text=value.text,data=value.data}
    end
    if type(value)=='string' and shape and shape.options then
        local found
        for i,option in ipairs(shape.options) do
            if value==option.text or value==option.data then
                assert(not found,'下拉映射重复：'..tostring(name))
                assert(type(option.text)=='string' and scalar(option.data),'下拉映射无效')
                found={sel=i-1,text=option.text,data=option.data}
            end
        end
        if found then return found end
    end
    local index=value==nil and 0 or tonumber(value)
    assert(index and index==math.floor(index) and index>=-1,'下拉配置需要序号或 {sel,text,data}：'..tostring(name))
    local option=shape and shape.options and shape.options[index+1]
    if option then
        assert(type(option.text)=='string' and scalar(option.data),'下拉映射无效：'..tostring(name))
        return {sel=index,text=option.text,data=option.data}
    end
    -- The selection is known, its label and attached value are not. Fail only
    -- if a task actually consumes the unavailable field.
    return setmetatable({sel=index},{__index=function(_,key)
        error('下拉配置缺少 '..tostring(key)..' 映射：'..tostring(name),0)
    end})
end
function OriginalConfig.list(value,name)
    local out={}
    if value==nil or value=='' then return out end
    if type(value)=='table' then
        assert(#value<=256,'列表最多 256 项')
        for _,item in ipairs(value) do
            assert(type(item)=='table' and type(item.text)=='string','列表行需要 text：'..tostring(name))
            local row={};for k,v in pairs(item) do assert(scalar(v),'列表列值无效');row[k]=v end
            out[#out+1]=row
        end
    else
        assert(type(value)=='string' and #value<=4096,'列表文本无效')
        for word in value:gmatch('%S+') do
            out[#out+1]=setmetatable({text=word},{__index=function(_,key)
                error('列表配置缺少 '..tostring(key)..' 列：'..tostring(name),0)
            end})
        end
    end
    return out
end

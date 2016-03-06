local libpack = {}
local fs = require("filesystem")
function read_file (dir)
    local f = io.open(dir,"r")
    local temp = f:read()
    local res = ""
    while temp do
        res = res .. "\n" .. temp
        temp = f:read()
    end
    f:close()
    return res
end
function write_file (file,str)
    if fs.exists(file) then
        return false,file .. " exists."
    end
    local f = io.open(file,"wb")
    if f then
        if f:write(str) then
            f:close()
            return true
        else
            f:close()
            return false,"Error:failed writing to " .. file .. "."
        end
    else
        f:close()
        return false,"Error:failed opening " .. file .. "."
    end
    f:close()
    return false,"Unknown error."
end
function list_dir (dir)
    local fun = fs.list(dir)
    local str = fun()
    local res = {}
    while str ~= nil do
        if fs.isDirectory(dir .. str) then
            res[#res + 1] = dir .. str
        end
        str = fun()
    end
    return res
end
--------------------------------------------------------------------------------
libpack.Getfile = nil --libpack.Getfile(name,file)
function libpack.Install_Single_Package (name,root_dir,is_depended)
    if fs.isDirectory(root_dir .. "var/lib/packman/") then
        return false,"Error:Couldn't find dir" .. root .. "var/lib/packman/"
    end

    fs.makeDirectory(root_dir .. "var/lib/packman/" .. name .. "/")

    local PACKINFO = libpack.Getfile(name,"PACKINFO")
    local a,b
    a,b = write_file(root_dir .. "var/lib/packman/" .. name .."/PACKINFO",
                    PACKINFO)
    if not a then
        return false,b
    end
    local T_PACKINFO = loadstring("return " .. PACKINFO)()

    for a=1,#T_PACKINFO.Directory do
        if not fs.isDirectory(root_dir .. T_PACKINFO.Directory[a]) then
            if not fs.makeDirectory(root_dir .. T_PACKINFO.Directory[a]) then
                return false,"Error:failed creating: " .. root_dir .. T_PACKINFO.Directory[a]
            end
        end
    end

    for i=1,#T_PACKINFO.Files do
        a,b = write_file(root_dir .. T_PACKINFO.Files[i],
                               libpack.Getfile(name,"data/" .. T_PACKINFO.Files[i]))
        if not a then
            return false,b
        end
    end

    if is_depended then
        a,b = write_file(root_dir .. "var/lib/packman/" .. name .. "/DEPENDED",
                        "")
        if not a then
            return false,b
        end
    end

    assert(loadstring(libpack.Getfile(name,"auto.lua")))(root_dir)
    return true
end
function libpack.Remove_Single_Package (name,root_dir,rm_extra_file)
    local PACKINFO = read_file(root_dir .. "var/packman/" .. name .. "/PACKINFO")
    local T_PACKINFO = loadstring("return " .. PACKINFO)()

    for i=1,#T_PACKINFO.Files do
        fs.remove(T_PACKINFO.Files[i])
    end

    if rm_extra_file then
        for a=1,#T_PACKINFO.Extra_Files do
            fs.remove(T_PACKINFO.Extra_Files[a])
        end
    end

    -- local dir = list_dir(root_dir .. "var/packman/")
    -- local delete = false
    -- local T_temp
    -- for b=1,#T_PACKINFO.Directory do
    --     for c=1,#dir do
    --         T_temp = loadstring("return " .. dir[1] .. "/PACKINFO")
    --         for o=1,T_temp.Directory do
    --             if T_PACKINFO.Directory[b] == T_temp.Directory[o] then
    --                 --body...
    --             end
    --         end
    --     end
    -- end
    -- TODO 删除多余目录
    fs.remove(root_dir .. name) -- TODO 检查函数是否使用正确
end

-- TODO 完成基础函数(安装单个，删除单个，...)
--------------------------------------------------------------------------------
return libpack

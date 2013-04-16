---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local tonumber = tonumber
local io = { popen = io.popen, input = io.input, read = io.read }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
-- }}}

local mutt = {}
-- mail: provides count of new and subject of last e-mail on IMAP mail


-- {{{ Gmail widget type
local function worker(format, warg)
	local mail = io.popen('/bin/bash -c "exec /home/bradomyn/.config/awesome/scripts/check_mail"') 
	local num = mail:read("*l")
	mail:close()

	if num == nil then 
	    return  "N/A"
	end
	return num
end
-- }}}

return setmetatable(mutt, { __call = function(_, ...) return worker(...) end })

--[[
-- Whitelist mod by ShadowNinja
-- License: WTFPL
--]]

local worldpath = minetest.get_worldpath()
local whitelist = {}
local admin = minetest.setting_get("name")

local function load_whitelist()
	local file, err = io.open(worldpath.."/whitelist.txt", "r")
	if err then
		return
	end
	for line in file:lines() do
		table.insert(whitelist, line)
	end
	file:close()
end

local function save_whitelist()
	local file, err = io.open(worldpath.."/whitelist.txt", "w")
	if err then
		return
	end
	for item in pairs(whitelist) do
		file:write(item)
	end
	file:close()
end

load_whitelist()

minetest.register_on_prejoinplayer(function(name, ip)
	if name == admin or name == "singleplayer" then
		return
	end
	for _, whitename in pairs(whitelist) do
		if name == whitename then
			return
		end
	end
	return "This server is whitelisted and you are not on the whitelist."
end)

minetest.register_chatcommand("whitelist", {
	params = "{add|remove} <nick>",
	help = "Manipulate the whitelist",
	privs = {ban=true},
	func = function(name, param)
		local action, whitename = param:match("^([^ ]+) ([^ ]+)$")
		if action == "add" then
			local alreadyin = false
			for i, listname in pairs(whitelist) do
				if listname == whitename then
					alreadyin = true
				end
			end
			if not alreadyin then
				table.insert(whitelist, whitename)
				save_whitelist()
				minetest.chat_send_player(name, "Added "
					..whitename.." to the whitelist.")
			else
				minetest.chat_send_player(name, whitename
					.." is already on the whitelist.")
			end
		elseif action == "remove" then
			local removed = false
			for i, listname in pairs(whitelist) do
				if listname == whitename then
					table.remove(whitelist, i)
					removed = true
				end
			end
			if removed then
				save_whitelist()
				minetest.chat_send_player(name, "Removed "
					..whitename.." from the whitelist.")
			else
				minetest.chat_send_player(name, whitename
					.." is not on the whitelist.")
			end
		else
			minetest.chat_send_player(name, "Invalid action.")
		end
	end,
})


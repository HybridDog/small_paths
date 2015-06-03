dofile(minetest.get_modpath("small_paths").."/net_noise.lua")

local c_stone = minetest.get_content_id("default:dirt_with_grass")
local c_cobble = minetest.get_content_id("default:cobble")
local c_mossycobble = minetest.get_content_id("default:mossycobble")
local cs_ignored = {
	minetest.get_content_id("air"),
	minetest.get_content_id("default:leaves"),
}
local cs_ground = {
	minetest.get_content_id("default:dirt_with_grass"),
	minetest.get_content_id("default:desert_sand"),
}

local function table_contains(t, v)
	for _,i in pairs(t) do
		if i == v then
			return true
		end
	end
	return false
end

minetest.register_on_generated(function(minp, maxp, seed)

	if maxp.y <= 1
	or minp.y >= 150 then
		return
	end

	local t1 = os.clock()

	local pr = PseudoRandom(seed+68)
	net_noise(minp, maxp, 20, string.sub(seed, 1, 3))

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local changes

	for z = minp.z,maxp.z do
		for x = minp.x,maxp.x do
			--data[area:index(x, 1, z)] = c_stone
			local ran = pr:next(1,9)
			if ran ~= 1
			and net_noise_tab[x.." "..z] then
				local ground
				local p
				for y = maxp.y,minp.y,-1 do
					p = area:index(x, y, z)
					local nd = data[p]
					if not table_contains(cs_ignored, nd) then
						if table_contains(cs_ground, nd) then
							ground = true
						end
						break
					end
				end
				if ground then
					if ran <= 4 then
						data[p] = c_mossycobble
					else
						data[p] = c_cobble
					end
					changes = true
				end
			end
		end
	end

	if not changes then
		return
	end

	vm:set_data(data)
	vm:write_to_map()

	local geninfo = string.format("[small_paths] path made after: %.2fs", os.clock() - t1)
	print(geninfo)
	--minetest.chat_send_all(geninfo)
end)

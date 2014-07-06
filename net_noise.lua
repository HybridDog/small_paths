--net_noise v2

local function get_random(a, b, seed)
	return PseudoRandom(math.abs(a+b*5)+seed)
end

local function olo(p, s)
	return {x=p.x-p.x%s, y=p.y-p.y%s, z=p.z-p.z%s}
end

function net_noise(minp, maxp, s, seed)
	local p1 = olo(vector.subtract(minp, s), s)
	local p2 = olo(vector.add(maxp, s), s)
	--local maxp = vector.add(minp, 15)

	local tab = {}
	for x = p1.x, p2.x, s do
		for z = p1.z, p2.z, s do
			local pr = get_random(x, z, seed)
			tab[x.." "..z] = {x=x+pr:next(0, s-1), z=z+pr:next(0, s-1)}
		end
	end

	local tab2 = {}
	for x = p1.x, p2.x, s do
		for z = p1.z, p2.z, s do
			local p = tab[x.." "..z]
			p.y = 0
			for _,p2 in pairs({tab[x+s.." "..z], tab[x.." "..z+s]}) do
				if p2 then
					p2.y = 0
					for _,pos in pairs(vector.line(p, p2)) do
						tab2[pos.x.." "..pos.z] = true
					end
				end
			end
		end
	end

	net_noise_tab = tab2
	--[[tab,n = {},1
	for p,_ in pairs(tab2) do
		local x,z = unpack(string.split(p, " "))
		tab[n] = {x=x, z=z}
		n = n+1
	end
	return tab]]
end
--[[
minetest.register_node("ac:nmg", {
	description = "nmg",
	tiles = {"ac_block.png"},
	groups = {snappy=1,bendy=2,cracky=1},
	sounds = default_stone_sounds,
	on_construct = function(pos)
		local minp = vector.subtract(pos, 55)
		local nse = net_noise(minp, vector.add(pos, 55), 15, 1)
		for _,p in pairs(nse) do
			local p2 = {x=p.x, y=pos.y, z=p.z}
			if minetest.get_node(p2).name == "air" then
				minetest.set_node(p2, {name="default:desert_stone"})
			end
		end
	end,
})]]

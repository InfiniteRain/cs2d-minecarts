if not f then f = {} end
f.cart = {}

f.cart.conf = {
	friction = 0.1;
	startingspeed = 10;
	imagepath = 'gfx/cart.png';
	rotation = 90;
};

f.cart.tiles = {}
f.cart.boost = {}
f.cart.table = {}

for x = 1, map'xsize' do
	f.cart.tiles[x] = {}
	f.cart.boost[x] = {}
	for y = 1, map'ysize' do
		if entity(x, y, 'name') == 'rails' then
			f.cart.tiles[x][y] = true
			f.cart.boost[x][y] = false
		elseif entity(x, y, 'name') == 'cart' then
			f.cart.tiles[x][y] = true
			f.cart.boost[x][y] = false
			table.insert(f.cart.table, {position = {x*32+16, y*32+16}; startingposition = {x*32+16, y*32+16}; image = image(f.cart.conf.imagepath, x * 32 + 16, y * 32 + 16, 0); moving = 'stopped'; speed = f.cart.conf.startingspeed; inside = 0})
		elseif entity(x, y, 'name') == 'boost' then
			f.cart.boost[x][y] = true
			f.cart.tiles[x][y] = true
		else
			f.cart.tiles[x][y] = false
			f.cart.boost[x][y] = false
		end
	end
end

addhook('always', 'f.cart.hook.always')
addhook('move', 'f.cart.hook.move')
addhook('startround', 'f.cart.hook.startround')
addhook('use', 'f.cart.hook.use')
addhook('die', 'f.cart.hook.die')
addhook('leave', 'f.cart.hook.leave')

f.cart.hook = {
	always  = function()
		for k, v in pairs(f.cart.table) do
			local xx, yy = v.position[1], v.position[2]
			local rotation = f.cart.conf.rotation
			local speed = v.speed
			local done = false
		 	repeat
				if v.moving == 'up' then
					if f.cart.tiles[math.floor(xx / 32)][math.floor((yy - 30) / 32)] then
						v.position[2] = v.position[2] - speed
						imagepos(v.image, v.position[1] , v.position[2] , rotation)
						done = true
					else
						if f.cart.tiles[math.floor((xx - 30) / 32)][math.floor(yy / 32)] then
							v.moving = 'left'
						elseif f.cart.tiles[math.floor((xx + 30) / 32)][math.floor(yy / 32)] then
							v.moving = 'right'
						else
							v.moving = 'down'
						end
						v.position[1] = math.floor(v.position[1] / 32)*32+16
						v.position[2] = math.floor(v.position[2] / 32)*32+16
					end
					parse('setpos '.. v.inside ..' '.. v.position[1] ..' '.. v.position[2])
				elseif v.moving == 'down' then
					if f.cart.tiles[math.floor(xx / 32)][math.floor((yy + 30) / 32)] then
						v.position[2] = v.position[2] + speed
						imagepos(v.image, v.position[1] , v.position[2] , -rotation)
						done = true
					else
						if f.cart.tiles[math.floor((xx - 30) / 32)][math.floor(yy / 32)] then
							v.moving = 'left'
						elseif f.cart.tiles[math.floor((xx + 30) / 32)][math.floor(yy / 32)] then
							v.moving = 'right'
						else
							v.moving = 'up'
						end
						v.position[1] = math.floor(v.position[1] / 32)*32+16
						v.position[2] = math.floor(v.position[2] / 32)*32+16
					end
					parse('setpos '.. v.inside ..' '.. v.position[1] ..' '.. v.position[2])
				elseif v.moving == 'left' then
					if f.cart.tiles[math.floor((xx - 30) / 32)][math.floor(yy / 32)] then
						v.position[1] = v.position[1] - speed
						imagepos(v.image, v.position[1] , v.position[2] , rotation-90)
						done = true
					else
						if f.cart.tiles[math.floor(xx / 32)][math.floor((yy - 30) / 32)] then
							v.moving = 'up'
						elseif f.cart.tiles[math.floor(xx / 32)][math.floor((yy + 30) / 32)] then
							v.moving = 'down'
						else
							v.moving = 'right'
						end
						v.position[1] = math.floor(v.position[1] / 32)*32+16
						v.position[2] = math.floor(v.position[2] / 32)*32+16
					end
					parse('setpos '.. v.inside ..' '.. v.position[1] ..' '.. v.position[2])
				elseif v.moving == 'right' then
					if f.cart.tiles[math.floor((xx + 30) / 32)][math.floor(yy / 32)] then
						v.position[1] = v.position[1] + speed
						imagepos(v.image, v.position[1] , v.position[2] , rotation+90)
						done = true
					else
						if f.cart.tiles[math.floor(xx / 32)][math.floor((yy - 30) / 32)] then
							v.moving = 'up'
						elseif f.cart.tiles[math.floor(xx / 32)][math.floor((yy + 30) / 32)] then
							v.moving = 'down'
						else
							v.moving = 'left'
						end
						v.position[1] = math.floor(v.position[1] / 32)*32+16
						v.position[2] = math.floor(v.position[2] / 32)*32+16
					end
					parse('setpos '.. v.inside ..' '.. v.position[1] ..' '.. v.position[2])
				else
					done = true
				end
			until done
			
			if v.speed > 0 and v.moving ~= 'stopped' and f.cart.boost[math.floor(v.position[1] / 32)][math.floor(v.position[2] / 32)] == true then
				v.speed = f.cart.conf.startingspeed
			end
			
			for _, id in pairs(player(0, 'table')) do
				if (player(id, 'tilex') == math.floor(v.position[1] / 32)) and (player(id, 'tiley') == math.floor(v.position[2] / 32)) then
					if v.inside ~= id then
						v.moving = 'stopped'
					end
				end
			end
			
			v.speed = v.speed - f.cart.conf.friction
			if v.speed <= 0 then
				v.speed = 0;
				v.moving = 'stopped'
			end
			
			if v.moving == 'stopped' then
				parse('setpos '.. v.inside ..' '.. v.position[1] ..' '.. v.position[2])
			end
		end
	end;
	
	move = function(id, x, y, walk)
		if walk == 0 then
			for k, v in pairs(f.cart.table) do
				if v.moving == 'stopped' then
					if v.inside ~= id then
						if math.floor(v.position[1] / 32) == math.floor(x / 32) and math.floor(v.position[2] / 32) == math.floor(y / 32) then
							local rot = player(id, 'rot')
							if rot > -45 and rot < 45 then
								v.moving = 'up'
							elseif (rot > 135 and rot < 180) or (rot > -180 and rot < -135) then
								v.moving = 'down'
							elseif rot > 45 and rot < 135 then
								v.moving = 'right'
							elseif rot > -135 and rot < -45 then
								v.moving = 'left'
							end
							v.speed = f.cart.conf.startingspeed
						end
					end
				end
			end
		end
	end;
	
	startround = function()
		for k, v in pairs(f.cart.table) do
			v.inside = 0
			v.position[1], v.position[2] = v.startingposition[1], v.startingposition[2]
			v.speed = 0
			v.image = image(f.cart.conf.imagepath, v.position[1], v.position[2], 0)
		end
	end;
	
	use = function(id)
		for k, v in pairs(f.cart.table) do
			local xx, yy = v.position[1], v.position[2]
			if math.sqrt((yy - player(id, 'y'))^2 + (xx - player(id, 'x'))^2) < 45 then
				if v.inside == id then
					v.inside = 0
				elseif v.inside == 0 then
					v.inside = id
				end
				break
			end
		end
	end;
	
	die = function(victim, weapon, killer, x, y)
		for k, v in pairs(f.cart.table) do
			if v.inside == victim then
				v.inside = 0
			end
		end
	end;
	
	leave = function(id)
		for k, v in pairs(f.cart.table) do
			if v.inside == id then
				v.inside = 0
			end
		end
	end;
}
local pico8 = require "pico8"
local bit = require "bit"

-- pico-8 cartridge // http://www.pico-8.com
-- version 42
-- __lua__
--      -- birds with guns --
--by yolwoocle & gouspourd
--extra credits :notgoyome
--music: simon t.

--bird ideas
--crow,owl,raven,pelican,goose,
--colibri,dinosaur,cockatiel
--peafowl

-- 2023-02-05 stealth patch by
-- zep to fix 0.2.5g breakage
-- (nested comments no longer
-- supported)

degaplus = 0

function _init()
	keyboard = false
	initguns()
	enemies,checker = {},{}
	--mouse
	mx,my=0,0  
	
	--flags
	solid,breakable,spawnable,lootable,notbulletsolid=0,1,2,3,4
	
	--camera
	shake,camy,camx,targetcamx=0,0,0,0
	
	cam_follow_player=true
--	trainpal = {{8,2},{11,3},
--	{7,13},{12,13},{10,9},{0,2}}
	
	-- zep:
	trainpal = split"8,2,11,3,7,13,12,13,10,9,0,2,8,2"
	
	pal_n,menu = 1,"main"
	
	actors = {}
	init_enemies()
	init_player(111)
	
	init_ptc()
	wl,diffi = 4,20
	
	--wagon length
	wagon_n,trainlen = 0,6
	tl = trainlen
	
	gen_train()
	update_room()
	random,enemies = {},{}
	parcourmap()
	
	drops={}
	
	init_menus()
	
	birdchoice,hardmodetimer=0,0
	ofsetboss,bullets_shooted,bullets_hit = 0,1,1
	
	stats={
	 time=0,
	 kills=0,
	 wagon=0,
	}
	
	is_boss = false
	boss_pos = {0,0}
	win,wintimer = false,0
	
	--darker blue
	--pal(1,130,1)
	--pal(1,129,1)
	pal()
	poke(0x5f2e,1)
	
	local s = stat(6)
	if s == "-"
	or s == "" 
	or s == nil then
		menu="main"
	else
		menu="game"
		birdchoice=tonum(stat(6))
		begin_game()
	end
	
end

function _update60()
	mouse_x_y()
	for i=0x3100,0x3148 do
		--on
		poke(i,bit.band(peek(i),0xBF))
	end
	

	if hardmodetimer > 90 and 
	menu == "main" and diffi ~= 17 then
		sfx(44)
		shake,diffi = 5,17
		degaplus = 1
		initguns()
		init_enemies()
	end

	grasstile()
	if(win) then wintimer = wintimer + 1 end
	if wintimer == 180 then
		menu="win" 
		set_stats()
	end
	--if(wintimer==180)sfx(46)
	if menu == "game" then
		delchecker()
		
		update_drops()
		player_update()
		
		for a in all(actors) do
			--actors are just bullets
			a:update()
			
			if a.destroy_flag then
				if a.dmg == 0 then
					animexplo(a)
					guns.explosion:fire(a.x-a.dx*2,a.y-a.dy*2,1)
				elseif a.dmg == 0.1 then
					--firework launcher
					for i=1,10 do
						sfx(32)
						guns.machinegun:shoot(a.x-a.dx*2,a.y-a.dy*2,i/10)
					end
				end
				del(actors,a)
			end
		end
		
		--for e in all(enemies) do
			update_enemy(e)
			--if(e.destroy_flag)del(enemy,e)
		--end
		
		for ptc in all(particles) do
			update_ptc(ptc)
			if(ptc.destroy) then del(particles,ptc) end
		end
		
		update_door()
		
		--shake = 0
		
		update_camera()
	elseif menus[menu] then
		local m = menus[menu]
		m.update(m)
		sprms = 127
	end
	
	shake = max(0,shake-0.3)
	
	local txt=keyboard and "keyboard" or "mouse+keys"
	menuitem(3,"mode:"..txt, function() keyboard = not keyboard end)
	menuitem(2,"⌂ main menu", function() run("-") end)
	
	if (btn(BTN_X) or btn(BTN_O))then  keyboard = true end
	if (lmb)then  keyboard = false end
end


function _draw()
	local ox = rrnd(shake)
	local oy = rrnd(shake)
	--if (keyboard == true) 
	camera(camx+ox, camy+oy)
	
	cls(15)
	
	--draw map
	drawgrass()
	
	draw_map()
	if wagon_n==0 and menu=="game" then
		local s= [[
  ⬆️        [e]
⬅️⬇️➡️ or [s d f] 
     move 

[click]  shoot
[scroll] change 
          weapon
		]]
		if(keyboard)then s=[[
    ⬆️
  ⬅️⬇️➡️ move 

  ❎ (x) shoot
  🅾️ (c) change 
         weapon
        ]]
        end
		print(s,33,42,2)
	end

	draw_wheel()
	
	draw_drops()
	
	for e in all(enemies) do
		draw_enemy(e)
	end
	draw_player()
	
	for a in all(actors) do
		a:draw()
	end
	
	for ptc in all(particles) do
		draw_ptc(ptc)
	end
	
	if(menu~="main")then draw_player_ui(azertyuiop)end
	
	local m = menus[menu]
	if m then
		m.draw(m)
	end
	
	-->>no code below this<<--
	--draw mouse
	
	if(not keyboard or menu=="game")then spr(sprms,mx-1,my-1) end
	pal(1,129,1)
end

----------
function set_stats()
	stats.time=flr(
	 (time()-stats.time) * 10) / 10
	local t = stats.time
	local s = ""
	if(t%60 < 10)then  s="0" end
	stats.time= tostr(flr(t/60))..":"..s..tostr(t%60) 
	--stats.time=(flr(stats.time)\60)+((flr(stats.time)-(flr(stats.time)\60)*60)/100)
	stats.wagon=tostr(wagon_n+1).."/7"
end

function begin_game()
	sfx(37)
	music()
	
	local b=birdchoice or 0
	if b == 0 then
		b=flr(rnd(12))+1
	end
	init_player(111+b)
	
	stats.time = time()
	
	azertyuiop.x,azertyuiop.y = 48,56
	
	shake = shake + 7
	for i=1,10 do
		make_ptc(
		 48 + rrnd(8),
		 56 + rrnd(8),
		 8+rnd(8),rnd({2,4,6}),0.97,
		 rrnd(2),rrnd(2)
		)
	end
end

function isleft(a)
	return a<.75 and .25<a
end

function ospr(s,x,y,col)
	for i=0,15 do
		pal(i,col)
	end
	
	for i=-1,1 do
		for j=-1,1 do
			spr(s,x+i,y+j)
		end
	end
	
	pal()
	spr(s,x,y)
end

function oprint(t,x,y,col,ocol)
	local ocol = ocol or 1
	for i=-1,1 do
		for j=-1,1 do
			print(t,x+i,y+j,ocol)
		end
	end
	
	local col = col or 7
	print(t,x,y,col)
end

function copy(t)
	local n={}
	for k,v in pairs(t) do
		n[k] = v
	end
	return n
end

function update_camera()
	local px = azertyuiop.x
	local wl = wl
	local maxlen = 240
	
	--poke(0x5f40,0)
	poke(0x5f43,0)
	if px > 128*(wl-1)+8 then
		--pan cam to connector room
		cam_follow_player=false
		targetcamx=128*(wl-1)
		
		--block off old entrance
		if wagon_n ~= tl-1 then
			--mset(48,7,6)
			--mset(48,6,13)
		end
		
		--low-pass filter & slow
		--poke(0x5f40,15)
		if(wagon_n~=tl)then poke(0x5f43,15) end
	end
	if cam_follow_player then 
		--camera follows player
		camx = px-60
		--offset camera to cursor
		if not keyboard then
		camx = camx + (stat(32)-64)/3
		end
		camx = flr(mid(0, camx, 128*(wl-2)+8) / 1)
		camy = 0
	else
		--do a cool animation
		camx=ceil(
		 camx+(targetcamx-camx)/10)
		
		if targetcamx <= 0
		and ceil(camx)==targetcamx then
			cam_follow_player=true
		end
	end
end

function draw_ghost_connector()
	if camx<0 then
		map(0,16, -128,0, 16,16)
	end
end

function rrnd(n)
	--"radius rnd"
	return rnd(2*n)-n
end

function allbtn(b)
	return btn(b) or btn(b,1)
end

--[[
function debug_()
	local p =players[1]
	p.gunls[1] = debuggun
	wagon_n = tl-1
	for i in all(enemies)do 
		i.destory = true
	end
	p.maxlife = 10000
	p.life = 10000
end--]]

-->8
--player
function init_player(bird)
	b=0
	dx1=1
	dy1=0
	azertyuiop = {
		n=1,
		agro = 9999,
		x=-64,y=-64,
		dx=0,dy=0,
		a=0,
		
		spd=.4,
		fric=0.75,
		
		bx=2,by=2,
		bw=4,bh=4,
		
		hx=2,hy=2,
		hw=4,
		
		life=10,
		maxlife=10,
		ammo=250,
		maxammo=250,
		
		spr=bird,
		
		gun=nil,
		gunn=1,
		gunls={},
	
		lmbp = true,
		iframes=30,
		
		damage=damage_player,
		spriteoffset = 0,
		kak = copy(kak)
	}

	azertyuiop.gun = azertyuiop.gunls[1]

	--should we keep this in? bird stats

	local n = bird-111
	local bird_stats=split[[n,     1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12
,life,   10, 10, 5,  10, 10, 10, 10, 10, 10, 2,  10, 10
,maxlife,10, 10, 5,  10, 10, 10, 10, 10, 10, 15, 10, 10
,spd,    .4, .4, .4, .4, .4, .4, .4, .4, .55, .4, .4, .4
,fric,   .75,.75,.75,.75,.75,.75,.75,.75,.75,.74,.75,.75
]]
	for i=1,#bird_stats,13 do
		--p[bird_stats[i] ] = bird_stats[i+n]
	end
	--                        [    default    ][     pigeon    ][       duck         ][         sparrow            ][          parrot          ][    toucan         ][     flamingo   ][         eagle            ][    seagull       ][      ostrich     ][    penguin  ][      jay           ][     chicken    ] 
	local bird_weapons=split"revolver,shotgun,revolver,shotgun,revolver,flamethrower,boxing_glove,fireworklauncher,machinegun,fireworklauncher,boxing_glove,shotgun,revolver,ringcannon,boxing_glove,assaultrifle,machinegun,sniper,machinegun,gatlinggun,shotgun,sniper,shotgun,assaultrifle,revolver,bazooka"
	
	for i=1,2 do
		azertyuiop.gunls[i] = copy(guns[bird_weapons[2*n+i] ])
	end
	
	update_gun(azertyuiop)
end

function player_update()
	 --damage
	 azertyuiop.iframes = max(0,azertyuiop.iframes-1)
		--movement
		local dx,dy = azertyuiop.dx,azertyuiop.dy
		local spd = azertyuiop.spd
		
		if (allbtn(BTN_LEFT)) then 
			azertyuiop.dx = azertyuiop.dx - spd
			dx1 = dx1 - spd
		end
		if (allbtn(BTN_RIGHT)) then 
			azertyuiop.dx = azertyuiop.dx + spd
			dx1 = dx1 + spd
		end
		if (allbtn(BTN_UP)) then 
			azertyuiop.dy = azertyuiop.dy - spd
			dy1 = dy1 - spd
		end
		if (allbtn(BTN_DOWN)) then 
			azertyuiop.dy = azertyuiop.dy + spd
			dy1 = dy1 + spd
		end
		
		--58
		
		azertyuiop.dx = azertyuiop.dx * azertyuiop.fric
		azertyuiop.dy = azertyuiop.dy * azertyuiop.fric
		
  if (abs(dx1)+abs(dy1))>0.1 then
		dx1 = dx1 * azertyuiop.fric
		dy1 = dy1 * azertyuiop.fric
		end
		
		collide(azertyuiop,0.1)
		
		azertyuiop.x = azertyuiop.x + azertyuiop.dx
		azertyuiop.y = azertyuiop.y + azertyuiop.dy
		
		
		--animation
		
		if abs(azertyuiop.dx)+abs(azertyuiop.dy)>0.75  then
		 animplayer(azertyuiop)
		else 
			azertyuiop.spriteoffset = 0
		end
		
		--aiming
		if keyboard then
			sprms=76
			distmin=9999
			indexmininit={x=azertyuiop.x-ofsetboss+dx1,y=azertyuiop.y-ofsetboss+dy1}
			indexmin=indexmininit
			for e in all(enemies) do
			 	if loaded(e) and 
			 	canshoot(azertyuiop,e) then
					local dist = dist(azertyuiop,e)
					if (distmin>dist) then distmin=dist indexmin=e end
				end
			end

			ofsetboss = 0
			if(indexmin.spr == 1) then ofsetboss = 4 end

			azertyuiop.a = atan2(indexmin.x+ofsetboss-azertyuiop.x,
			indexmin.y+ofsetboss-azertyuiop.y)
			mx=indexmin.x+1+ofsetboss
			my=indexmin.y+1+ofsetboss
			if(indexmin==indexmininit) then sprms=57 end
		else
			sprms = 127
			azertyuiop.a = atan2(mx-azertyuiop.x,
			my-azertyuiop.y)	
		end
		azertyuiop.flip = isleft(azertyuiop.a)
		
		--ammo & life
		azertyuiop.life=min(max(0,azertyuiop.life),azertyuiop.maxlife)
		azertyuiop.gun.ammo=min(max(0,azertyuiop.gun.ammo),azertyuiop.gun.maxammo)
		
		--death
		if azertyuiop.life <= 0 
		and menu~="death"then
			sfx(34)
			music(-1, 300)
			
			menu = "death"
			shake = shake + 9
			burst_ptc(azertyuiop.x+4,azertyuiop.y+4,7)
			
			set_stats()
		end
		
		--shooting
		if stat(36) ==1 or stat(36) ==-1 or (btnp(BTN_O)) then
			nextgun(azertyuiop)
			--print(p.gun.cooldown,0,0)
			azertyuiop.gun.timer = azertyuiop.gun.cooldown/2
		end
		
		
		local fire=lmb or btn(BTN_X) 
		local active=rmb
		
		local dofire
		
		azertyuiop.kak:update()
		azertyuiop.gun:update()
		test = azertyuiop.gun.name
		-- not auto
		if fire and
		azertyuiop.gun.timer<=0 and
		azertyuiop.gun.ammo > 0 and azertyuiop.gun.auto == false
		then
			if azertyuiop.lmbp == true then
				dofire = true
				
				azertyuiop.lmbp = false
			end
			
		-- auto
		elseif fire and azertyuiop.gun.timer<=0 
		and azertyuiop.gun.ammo > 0 then
			dofire = true
		elseif fire and
        azertyuiop.gun.ammo < 1 and
        azertyuiop.lmbp == true and
        azertyuiop.kak.timer<=0 then
        coupdekak(azertyuiop) 
        azertyuiop.lmbp = false
		end
		
		if dofire then
			make_ptc(azertyuiop.x+cos(azertyuiop.a)*6+4, 
				azertyuiop.y+sin(azertyuiop.a)*3+4, rnd(3)+6,7,.7)
				
			azertyuiop.gun.ammo = azertyuiop.gun.ammo - 1
			azertyuiop.gun:fire(azertyuiop.x+4,azertyuiop.y+4,azertyuiop.a)
		end
		
		-- if mleft not pressed 
		if not fire then
			azertyuiop.lmbp = true
		end
		
		--begin boss
		local w3=128*(wl-1)
		
		if wagon_n==tl and azertyuiop.x>w3 
		and cam_follow_player 
		and not is_boss then
			is_boss = true
			begin_boss()
			azertyuiop.x = w3+8
		end
		
		--next wagon
		if azertyuiop.x>128*wl then
			random = {}
			
			wagon_n = wagon_n + 1
			update_room()
			enemiescleared=false
			pal_n = pal_n + 1
			
			--pan cam to next wagon
			camx = -128
			targetcamx=0
			drops = {}
			enemies = {}
			parcourmap()
			--teleport players
			azertyuiop.x = azertyuiop.x - 128*wl
			azertyuiop.x = max(azertyuiop.x, 0)
		end
		for e in all(enemies)do
			
			if touches_rect(
			azertyuiop.x+4,azertyuiop.y+4,
			e.x+1,e.y+1,e.x+7,e.y+7) then
				
				if (azertyuiop.iframes == 0) then
					sfx(35)
					if(shake<=2)then shake = shake + 2 end
					if e.spr ~= 126 then
						azertyuiop.life = azertyuiop.life - 1+(degaplus*2)
					else 
						azertyuiop.life = azertyuiop.life - 1+degaplus
					end
					azertyuiop.iframes = 30
					
					if e.spr == 109 then
					 azertyuiop.life = azertyuiop.life + 1
					 killbarelle(e)
					 azertyuiop.iframes = 0
					end
				end
				knockback_player(azertyuiop,e)
			
			end
		end
end

function draw_player()
	if (azertyuiop.iframes%5) == 0  then
		local x=flr(azertyuiop.x) + cos(azertyuiop.a)*6 +0
		local y=flr(azertyuiop.y) + sin(azertyuiop.a)*3 +0
		
		if azertyuiop.gun.name=="sniper" then
			local c,s=cos(azertyuiop.a),sin(azertyuiop.a)
			line(
			x+4+c*6,
			y+4+s*6,
			azertyuiop.x+c*128,
			azertyuiop.y+s*128,8)
		end
		spr(azertyuiop.gun.spr,x,y,1,1, azertyuiop.flip)
		
		
		palt(0,false)
		palt(1,true)
		
		spr(azertyuiop.spr,azertyuiop.x,azertyuiop.y+azertyuiop.spriteoffset,1,1, azertyuiop.flip)
		
		palt()
	end
end

function draw_player_ui(p)
	--life counter
	rectfill(camx+1,1,camx+43,7,2)
	local l=40*(p.life/p.maxlife)
	rectfill(camx+2,2,camx+2+l,6,8)
	
	local s="♥"..p.life.."/"..p.maxlife.." "
	print(s, camx+2,2,7)
	
	--ammo bar
	rectfill(camx+84,1,camx+84+42,7,4)
	local l=40*(p.gun.ammo/p.gun.maxammo)
	if(p.ammo>0)then rectfill(camx+85,2,camx+85+l,6,9) end
	
	local s,col = tostr(p.gun.ammo),7
	if(s=="0") then s,col="no ammo!",14 end
	spr(110,camx+89,2)
	print(s, camx+95,2,col)
	
	--weapon list
	for i=1,2 do
		local col = 1
		if(i==p.gunn)then col=7 end
		
		ospr(p.gunls[i].spr, 
		camx+90+(i-1)*10, 10,col)
	end
	
	--wagon
	local color = 7
	if degaplus == 1 then
		color = 8
		else color = 7
	end
	oprint("wagon "..wagon_n+1 .."/7",
	camx+46,2,color,1)
	--print(test,0,80)
end

function nextgun(p)
	sfx(36)
	
	p.gunn = p.gunn + 1
	if(p.gunn > #p.gunls)then  p.gunn = 1 end
	update_gun(p)
	--[[local f = 0
	for i=1,#p.gunls do
	if p.gunls[i] == p.gunn then
		if (((i+stat(36))%#p.gunls)<1) f = #p.gunls
		 return p.gunls[(i+stat(36))%(#p.gunls)+f]
		end
	end]]
end

function update_gun(p)
	p.gun = p.gunls[p.gunn]
end

function knockback_player(p,e)
	if abs(p.dx)+abs(p.dy) < 3 then
			  p.dx = p.dx + e.dx*e.spd*2
				 p.dy = p.dy + e.dy*e.spd*2
			end	
end

function knockback_enemy(e,b)
	
		if (abs(e.dx)+abs(e.dy<30)) then
			e.dx = e.dx + b.dx*b.spd*.1
			e.dy = e.dy + b.dy*b.spd*.1
		end

end

function animplayer(p)
	if flr(time()*7)%2==1 then
		p.spriteoffset = 1
	else 
		p.spriteoffset = 0
	end
end

function coupdekak(p)
	local x=flr(p.x) + cos(p.a)*6 +0
	local y=flr(p.y) + sin(p.a)*3 +0
	
	p.kak:fire(x+4,y+4,p.a)
end
-->8
--gun & bullet

function make_gun(args,fire)
	local name_,sprr,cd_,spd,oa,dmg,is_enemy,auto,maxammo,sfxx,knockback=unpack(split(args))

	
	is_enemy = is_enemy == 1
	auto = auto  == 1
	if(is_enemy) then dmg = dmg + degaplus * 2 end
	
	--todo:not have 3000 args
	local gun = {
		name=name_,
		spr=sprr,
		spd=spd,
		oa=oa,--offset angle in [0,1[
		dmg=dmg,
		shake=shake,
		auto=auto,
		
		ammo=maxammo,
		maxammo=maxammo,
		
		timer=0,
		cooldown=cd_,
		is_enemy=is_enemy,
		
		x=0,y=0,
		dir=0,
		burst=0,
		
		sfx=sfxx,
		knockback=knockback,
	}
	
	gun.fire = fire
	
	gun.shoot=function(gun,x,y,dir,spd,knockback)
		--remove? it complicates code
		if(gun.burst<=0)then dir = dir + rrnd(gun.oa) end
		
		if(gun.sfx)then  sfx(gun.sfx) end
		
		local s=93
		local name = gun.name
		local palette = ""

		if(gun.is_enemy)then s=95 end
		if(name=="kak")then s=77 lifspa=5 end
		if(name=="boxing glove")then s,lifspa=77,10 end
		if(name=="flamethrower")then  lifspa=40 palette="1,2,3,4,5,6,10,8,8,9" end
		if(name=="explosion")then s=57 lifspa=10 end
		if(name=="bazooka")then  palette="1,2,3,4,5,6,6,8,5,13" end
		if not gun.is_enemy then
			if(shake<1 and name~="flamethrower")then shake = shake + 1 end
		end
		
		spd = spd or gun.spd
		spawn_bullet(x,y,dir,
		spd,3,s,dmg,is_enemy,lifspa,palette)
		lifspa=nil
		gun.timer = gun.cooldown
		azertyuiop.dx = azertyuiop.dx - cos(dir)*gun.knockback
		azertyuiop.dy = azertyuiop.dy - sin(dir)*gun.knockback
	end
	
	gun.update=function(gun)
		gun.timer = max(gun.timer-1,0)
		gun.ammo = mid(0,gun.ammo,gun.maxammo)
		
		if gun.burst > 0 then
			gun:shoot(gun.x,gun.y,gun.dir)
			gun.burst = gun.burst - 1
		end
	end
	
	return gun
end

function shoot1(gun,x,y,dir)
	gun:shoot(x,y,dir)
end

-- init guns

--degaplus = 0
                   --name      spr cd spd oa dmg is_enemy auto maxammo sfx knock
--debuggun = make_gun("debuggun, 64, 1, 3, .02, 0, 0,       1,   999999, 64, 1",
--		function(gun,x,y,dir)
--	  for i=1,7 do
--	 		p.life = p.life + 1
--	 		gun:shoot(x,y,dir+rrnd(.1), ospd)
--	 	end
--end
--		function(gun,x,y,dir)
--			gun:shoot(x,y,dir)
--		end
--	)
function initguns()
guns = {

                       --name   spr cd spd oa dmg is_enemy auto maxammo sfx
	revolver = make_gun("revolver, 64, 15,2.5,.02,3 ,0,       0,   100,    33, 0.3",
		shoot1
	),
	
	
	fireworklauncher = make_gun("firework launcher, 74, 25,2.5,.02,0.1 ,0,       0,   80,    52, 0.6",
		shoot1
	),
	
	boxing_glove = make_gun("boxing glove, 72, 18,3.3,.005,1 , 0, 0, 1,      53, -0.96",
 function(gun,x,y,dir)
  for i=1,7 do
			gun:shoot(x,y,dir)
		end
		azertyuiop.iframes,gun.ammo = 9,gun.maxammo
		end
 ),
	
	
	bazooka = make_gun("bazooka, 69, 90,1.5,.007,0 ,0,       0,   20,    33, 4.5",
		shoot1
	),
	
	flamethrower = make_gun("flamethrower, 70, 2,1.5,.015,0.34 ,0,       1,   1500,    51, 0",
		shoot1
	),
	
	ringcannon = make_gun("ring cannon,    71, 45,2, .01,3,  0,   0,  50,    32, 0",
	 function(gun,x,y,dir)
	 	for i=1,20 do
	 		local o=i/20
	 		local ospd=gun.spd*(rnd(.2)+.9)
	 		gun:shoot(x,y,dir+o, ospd)
	 	end
	 end),
	                    --name    spr cd spd oa dmg is_enemy auto maxammo sfx
	shotgun = make_gun("shotgun,    65, 60,4, .05,1.25,  0,   0,  50,    32, 0.4",
	 function(gun,x,y,dir)
	 	for i=1,7 do
	 		local o=rrnd(.05)
	 		local ospd=gun.spd*(rnd(.2)+.9)
	 		gun:shoot(x,y,dir+o, ospd)
	 	end
	 end),
	 
	                         --name      spr cd spd oa dmg is_enemy auto maxammo sfx
	machinegun = make_gun("machinegun, 66, 7, 3, .05,2  ,0,       1, 250,    33, .2",
		shoot1
	),
	
	                          --name           spr cd spd oa dmg is_enemy auto maxammo sfx
	assaultrifle = make_gun("assault rifle, 67, 30,4, .02,1   ,0,       1, 75,      33, .3",
		function(gun,x,y,dir)
			gun.burst = 4
			gun.x, gun.y = x, y
			gun.dir =dir+(rrnd(1))*gun.oa
			gun:shoot(x,y,gun.dir)
		end
	),
	
	                   --name  spr cd spd oa dmg is_enemy auto maxammo sfx
	sniper = make_gun("sniper, 68, 40,7, .0, 5  ,0,        0,  35,     32, 3",
		shoot1
	),
	
	                            --name  spr cd spd oa dmg is_enemy auto maxammo sfx   kb
	gatlinggun = make_gun("gatling gun, 73, 3, 3, .08, 2  ,0,        1,  500,     33, 1",
		shoot1
	),
	
	                      --name      spr cd  spd oa   dmg is_enemy auto maxammo sfx kb
	gunslime = make_gun("gunslime, 64, 100,1.5, .02,2,  1,       1,   250,    32, 0",
		function(gun,x,y,dir)
			dir = dir + rrnd(gun.oa)
			gun:shoot(x,y,dir)
		end
	),
	
                              --name      spr cd spd   oa dmg is_enemy auto maxammo sfx
	gunslimebuff = make_gun("gunslimebuff, 64, 100,1, .04,2,  1,       1,   250, 32, 0",
		function(gun,x,y,dir)
			for i=0,2 do
				local o=rrnd(.05)
				local ospd=gun.spd*(rnd(.2)+.9)
				gun:shoot(x,y,dir+o, ospd)
			end
		end
	),
	
	
	shotgunmechant = make_gun("shotgunmechant, 65, 60,1.35, .04,3, 1, 1, 250, 32, 0",
		function(gun,x,y,dir)
	 		for i=1,4 do
	 			local o=rrnd(.05)
	 			local ospd=gun.spd*(rnd(.2)+.9)
	 			gun:shoot(x,y,dir+o, ospd)
	 		end
		end
	),
	 
	 null = make_gun("null, 57, 0,57, 0,1,  1,  1, 250, 32,0",
	 function() --opti: remove args
	 end),
	 
	 machinegunmechant = make_gun("machinegunmechant, 66, 5, .75,.05,2, 1, 1,250, 32, 0",
		shoot1
	),
	
	explosion = make_gun("explosion, 57, 0, 2,  0,5   ,1,  0, 1, 32, 0",
		function(gun,x,y,dir)

			for i=1,12 do
	 		local o=i/12
	 		gun:shoot(x,y,dir+o)

	 	end
	end

	),
	
	boss_targetgun = 
	make_gun("boss target gun, 65, 6, 1.2,.05,2, 1,  1, 250, 47, 0",
		shoot1
	),
	
	boss_360gun = 
	make_gun("boss 360 gun, 65, 1, 1,  0,2  ,1,  1,	250,    47, 0",
		function(gun,x,y,dir)
			gun.dir = gun.dir + .176666
			gun:shoot(x,y,gun.dir)
		end
	),
	
	boss_enemygun = 
	make_gun("boss_enemygun, 65, 150, 1, 1,2   ,1,  1, 250, 33, 0",
		function(gun,x,y,dir)
			sfx(33)
			gun.timer = gun.cooldown
			if(rnd(2)<1)then return spawn_enemy(x,y,enemy.hedgehog) end
			spawn_enemy(x,y,enemy.hedgehogbuff)
		end
	),
}
	--table of number-indexed guns
	iguns={}
	for k,v in pairs(guns)do
		if(not v.is_enemy)then add(iguns,v)end
	end
end

kak = make_gun("kak, 57, 20,2.1,.005,3 , 0, 0, 0,      36, 1",
	shoot1
)


function rnd_gun()
	--todo: "power" param
	--later weapons should be  
	--more powerful
	return rnd(iguns)
end

function spawn_bullet(x,y,dir,spd,r,spr,dmg,is_enemy,lifspa,palette)
	local dx=cos(dir)*spd
	local dy=sin(dir)*spd
	add(actors,{
		x=x,  y=y,
		dx=dx,dy=dy,
		r=4,
		dmg=dmg,
		spd=spd,
		spr=spr,
		is_enemy=is_enemy,
		destroy_flag=false,
		dir=dir,
		
		update=update_bullet,
		draw=draw_bullet,
		lifspa=lifspa,

		palette=palette,
	})
end

function update_bullet(b)
 if not(b.lifspa== nil)then
  b.lifspa = b.lifspa - 1
  if (b.lifspa== 0) then b.destroy_flag = true end
 end
	b.x = b.x + b.dx
	b.y = b.y + b.dy
	
	local bx,by = b.x,b.y 

	debug=""
	if b.is_enemy then
		
		local x2 = azertyuiop.x+azertyuiop.hx+azertyuiop.hw
		local y2 = azertyuiop.y+azertyuiop.hx+azertyuiop.hw 
		if touches_rect(bx,by,
		azertyuiop.x+azertyuiop.hx, azertyuiop.y+azertyuiop.hy,
		x2,y2) then
			
			if azertyuiop.iframes == 0 then
				azertyuiop.life = azertyuiop.life - b.dmg 
				azertyuiop.iframes = 30
				sfx(35)
			end
			if(shake<=4)then shake = shake + 4 end
			knockback_player(azertyuiop,b)
			make_ptc(bx,by,rnd(4)+6,7,.8)
			b.destroy_flag = true
			
		end
	end
		
	if not(b.is_enemy) or b.spr == 57 then
		
		for e in all(enemies)do
		 if loaded(e) then
			local x2 = e.x+e.hx+e.hw
			local y2 = e.y+e.hx+e.hw 
			
			if touches_rect(bx,by,
			e.x+e.hx,e.y+e.hy,
			x2,y2) then
				
				sfx(46)
				e.life = e.life - b.dmg
				if e.life<=0 then
					--kill enemy
					stats.kills = stats.kills + 1 del(enemies,e)
					spawn_loot(e.x,e.y)
					if e.spr ~= 109 then
					burst_ptc(e.x+4,e.y+4,8,1,1,1)
					
					--boss death
					if e.spr==1 then
						shake = shake + 10
						boss_pos = {e.x,e.y,e.flip}
						menu = "bossdeath"
					end
					
					else --animation explosion
						killbarelle(e)
					end
				end
				bullets_hit = bullets_hit + 1
				
				knockback_enemy(e,b)
				
				e.timer = 5
				make_ptc(bx,by,rnd(4)+6,7,.8)
				b.destroy_flag = true
				return
			end
		end
		end
	end
	
	--destroy on collision
	if (is_solid(bx,by)
	and not check_flag(
	    notbulletsolid,bx,by)) 
	or bx+11<camx 
	or bx>camx+139 
	or by<-8 or by>132
	then
		
		if check_flag(breakable,bx,by) then
			--sfx(47)
			if check_flag(lootable,bx,by)then
				break_crate(bx,by)
			end
			mset(flr(bx/8),flr(by/8),39)
			add(random,{
			 x=(flr(bx/8))*8+4,
			 y=(flr(by/8))*8+4,
			 spr=rnd{55,22,39},
			 f=rnd{true,false},
			 r=rnd{true,false}
			})
		end
		make_ptc(bx,by,rnd(4)+6,7,.8)
			
		b.destroy_flag = true
	end
end

function draw_bullet(b)
	pal(split(b.palette))
	spr(b.spr, b.x-4, b.y-4,1,1, azertyuiop.flip)
	pal()
end

function draw_random()
for i in all(random)do
	 spr(i.spr, i.x-4, i.y-4,1,1,i.f,i.r)
	end
end

function killbarelle(e)
 animexplo(e)
	e.gun:fire(e.x+4,e.y+4,e.a)
	del(enemies,e)
end

function animexplo(e)
for i=1,15 do
		make_ptc(
					e.x + rrnd(14),
					e.y + rrnd(14),
			8+rnd(8),rnd{9,10})
	end
sfx(37)
shake = shake + 7
end

--------

--[[
function spawn_bullet(x,y,type_bullet,speed,timer_bullet1,sprite,nb_bullet,ecartement)
	if timer_bullet == 0 then
		local xy = get_traj(x,y,mouse_x,mouse_y)
		local traj_x = xy.x*speed
		local traj_y = xy.y*speed
		local angle = xy.angle
		timer_bullet = timer_bullet1
		
		if type_bullet == 1 then
			nvelement = {
			  x=x,y=y,
			  type_bullet=type_bullet,
			  traj_x=traj_x,
			  traj_y=traj_y,
			  sprite=sprite
			}
			rafale(10,nvelement)
		end
	 
	 if type_bullet == 2 then
	  for i=0,nb_bullet do
	   if nb_bullet == 0 then
	    add(bullet,{
	      x=x,y=y,
	      type_bullet=type_bullet,
	      traj_x=traj_x,
	      traj_y=traj_y,
	      sprite=sprite
	    })
				else 
					add(bullet,{
					  x=x,y=y,
					  type_bullet=type_bullet,
					  traj_x=cos((angle-((1/ecartement)/2)+(i/nb_bullet)/ecartement))*speed,
					  traj_y=sin((angle-((1/ecartement)/2)+(i/nb_bullet)/ecartement))*speed,
					  sprite=sprite
					})
	   end
	  end
	 end
 end
end

-- -(i/2)+i/nb_bullet
function update_bullet()
 if (timer_bullet>0)timer_bullet = timer_bullet - 1
	for i in all(bullet) do
		if is_solid(i.x+(i.traj_x*1.5)+4,i.y+4+(i.traj_y*1.5)) then
		 del(bullet,i)
	 end
		i.x = i.x + i.traj_x
		i.y = i.y + i.traj_y
	end
end

function draw_bullet()
	for i in all(bullet) do
		spr(i.sprite,i.x,i.y)
	end
end

function rafale(nb,bullet)
 add(rafalels,{nb=nb,bullet=bullet})
end

function updaterafale()	
	for i in all(rafalels) do
  if (i.nb<1) del(rafalels,i)
  add(bullet,i.bullet)
  i.nb = i.nb - 1
	end
end
--]]
-->8
--mouse
function mouse_x_y()
	poke(0x5f2d, 1)
	mx=stat(32)+flr(camx)
	my=stat(33)
	local s = stat(34)
	lmb=bit.band(s,1) > 0
	rmb=bit.band(s,2) > 0
end




--[[function get_traj(x_satr,y_start,x_end,y_end)
	angle=atan2(x_end-x_satr-4, 
	 y_end-y_start-4)
	return {x=cos(angle),
	 y=sin(angle),angle=angle}
end]]

function check_flag(flag,x,y)
	return fget(mget(flr(x/8),flr(y/8)),flag)
end

-->8
--collision
function is_solid(x,y)
	if(x<0)then return true end
	return check_flag(0,x,y)
end

function touches_rect(x,y,x1,y1,x2,y2)
	return x1 <= x
	   and x2 >= x
	   and y1 <= y
	   and y2 >= y
end
--[[
function circ_coll(a,b)
	--https://www.lexaloffle.com/bbs/?tid=28999
	--b: bullet
	local dx=a.x+4 - b.x
	local dy=a.y+4 - b.y
	local d = max(dx,dy)
	dx = dx / d
	dy = dy / d
	local sr = (a.r+b.r)/d
	
	return dx*dx+dy*dy < sr*sr 
end
--]]

function rect_overlap(a1,a2,b1,b2)
	--[[return not (a1.x>b2.x
	         or a1.y>b2.y 
	         or a2.x<b1.x
	         or a2.y<b1.y)--]]
	
	return a1.x<b2.x
	   and a1.y<b2.y 
	   and a2.x>b1.x
	   and a2.y>b1.y--]]
end

function collision(x,y,w,h,flag)
	return 
	   is_solid(x,  y)
	or is_solid(x+w,y)
	or is_solid(x,  y+h)
	or is_solid(x+w,y+h) 
end

function collide(o,bounce1)
	local x,y = o.x,o.y
	local dx,dy = o.dx,o.dy
	local w,h = o.bw,o.bh
	local ox,oy = x+o.bx,y+o.by
	local bounce = bounce1
	
	--collisions
	local we,he = w-1, h-1
	local coll_x = collision( 
	ox+dx, oy,    we, he)
	local coll_y = collision(
	ox,    oy+dy, we, he)
	local coll_xy = collision(
	ox+dx, oy+dy, we, he)
	
	if coll_x then
		o.dx = o.dx * -bounce
	end
	
	if coll_y then
		o.dy = o.dy * -bounce
	end
	
	if coll_xy and 
	not coll_x and not coll_y then
		--prevent stuck in corners 
		o.dx = o.dx * -bounce
		o.dy = o.dy * -bounce
	end
end
-->8
--map 
test = 0
wagon_n = 0

function gen_train()
	--gen talbe of all wagon nums
	nums = {}
	for i=10,29 do
		add(nums,i)
	end
	
	--gen train
	train = {[0]=9}
	
	for i=0,tl do
		local w = i*wl
		for j=0,2 do
			
			local n = 10+flr(rnd(21))
			if(#nums>0)then n=nums[flr(rnd(#nums))+1]end
			train[w+j]=n
			del(nums,n)
			
		end
		train[w+3] = 8
	end
	
	train[0]=9
	
	for j=0,2 do
		train[tl*4+j]=30
	end
	train[(tl+1)*4 - 1]=31
end

function clone_room(a,b)
	local ax = (a%8)*16
	local ay = flr(a/8)*16
	room_all= {}
	for j = 0,15 do
		for i = 0,15 do
			local t=mget(ax+i,ay+j)
			mset(b*16+i,j,t)
		end
	end
end

function update_door()
	local wl = wl
	--unlock next wagon
	if #enemies <= 0 and 
	not enemiescleared then
		
		sfx(37)
		sfx(42)
		
		local x=(wl-1)*16
		local g=rnd_gun()
		
		make_drop(x*8+60,56,g.spr,"gun",
		copy(g))
		enemiescleared=true
		
		for i=1,5 do
			make_ptc(
			  x*8 + rrnd(8),
			  56  + rrnd(8),
			8+rnd(8),rnd{9,10})
		end
		
		if wagon_n < tl then
			mset(x,6,40)
			mset(x,7,39)
		else
			init_boss_room(x)
		end
		
		shake = shake + 5
		
	end 
end

function init_boss_room(x)
	mset(x,4,40)
	for i=5,9 do
		mset(x,i,39)
	end
	mset(x,10,12)
end

function begin_boss()
	local x = (wl-1)*16
	spawn_enemy(x*8+8*12,
	56,enemy.boss)
	
	mset(x,i,6)
	for i=5,9 do
		mset(x,i,6)
		burst_ptc(x*8,i*8,10)
	end
	mset(x,i,6)
end

function update_room()
	for i=0,3 do
		local w=wagon_n*wl + i
		
		--printh("train["..tostr(w).."]:"..tostr(train[w]))
		clone_room(train[w],i)
	end
	printh("---")
end

function draw_map()
	-- wall palette
--	if(pal_n>#trainpal) pal_n=1
--	pal(8,trainpal[pal_n][1])
--	pal(14,trainpal[pal_n][2])

 -- zep:
 pal_n=min(7,pal_n)
 pal(8,trainpal[pal_n*2-1])
 pal(14,trainpal[pal_n*2])
	
	draw_ghost_connector()
	map()
	draw_random()
	
	palt()
	pal()
end

function break_crate(x,y)
	spawn_loot(flr(x/8)*8,flr(y/8)*8)
	-- spawn_loot(x&~7,y&~7) -- zep
	
end



function swichtile(x,y)
 local t = mget(flr(x/8),flr(y/8))
 mset(flr(x/8),flr(y/8),t+1)
end

function parcourmap()

 local x1=0
 if(wagon_n==0)then x1=16 end
 	for x=x1,16*(wl-1) do
  	for y=2,12 do
   	if x>3 or azertyuiop.y-1000>y*8 or azertyuiop.y+1000<y*8 then
    	if mget(x,y)==109 then
   	  mset(x,y,39)
   	  if rnd(4)>3 then
   	  spawn_enemy(x * 8,y * 8,enemy.explosive_barrel)
   	  end
    	elseif fget(mget(x,y),2) and ceil(rnd(max(3,diffi-(wagon_n*1.65))))==1 then
      sapwnrndenemy(x,y)
    	end
   	end
  	end
  end
 end


function sapwnrndenemy(x,y)
	--spawn explosive_barrel 
      if ceil(rnd(25))==10 then
      spawn_enemy(x * 8,y * 8,enemy.explosive_barrel)
     --spawn juggernaut
     elseif ceil(rnd(32))>31-(wagon_n*0.7) and wagon_n>1 then
      spawn_enemy(x * 8,y * 8,enemy.juggernaut)
     
     --spawn warm
     elseif ceil(rnd(30))>28.5-(wagon_n*0.5) and wagon_n>0 then
      for i=0,ceil(rnd(wagon_n/2))+8 do
      spawn_enemy(x * 8,y * 8,enemy.warm)
      end
     
     --spawn tourelle 

      elseif ceil(rnd(30))>32.5-(wagon_n*1) and wagon_n>2 then

      spawn_enemy(x * 8,y * 8,enemy.tourelle)
     --spawn hedgehog 
     else 
      if ceil(rnd(23))>27-(wagon_n*2.5) then
       spawn_enemy(x * 8,y * 8,enemy.hedgehogbuff)
      else spawn_enemy(x * 8,y * 8,enemy.hedgehog)
      
     end
     end
end
-->8
--enemies
function make_enemy(x,y,spr,
spd,life,agro,chase,seerange,
gunt)
	return {
		x=x, y=y,
		angle=0,
		
		pangle=0,
		
		dx=0,dy=0,
		spd=spd,
		agro=agro,
		
		bx=1,by=1,
		bw=6,bh=6,
		
		hx=0,hy=0,
		hw=8,
		
		chase=chase,
		seerange=seerange,
		spr=spr,
		life=life,
		
		gun=gunt,
		cd=30,
		timer = 0,
		a=0,
	}
end

function init_enemies()
	enemy= {
	
	hedgehog=make_enemy(
--x,y,sprite,speed,life,shootrange,  
	 x,y,108   ,1    ,5   ,7.75   ,
--chase,seerange
	 false,1,
	 guns.gunslime),
	 
	hedgehogbuff=make_enemy(
--x,y,sprite,speed,life,shootrange,  
	 x,y,92   ,1    ,10   ,7.75   ,
--chase,seerange
	 false,1,
	 guns.gunslimebuff),
	 
	 
  juggernaut=make_enemy(
--x,y,sprite,speed,life,shootrange,  
	 x,y,94    ,1.5  ,30  ,3   ,  
--chase,seerange
  true,8, 
	 guns.shotgunmechant),
	 
	 warm=make_enemy(
--x,y,sprite,speed,life,shootrange,  
	 x,y,126    ,1  ,1  ,0   ,  
--chase,seerange
  true,6.5, 
	 guns.null),
	 
	 tourelle=make_enemy(
--x,y,sprite,speed,life,shootrange,  
	 x,y,125   ,0    ,15   ,6.5   ,
--chase,seerange
	 false,1,
	 guns.machinegunmechant),
	 
	 explosive_barrel=make_enemy(
--x,y,spr,speed,life,shootrange,  
	 x,y,109  ,0    ,0.1 ,0,
--chase,seerange
	 false,0,
	 guns.explosion),
	 
	boss=make_enemy(
--x,y,spr,speed,life,shootrange,  
	 x,y,1  ,3    ,300 ,32,
--chase,seerange
	 true,32,

	 guns.boss_360gun),
}

local b=enemy.boss
b.bw = 15
b.bh = 15
b.hw = 16
b.guns = {guns.boss_targetgun,
guns.boss_360gun,
guns.boss_enemygun}
b.phase = 0
b.phasetimer = 0
b.pause=0

end

function spawn_enemy(x,y,name)
	local a=copy(name)
	a.x = x
	a.y = y
	a.gun = copy(a.gun)
	local r = rnd(60)
	if(a.spr==1)then r = 0 end
	if (a.spr ~= 125)then a.gun.cooldown = a.gun.cooldown + r end
	
 if (a.spr == 126)then a.spd = 0.8+rnd(0.4)end
 if a.x<175 then
  a.gun.timer = a.gun.timer + 90
  a.timer = 90
 end
 
	add(enemies,a)
end

function update_enemy(e)
	for i in all(enemies) do
		if loaded(i) then
			mouvrnd = true
			
			i.gun.timer = max(i.gun.timer-1--/#enemies
			,0)
			
			if i.gun.timer<=0 and 
			(canshoot(i,azertyuiop) or i.spr==1)then
				
				i.gun:fire(i.x+4,i.y+4,i.a)
			end
			if mouvrnd then
				changedirection(i)
			end
			collide(i,0.1)
			
			i.pangle=atan2(azertyuiop.x-i.x,azertyuiop.y-i.y)
			if not (i.spr== 109) then
				i.flip=isleft(i.pangle)
			end
			
			if(i.spr==1)then  update_boss(i)end
			
			i.x = i.x + i.dx
			i.y = i.y + i.dy
		end
	end
end

function draw_enemy(e)
	local w = 1
	if(e.spr==1)then w=2 end
	
	local x=flr(e.x)+
	cos(e.pangle)*6*w
	local y=flr(e.y)+
	sin(e.pangle)*3*w
	
	spr(e.gun.spr,x,y,1,1, e.flip)
	
	spr(e.spr,e.x,e.y,w,w, e.flip)
	
	--boss health bar
	if e.spr==1 then
		rectfill(camx+1,120,
		camx+126,126,4)
		local l=126*(e.life/300)
		rectfill(camx+2,121,camx+2+l,
		125,9)
		
		local s="🐱"..ceil(e.life).."/".."300"
		print(s, camx+3,121,7)
	end
	
	--print(e.life, e.x,e.y-8,7)
	--circ(e.x+4,e.y+4,e.r,12)
	--print(e.gun.timer,e.x,e.y)
	--print(abs(e.dy)+abs(e.dx),e.x,e.y+6)
end

function update_boss(i)
	i.phasetimer = i.phasetimer - 1
	i.pause = i.pause - 1
	
	if i.phasetimer<0 then
		i.phasetimer=600+rnd(600)
		i.phase = i.phase + 1
		i.pause = 200
	end
	if(i.phase>3)then i.phase=1 end
	
	i.gun=i.guns[i.phase]
	if(i.pause>0)then  i.gun = guns.null end
end

function changedirection(i)
	i.timer = i.timer - 1
	if i.timer < 1 then
	 i.angle = i.angle + rrnd(0.25)
	 i.timer=i.cd
	 i.dx=cos(i.angle)/8*i.spd 
	 i.dy=sin(i.angle)/8*i.spd
	end
end

function canshoot(e,pl)
	local angle = atan2(pl.x-e.x,
	pl.y-e.y)
	e.a=angle
	local x = cos(angle)
	local y = sin(angle) 
	local dist = dist(e,pl)
	
	if (abs(dist)<e.agro and abs(pl.x-e.x)<128) or e==azertyuiop then
		return cansee(e,angle,x,y,dist)
	elseif abs(dist)<e.seerange and abs(dist)>e.agro and e.chase and cansee(e,angle,x,y,dist) then
  o= e.dx+e.dy
   e.dx=x*(e.spd*2)/max(dist,4)
   e.dy=y*(e.spd*2)/max(dist,4)
   
    mouvrnd = false
   
  
 end	
end

local function sqr(x)
	return x*x
end

function dist(e,p)
	-- return sqrt(abs(p.y-e.y)^2 + abs(p.x-e.x)^2)/8
	return sqrt(sqr(abs(p.y-e.y)) + sqr(abs(p.x-e.x)))/8
end
 
function cansee(e,angle,x,y,dist)	 
 for i =1,dist do
	add(checker,{x=e.x+x*i*8,y=e.y+y*i*8})  
	 if is_solid(checker[#checker].x+4,checker[#checker].y+4) then
	 	delchecker()
	 	if (e~=azertyuiop) then e.gun.timer = e.gun.cooldown/2 end
	 return false 
	 end
	end
	delchecker() 
	return true 
end


function delchecker()
	checker = {}
end

function loaded(i)
	return abs(camx+64-i.x)<71--71
end
-->8
--particles & bg
function init_ptc()
	particles={}
	grass = {}
	for i=0,20 do 
	add(grass,{x=flr(rnd(16))*8, y=flr(rnd(16))*8, spr=56})
	end
	for i=0,5 do 
	add(grass,{x=flr(rnd(16))*8, y=rnd{0,112}, spr=56})
	end
	for i=0,3 do
	for v=4,14 do
	add(grass,{x=32*i,y=v*8,spr=24})
	end
	end
	weelflip = true
	weelframe = 5
	weelcount = weelframe
end

function make_ptc(x,y,r,col,fric,dx,dy,txt)
	fric=fric or rnd(.1)+.85
	dx=dx or 0
	dy=dy or 0
	add(particles, {
		x=x,  y=y,
		dx=dx,dy=dy,
		fric=fric,
		
		txt=txt,
		
		r=r, col=col,
		destroy=false,
	})
end

function update_ptc(ptc)
	ptc.x = ptc.x + ptc.dx
	ptc.y = ptc.y + ptc.dy
	
	ptc.dx = ptc.dx * ptc.fric
	ptc.dy = ptc.dy * ptc.fric
	
	ptc.r = ptc.r * ptc.fric
	
	if(ptc.r<=1)then ptc.destroy=true end
end

function draw_ptc(ptc)
	--kinda bodgey but whatever
	if ptc.txt==nil then
		circfill(ptc.x,ptc.y,ptc.r,ptc.col)
	else
		print(ptc.txt,ptc.x,ptc.y,ptc.col)
	end
end

function burst_ptc(x,y,col)
	for i=1,5 do
		make_ptc(
		   x+rrnd(8),
		   y+rrnd(8),
		   rnd(5)+5,col,
		   0.9+rnd(0.07))
	end 
end

function grasstile()
	for i in all(grass)do
	 i.x = i.x
		i.x = i.x - 2.5
		if (i.x<-8)then i.x = 128 end
	end
end

function drawgrass()
	for elt in all(grass)do
		spr(elt.spr,camx+elt.x,elt.y)
	end
end

function draw_wheel()
 weelcount = weelcount - 1
 if (weelcount<1)then  weelflip = not weelflip weelcount=weelframe end
 for n=0,5 do
	for i=0,2 do
		spr(42,8+n*64+i*16,14*8, 2,2,weelflip)--, flip_x ,flip_y)
	end
	end
end

----


-->8
--menus
function init_menus()
	menus = {}
	menus.main = make_main_menu()
	menus.death = make_death_menu(false)
	menus.bossdeath = make_boss_death()
	menus.win = make_death_menu(true)
end

--[[
function draw_bar(t,x,y,w,w2,c,c2)
	rectfill(x,y,
	x+w+2,y+5,c2)
	local l=w*w2
	rectfill(x+1,y+1,
	x+1+l,y+5,c)
	
	print(t, x+1,y+1,7)
end--]]

function make_boss_death()
	local m={
	timer=400,
	
	update=function(m)
		for e in all(enemies)do del(e,enemies) end
		music(-1,0)
		if(m.timer==400)then sfx(45)end --sfx(46)
		
		m.timer = m.timer - 3
		
		if m.timer<0 then
			menu = "game"
			win=true
			shake = shake + 40
			sfx(48)
			
			for i=1,18 do
				make_ptc(camx+rnd(128),
				rnd(128),50+rnd(20),
				rnd{8,9,10},.95)
				
--(x,y,r,col,fric,dx,dy,txt)
			end
		end
		
		mx,my=-10,-10
	end,
	
	draw=function(m)
		
		local x,y = boss_pos[1]+8,boss_pos[2]+8
		local flp = boss_pos[3]
		local t = m.timer
		circfill(x,y,t    ,8)
		circfill(x,y,t*.75,9)
		circfill(x,y,t*.5 ,10)
		circfill(x,y,t*.25,7)
		spr(1,x-8,y-8,2,2,flp)
	end
	}
	return m
end
------

function make_main_menu()
	--this code could be better
	local m = {
	  update=update_main_menu,
	  draw=draw_main_menu,
	  
	  sel=0,
	  done=false,
	  ui_oy=0,
	  ui_dy=0,
	  
	  has_active=false,
	}
	m.buttons={}
	
	local names=split"pigeon,duck,sparrow,parrot,toucan,flamingo,eagle,seagull,ostrich,penguin,jay,chicken"
	local x=4
	local y=105
	for i=1,12 do
		add(m.buttons,{
		  n=i,
		  spr=i+79,
		  bird=i+111,
		  
		  x=i*10-6,
		  y=105,
		  w=9,
		  h=17,
		  col=1,
		  sh=2,
		  
		  name=names[i],
		  active=false,
		})
	end
	
	-------
	function make_btn(args)
		n,sp,bird,x,y,w,h,name=unpack(split(args))
		return {
		  n=n,
		  spr=sp,
		  bird=bird,
		  
		  x=x,y=y,
		  w=w,h=h,
		  
		  oy=0,
		  col=1,
		  sh=1,
		  
		  name=name,
		  active=false,
		}
	end
	-------
	m.buttons[0]=make_btn("0,124,39,114,91,9,9,random")
		
	m.buttons[13]=make_btn("13,111,39,2,2,9,9,random")
	
	return m
end

function update_main_menu(m)
	local selection=1000
	
	if not m.done then
		--update buttons
		for k=0,#m.buttons do
			local i = m.buttons[k]
			
			--on hover
			if touches_rect(mx,my,i.x,i.y,
			i.x+i.w-1, i.y+i.h-1) then
				i.col = 7
				i.oy = 2
				
				if(not i.active) then  sfx(43) end
				m.has_active=true
				m.sel = i.n
				i.active=true
				
				-- on click
				if lmb then 
					selection = i.n
				end
			
			else
				
				i.active = false
				i.col = 1
				i.oy = 0
				
			end--if
		end--for
		
		--buttons
		for n=0,1 do
		if(btnp()>0) then sfx(43) end
		if(btnp(BTN_LEFT,n)) then m.sel = m.sel - 1 end
		if(btnp(BTN_RIGHT,n)) then m.sel = m.sel + 1 end
		if(btnp(BTN_UP,n)) then m.sel=(m.sel==0)and 13 or 0 end
		if(btnp(BTN_DOWN,n)) then m.sel=1 end
		end
		if(btn(BTN_X)or btn(BTN_O)) then selection=m.sel end
		
		m.sel = m.sel % 14
		local b=m.buttons[m.sel]
		b.active = true
		m.has_active=true
		b.oy,b.col = 2,7
		
		
		-- run selection
		if selection<=12 then
			m.done = true
		elseif selection==13 then
			hardmodetimer = hardmodetimer + 1
		else
			hardmodetimer=0
		end
	else
		--animation 
		m.ui_dy = m.ui_dy + .1
		m.ui_oy = m.ui_oy + m.ui_dy
		
		if m.ui_dy > 5 then
			birdchoice = m.sel
		 menu = "game"
			begin_game()
			return
		end 
	end
end

function draw_main_menu(m)
	local oy = m.ui_oy
	
	palt(0,false)
	
	draw_logo(44,5-oy)
	
	--player selection
	rectfill(112,89+oy,125,110+oy,12)
	rectfill(2,103+oy,125,124+oy,1)
	for k=0,#m.buttons do
		i = m.buttons[k]
		
		oy = abs(oy)
		if(k == 13)then oy = -oy end
		
		rectfill(i.x, 
		i.y-i.oy + oy, 
		i.x+i.w, 
		i.y+i.h-i.oy + oy, 
		i.col)
		spr(i.spr, 
		i.x+1, 
		i.y+1-i.oy + oy,
		1,i.sh)
		
		if i.n==13 and i.active then
			oprint("a game by:",2,13, 14)
			oprint([[yOLWOOCLE
gOUSPOURD
nOTGOYOME
sIMON t.]],2,13)
			oprint([[code,art
code
code
music]],45,13, 13)
		end
	end
	oy=abs(oy)
	
	-- buttons
	local sel=m.buttons[m.sel]
	rectfill(
	2,93+oy,
	2+#sel.name*8, 102+oy,1)
	wide(sel.name,4,95+oy,7)
	palt()
	
	-- encaged bird
	palt(1,true)
	spr(sel.bird,6*8,7*8)
	spr(32,6*8,7*8)
	palt()
end

function draw_logo(x,y)
	--"birds"
	oxxl("birds",x,y,10)
	oxxl("guns",x+4,y+15, 6)
	
	--"with"
	oprint("with",x+11,y+10)
	
	oprint("with",x+11,y+9)
end

function oxxl(t,x,y,col)
	--credit to freds72
	for ix=-2,2 do
		for iy=-2,4 do
			if abs(ix)==2 
			or abs(iy)>=2 then
				-- print("\^p"..t,x+ix,y+iy,1) -- FIXME
				print("p"..t,x+ix,y+iy,1)
			end
		end
	end
	
	col=col or 7 
	for ix=-1,1 do
		for iy=-1,1 do
			-- print("\^p"..t, -- FIXME
			print("p"..t,
			x+ix,y+iy,col)
		end
	end
end

function wide(t,x,y,col,pre)
	--credit to yolwoocle uwu
	t1= "                ! #$%&'()  ,-./[12345[7[9:;<=>?([[c[efc[ij[l[[([([st[[[&yz[\\]'_`[[c[efc[ij[l[[([([st[[[&yz{|}~"
	t2="                !\"=$  '()*+,-./0123]5678]:;<=>?@abcdefghijklmnopqrstuvwx]z[\\]^_`abcdefghijklmnopqrstuvwx]z{|} "
	n1,n2="",""
	pre=pre or ""
	
	for i=1,#t do
		local char = sub(t,i,i)
		local c=ord(char)-16
		n1 = n1 .. sub(t1,c,c).." "
		n2 = n2 .. sub(t2,c,c).." "
	end
	
	if(col~=nil)then color(col) end
	print(pre..n1,x,y)
	print(pre..n2,x+1,y)
end


-->8
--drops
function make_drop(x,y,spr,type,q)
	add(drops,{
	 x=x, y=y,
	 bx=8,dy=8,
	 
	 spr=spr,
	 type=type,
	 
	 q=q,
	 touched=false,
	 cooldown=0,
	 
	 destroy=false,
	})
end

function update_drops()
	for d in all(drops) do
		d.cooldown=max(0,d.cooldown-1)
		
		local touches = touches_rect(
		azertyuiop.x+4,azertyuiop.y+4,
		d.x,d.y,d.x+8,d.y+8)
		
		if(not touches)then d.touched=false end
		if touches then
			
			local col=7
			local txt=""
			local do_ptc = false
			
			if d.type=="ammo" then
				d.destroy = true
				local q = flr(d.q*azertyuiop.gun.maxammo)
				azertyuiop.gun.ammo = azertyuiop.gun.ammo + q
				
				do_ptc=true
				col=9
				txt="+"..q.." ammo"
				
				sfx(38)
				
			elseif d.type=="health"then
				d.destroy = true
				azertyuiop.life = azertyuiop.life + d.q
				
				do_ptc=true
				col=8
				txt="+"..d.q.." health"
				
				sfx(38)
				
			elseif d.type=="gun" 
			and not d.touched
			and d.cooldown<=0 then
				d.touched = true
				d.cooldown = 60
				
				do_ptc=true
				col=6
				txt=d.q.name
				
				azertyuiop.gunls[azertyuiop.gunn],d.q=d.q,azertyuiop.gunls[azertyuiop.gunn]
				update_gun(azertyuiop)
				d.spr = d.q.spr
				
				sfx(36)
			end
			
			if do_ptc then
				for i=1,5 do
					make_ptc(
						d.x+rrnd(8),
						d.y+rrnd(8),
						rnd(5)+5,col,
						0.9+rnd(0.07))
				end 
			end
			
			make_ptc(
				d.x+4-(#txt*2),
				d.y+4,
				rnd(5)+5,7,
				.98,0,-0.3,txt
			)
		end
		
		if(d.destroy)then del(drops,d) end
	end
end

function draw_drops()
	for d in all(drops)do
		spr(d.spr,d.x,d.y)
	end
end

function spawn_loot(x,y)
	local r = rnd(1)
	
	if r < .015 then
		local g = rnd_gun()
		make_drop(x,y,g.spr,"gun",
		copy(g))
	elseif r < .045 then
		make_drop(x,y,79,"ammo",1/4)
		
	elseif r < .075 and degaplus == 0 then
		make_drop(x,y,78,"health",2)
	
	elseif r < .017 and degaplus == 1 then
		make_drop(x,y,78,"health",1)
	end
end
-->8
--death menu
function make_death_menu(iswin)
	local m = {
	  update=update_death_menu,
	  draw=draw_death_menu,
	  
	  circt=1,
	  timer=0,
	  showtext=false,
	  
	  iswin=iswin,
	  nstats=0,
	}
	
	local t,t2="retry","change bird"
	if(iswin)then t="play again","title screen" end
	
	m.buttons = {}
	m.buttons[1]={
		n=1,
		t=t,
		x=0,y=0, oy=0,
		active=false
	}
	m.buttons[2]={
		n=2,
		t=t2,
		x=0,y=0, oy=0,
		active=false
	}
	
	return m
end

function update_death_menu(m)
	m.circt=min(m.circt*1.05,600)
	
	--circle timer
	if m.circt>=600 then
		if(m.timer==0)then  music(23) end
		
		if(m.timer==220)then  music(24) end
		if m.timer%60==59 
		
		--"ploop" sfx on every stat
		and m.nstats<3 then
			sfx(41) 
			m.nstats = m.nstats + 1
		end
		
		m.showtext=true
		m.timer = m.timer + 1
	end
	
	-- buttons
	local o = 0
	if keyboard and m.timer>1 then
		if(btn(BTN_X))then o=1 end
		if(btn(BTN_O))then o=2 end
	end
	
	for i=1,#m.buttons do
		local b = m.buttons[i]
		local t=m.timer / 100
		
		local ox = #b.t*2
		b.x = camx + 64 - ox 
		+ cos(t+i/10)*1.5
		b.y = 1/t + 80 + i*15 
		+ sin(t+i/10)*1.5
		
		if touches_rect(mx,my,
		b.x-4,b.y-4,
		b.x+#b.t*4+3, b.y+9) then
			
			if(not b.active)then sfx(43) end
			b.active = true
			b.oy = 3
			if lmb then
				o = b.n
			end
			
			m.sel = i
			
		else
			b.active = false
			
		end
	end
	
	if(o==1)then run(tostr(birdchoice)) end
	if(o==2)then run("-") end
end

function draw_death_menu(m)
	--circles animation
	palt(0,false)
	palt(1,true)
	local col,c2,c3,c4=0,1,2,9
	local txtcol = 7
	if m.iswin then
		col,c2,c3,c4=15,9,8,2
		txtcol = 10
		if(t()%2<1)then txtcol = 9 end
	end
	
	local x,y = azertyuiop.x+4,azertyuiop.y+4
	local c = m.circt
	circfill(x,y,c    ,c4)
	circfill(x,y,c*.75,c3)
	circfill(x,y,c*.5 ,c2)
	--spr(p.spr,p.x,p.y)
	circfill(x,y,c*.25,col)

	palt()
	
	--text & buttons
	local t=m.timer/100
	local txt=m.iswin and 
	   "congrats!" or "game over"
	
	oxxl(txt,
	     camx+30+cos(t)*3,
	     1/t +20+sin(t)*3, txtcol)
	     
	for b in all(m.buttons) do
		local a = ""
		if keyboard then
			a = "🅾️"
			if(b.n == 1)then  a = "❎" end
		end
		
		if b.active then
			oprint(a..b.t,b.x,b.y-b.oy,1,7)
		else
			oprint(a..b.t,b.x,b.y,14,1)
		end
	end
	
	--stats
	local i=0
	for k,v in pairs(stats)do
		if i<m.nstats then
			text_y = i*8+1/t+40+sin(t+.3)*3
			oprint(k,camx+35,text_y)
			oprint(v,camx+80,text_y, 13)
		end
		i = i + 1
	end
	
	for i=0,6 do
		local txt="▒"
		if(i<=wagon_n)then txt="█" end
		if not m.iswin then
			oprint(txt, camx+37+i*8,
			1/t+70+sin(t)*3, 7)
		end
	end
	
	--hard mode prompt
	if m.iswin then
		local txt="hold the 'i' button\non the title screen\nto unlock hard mode\n"
		if(degaplus~=0)then txt="bro what !!!\nthis mode was not \nsupposed to be possible !" end
		oprint(txt
		,camx+25,1/t+70+sin(t)*2, 13)
	end
end

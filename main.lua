local beer_x, beer_y = 200, 500
local beer_speed = 200
local beer_walking = false
local beer_direction = 0
local frame_time = 0

function love.load()
	love.window.setFullscreen(true, "desktop")
   bos = love.graphics.newImage("bos.jpeg")
   beer = love.graphics.newImage("beer.png")
   sw, sh = beer:getDimensions()

   beer1 = love.graphics.newQuad(189*2*0, 0, 189*2, 896, sw, sh)
   beer2 = love.graphics.newQuad(189*2*1, 0, 189*2, 896, sw, sh)
   beer3 = love.graphics.newQuad(189*2*2, 0, 189*2, 896, sw, sh)
   beer4 = love.graphics.newQuad(189*2*3, 0, 189*2, 896, sw, sh)
   beer5 = love.graphics.newQuad(189*2*4, 0, 189*2, 896, sw, sh)

   current_frame = beer5

   love.graphics.setNewFont(12)
--   love.graphics.setColor(0,0,0)
   love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
	local x, y = beer_x, beer_y
    if love.keyboard.isDown("left") then
        beer_x = beer_x - beer_speed * dt
    end
    if love.keyboard.isDown("right") then
        beer_x = beer_x + beer_speed * dt
    end
    dx = beer_x - x
	local walking = beer_x ~= x

	if dx > 0 then
		beer_direction = 1
	elseif dx < 0 then
		beer_direction = -1
	end

	if beer_x < -400 then
		beer_x = 2000
	end
	if beer_x > 2000 then
		beer_x = -400
	end

    if beer_walking ~= walking then
   		beer_walking = walking
   		if not beer_walking then
   			current_frame = beer5
   		else
   			current_frame = beer1
   			frame_time = 0
   		end
    end

    frame_time = frame_time + dt
    if frame_time > 0.25 then
        if current_frame == beer1 then
            current_frame = beer2
        elseif current_frame == beer2 then
           current_frame = beer1
        end 
        frame_time = frame_time - 0.25
    end
end

function love.draw()
    love.graphics.draw(bos, 0, 0, 0, 0.5, 0.5)
--   love.graphics.print("Der bunte Teddy", 400, 300)
    if beer_direction >= 0 then
	   love.graphics.draw(beer, current_frame, beer_x, beer_y, 0, 0.6, 0.6)
	else
	   love.graphics.draw(beer, current_frame, beer_x + 189*2*0.6, beer_y, 0, -0.6, 0.6)
	end
end



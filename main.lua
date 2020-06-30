local beer_x, beer_y = 200, 500
local beer_speed = 200
local beer_walking = false
local beer_direction = 0
local frame_time = 0
local walking_time = 0
local speed_y = 0
local beer_height = 0

function love.load()
    love.window.setFullscreen(true, "desktop")

    -- Load sounds
    sounds = {}
    for _, name in ipairs {
        "aieguddlguddl",
        "guddlguddl",
        "ha",
        "pffwhup",
    } do
        sounds[name] = love.audio.newSource(name .. ".ogg", "stream")
    end

    -- Load images
    bos = love.graphics.newImage("bos.jpeg")
    beer = love.graphics.newImage("beer.png")

    -- Set up frames for beer
    local sw, sh = beer:getDimensions()
    beer1 = love.graphics.newQuad(189*2*0, 0, 189*2, 896, sw, sh)
    beer2 = love.graphics.newQuad(189*2*1, 0, 189*2, 896, sw, sh)
    beer3 = love.graphics.newQuad(189*2*2, 0, 189*2, 896, sw, sh)
    beer4 = love.graphics.newQuad(189*2*3, 0, 189*2, 896, sw, sh)
    beer5 = love.graphics.newQuad(189*2*4, 0, 189*2, 896, sw, sh)
    current_frame = beer5

    love.graphics.setNewFont(30)
    love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
    local prev_x, prev_y = beer_x, beer_y

    -- Move by left/right keys
    if love.keyboard.isDown("left") then
        beer_x = beer_x - beer_speed * dt
    end
    if love.keyboard.isDown("right") then
        beer_x = beer_x + beer_speed * dt
    end

    -- Adjust direction of the sprite
    local dx = beer_x - prev_x
    if dx > 0 then
        beer_direction = 1
    elseif dx < 0 then
        beer_direction = -1
    end

    -- Loop from one side to the other side
    if beer_x < -400 then
        beer_x = 2000
    end
    if beer_x > 2000 then
        beer_x = -400
    end

    -- Gravity
    local prev_beer_height = beer_height
    beer_height = math.max(0, beer_height + speed_y * dt)
    if beer_height > 0 then
        speed_y = speed_y - 9.8 * dt
    end
    if prev_beer_height ~= 0 and beer_height == 0 then
        frame_time = 0
    end

    -- Update walking animation
    local walking = beer_x ~= prev_x
    if beer_walking ~= walking then
        beer_walking = walking
        if not beer_walking then
            current_frame = beer5
        else
            current_frame = beer1
            frame_time = 0
            love.audio.play(sounds.guddlguddl)
        end
        walking_time = 0
    elseif beer_walking then
        walking_time = walking_time + dt
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

    -- Play funny sound while walking
    if walking_time > 4 then
        if beer_height == 0 then
            love.audio.play(sounds.aieguddlguddl)
        end
        walking_time = math.random(-3, 0)
    end
end

function love.draw()
    love.graphics.draw(bos, 0, -100, 0, 0.55, 0.55)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Der bunte Teddy", 20, 20)
    love.graphics.setColor(1,1,1)

    -- Scale is used to flip the sprite, but then its position needs to be compensated
    local frame = beer_height > 0 and beer4 or current_frame
    if not beer_walking and beer_height == 0 and love.keyboard.isDown("up") then
        frame = beer3
    end
    local y = beer_y + beer_height * -200
    if beer_direction >= 0 then
       love.graphics.draw(beer, frame, beer_x, y, 0, 0.6, 0.6)
    else
       love.graphics.draw(beer, frame, beer_x + 189*2*0.6, y, 0, -0.6, 0.6)
    end
end

function love.keypressed(key)
    if key == 'space' then
        if beer_height == 0 then
            love.audio.stop(sounds.aieguddlguddl, sounds.guddlguddl)
            love.audio.play(sounds.ha)
            speed_y = 3
        end
    elseif key == 'up' and not beer_walking and beer_height == 0 then
        love.audio.play(sounds.pffwhup)
    end
end

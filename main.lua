local FULL_SCREEN = false

local player_direction = 0
local player_height = 0
local player_speed_y = 0
local player_walking = false
local player_walking_speed = 200
local player_walking_time = 0
local player_x, player_y = 200, 500

local frame_time = 0

local function quadsForGrid(image, width, height)
    local sw, sh = image:getDimensions()
    local quads = {}

    for y=0,sh/height-1 do
        for x=0,sw/width-1 do
            table.insert(quads, love.graphics.newQuad(width*x, height*y, width, height, sw, sh))
        end
    end
    return quads
end

local function setupBeer()
    local beerImage = love.graphics.newImage("beer.png")
    local beer = quadsForGrid(beerImage, 378, 896)
    return {
        image = beerImage,
        frames = {
            staan = beer[5],
            lopen1 = beer[1],
            lopen2 = beer[2],
            omhoog = beer[3],
            spring = beer[4]
        },
        width = 378,
        scale = 0.6,
    }
end

local function setupSemire()
    local semireImage = love.graphics.newImage("semire.png")
    local semire = quadsForGrid(semireImage, 292, 389)
    return {
        image = semireImage,
        frames = {
            staan = semire[3],
            lopen1 = semire[1],
            lopen2 = semire[2],
            -- lopen1 = semire[4],
            -- lopen2 = semire[5],
            omhoog = semire[10],
            spring = semire[14]
        },
        width = 292,
        scale = 1.0,
    }
end

function love.load()
    love.window.setTitle("Der bunte Teddy")
    love.window.setMode(1280, 720, {
        fullscreen = FULL_SCREEN,
        resizable = true,
    })

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
    sprite = setupBeer()
    -- sprite = setupSemire()

    -- Start width "staan" frame
    current_frame = sprite.frames.staan

    love.graphics.setNewFont(30)
    love.graphics.setBackgroundColor(255,255,255)
end

function love.update(dt)
    local prev_x, prev_y = player_x, player_y

    -- Move by left/right keys
    if love.keyboard.isDown("left") then
        player_x = player_x - player_walking_speed * dt
    end
    if love.keyboard.isDown("right") then
        player_x = player_x + player_walking_speed * dt
    end

    -- Adjust direction of the sprite
    local dx = player_x - prev_x
    if dx > 0 then
        player_direction = 1
    elseif dx < 0 then
        player_direction = -1
    end

    -- Loop from one side to the other side
    if player_x < -400 then
        player_x = 2000
    end
    if player_x > 2000 then
        player_x = -400
    end

    -- Gravity
    local prev_player_height = player_height
    player_height = math.max(0, player_height + player_speed_y * dt)
    if player_height > 0 then
        player_speed_y = player_speed_y - 9.8 * dt
    end
    if prev_player_height ~= 0 and player_height == 0 then
        frame_time = 0
    end

    -- Update walking animation
    local walking = player_x ~= prev_x
    if player_walking ~= walking then
        player_walking = walking
        if not player_walking then
            current_frame = sprite.frames.staan
        else
            current_frame = sprite.frames.lopen1
            frame_time = 0
            love.audio.play(sounds.guddlguddl)
        end
        player_walking_time = 0
    elseif player_walking then
        player_walking_time = player_walking_time + dt
    end

    frame_time = frame_time + dt
    if frame_time > 0.25 then
        if current_frame == sprite.frames.lopen1 then
            current_frame = sprite.frames.lopen2
        elseif current_frame == sprite.frames.lopen2 then
           current_frame = sprite.frames.lopen1
        end
        frame_time = frame_time - 0.25
    end

    -- Play funny sound while walking
    if player_walking_time > 4 then
        if player_height == 0 then
            love.audio.play(sounds.aieguddlguddl)
        end
        player_walking_time = math.random(-3, 0)
    end
end

function love.draw()
    local scale = love.graphics.getWidth() / 1920
    love.graphics.scale(scale, scale)

    love.graphics.draw(bos, 0, -100, 0, 0.55, 0.55)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Der bunte Teddy", 20, 20)
    love.graphics.setColor(1,1,1)

    -- Scale is used to flip the sprite, but then its position needs to be compensated
    local frame = player_height > 0 and sprite.frames.spring or current_frame
    if not player_walking and player_height == 0 and love.keyboard.isDown("up") then
        frame = sprite.frames.omhoog
    end
    local y = player_y + player_height * -200
    if player_direction >= 0 then
       love.graphics.draw(sprite.image, frame, player_x, y, 0, sprite.scale, sprite.scale)
    else
       love.graphics.draw(sprite.image, frame, player_x + sprite.width*sprite.scale, y, 0, -sprite.scale, sprite.scale)
    end
end

function love.keypressed(key)
    if key == 'space' then
        if player_height == 0 then
            love.audio.stop(sounds.aieguddlguddl, sounds.guddlguddl)
            love.audio.play(sounds.ha)
            player_speed_y = 3
        end
    elseif key == 'up' and not player_walking and player_height == 0 then
        love.audio.play(sounds.pffwhup)
    elseif key == 'escape' then
        love.event.quit()
    end
end

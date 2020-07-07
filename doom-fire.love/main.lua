function love.load()
    fire_width = 800
    fire_height = 125
    palette_size = 45
    pixels = {}
    test = bit.bor(1, 2)
    for x = 0, fire_width - 1 do
        for y = 0, fire_height - 1 do
            pixels[(y * fire_width) + x] = 1
        end
    end

    for x = 1, fire_width - 1 do
        pixels[(fire_height - 1) * fire_width + x] = palette_size
    end

    colors = {
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {0 / 255, 0 / 255, 0 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {234 / 255, 51 / 255, 82 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {242 / 255, 166 / 255, 59 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 239 / 255, 87 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255},
        {253 / 255, 241 / 255, 233 / 255}
    }
end

function spread(src)
    local p = pixels[src]
    if (p == 0) then
        pixels[src - fire_width] = 0
    else
        local rand_idx = bit.band(love.math.random(0, 3), 3)
        local dst = src - rand_idx + 1
        pixels[dst - fire_width] = p - bit.band(rand_idx, 1)
    end
end

function love.update(dt)
    for x = 0, fire_width - 1 do
        for y = 1, fire_height - 1 do
            spread(y * fire_width + x)
        end
    end
end

function love.draw()
    local offset = 600 - fire_height
    for x = 0, fire_width - 1 do
        for y = 0, fire_height - 1 do
            local pixel = pixels[y * fire_width + x]

            local color = colors[pixel]
            if color then
                love.graphics.setColor(color[1], color[2], color[3])
            else
                love.graphics.setColor(0, 0, 0)
            end
            love.graphics.rectangle("fill", x, y + offset, 1, 1)
        end
    end
end

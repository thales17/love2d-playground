function love.load()
    image = love.graphics.newImage("sentinel.png")
end

function love.update(dt)
end

function love.draw()
    -- love.graphics.print("Hello, World", 400, 300)
    love.graphics.draw(image, love.math.random(0, 800), love.math.random(0, 600))
end

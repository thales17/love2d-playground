function love.load()
    width = 800
    half_width = width / 2
    height = 300
    grid_size = 20
    angle_step = math.pi / 64
    fov = math.pi / 4
    grid_cols = 20
    grid_rows = 15

    player = {
        x = half_width / 2,
        y = height / 2,
        size = 5,
        color = {
            r = 255 / 255,
            g = 0 / 255,
            b = 0 / 255
        },
        speed = 4
    }
    angle = 0
    rays = {}
    ray_count = half_width

    grid_data = {
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1},
        {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1},
        {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1},
        {1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1},
        {1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1},
        {1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
        {1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    }

    cast_rays()
end

function clamp(n, min, max)
    if n < min then
        return min
    end
    if n > max then
        return max
    end

    return n
end

function handle_input()
    local move_dir = {x = 0, y = 0, left = false, right = false}
    if love.keyboard.isDown("w") then
        move_dir.y = -1
    end

    if love.keyboard.isDown("s") then
        move_dir.y = 1
    end

    if love.keyboard.isDown("d") then
        move_dir.x = 1
    end

    if love.keyboard.isDown("a") then
        move_dir.x = -1
    end

    if love.keyboard.isDown("h") then
        move_dir.left = true
    elseif love.keyboard.isDown("l") then
        move_dir.right = true
    end

    return move_dir
end

function grid_cell_for_point(x, y)
    x = math.floor(x / grid_size)
    y = math.floor(y / grid_size)

    x = clamp(x, 0, grid_cols - 1)
    y = clamp(y, 0, grid_rows - 1)

    return {x = x, y = y}
end

function grid_distance(p1, p2)
    local x = p2.x - p1.x
    local y = p2.y - p1.y

    return math.floor(math.sqrt((x * x) + (y * y)))
end

function angle_for_ray(i)
    local start_angle = angle - (fov / 2)
    local end_angle = angle + (fov / 2)
    local ray_angle_step = (end_angle - start_angle) / ray_count

    return start_angle + (ray_angle_step * i)
end

function cast_rays()
    print("cast rays")
    local cast_step = 0.0001

    for i = 1, ray_count do
        local local_step = 0.0
        local max = {x = 0, y = 0}
        local local_angle = angle_for_ray(i - 1)
        max.x = player.x + math.cos(local_angle) * width
        max.y = player.y + math.sin(local_angle) * width
        rays[i] = {x = player.x, y = player.y}
        local cell = grid_cell_for_point(rays[i].x, rays[i].y)
        while grid_data[cell.y + 1][cell.x + 1] == 0 do
            rays[i].x = player.x + ((max.x - player.x) * local_step)
            rays[i].y = player.y + ((max.y - player.y) * local_step)
            local_step = local_step + cast_step
            cell = grid_cell_for_point(rays[i].x, rays[i].y)
        end
    end
end

function love.update(dt)
    local move_dir = handle_input()
    if move_dir.x == 0 and move_dir.y == 0 and not move_dir.left and not move_dir.right then
        return
    end

    local current_cell = grid_cell_for_point(player.x, player.y)
    local next_point = {x = player.x + move_dir.x, y = player.y + move_dir.y}
    local next_cell = grid_cell_for_point(next_point.x, next_point.y)
    local should_move = true

    if next_cell.x ~= current_cell.x or next_cell.y ~= current_cell.y then
        if grid_data[next_cell.y + 1][next_cell.x + 1] > 0 then
            should_move = false
        end
    end

    if should_move then
        player.x = next_point.x
        player.y = next_point.y
    end

    if move_dir.left then
        angle = angle - angle_step
    elseif move_dir.right then
        angle = angle + angle_step
    end

    if should_move or move_dir.left or move_dir.right then
        cast_rays()
    end
end

function draw_grid()
    love.graphics.setColor(0 / 255, 10 / 255, 128 / 255)
    for r = 1, grid_rows do
        for c = 1, grid_cols do
            if grid_data[r][c] > 0 then
                love.graphics.rectangle("fill", (c - 1) * grid_size, (r - 1) * grid_size, grid_size, grid_size)
            end
        end
    end

    local gray = 32 / 255
    love.graphics.setColor(gray, gray, gray)

    local x = grid_size
    while x <= half_width do
        love.graphics.rectangle("fill", x, 0, 1, height)
        x = x + grid_size
    end
    local y = grid_size
    while y < height do
        love.graphics.rectangle("fill", 0, y, half_width, 1)
        y = y + grid_size
    end
end

function draw_player()
    love.graphics.setColor(player.color.r, player.color.g, player.color.b)
    love.graphics.rectangle(
        "fill",
        player.x - (player.size / 2),
        player.y - (player.size / 2),
        player.size,
        player.size
    )
end

function draw_rays()
    local gray = 75 / 255
    love.graphics.setColor(gray, gray, gray)
    for i = 1, ray_count do
        love.graphics.line(player.x, player.y, rays[i].x, rays[i].y)
    end
end

function draw_horizon()
    love.graphics.setColor(222 / 255, 184 / 255, 135 / 255)
    love.graphics.rectangle("fill", half_width, height / 2, half_width, height / 2)
end

function draw_viewport()
    local radius = 50
    local left_angle = angle_for_ray(0)
    local center_angle = angle
    local right_angle = angle_for_ray(ray_count - 1)
    local left_x = player.x + math.cos(left_angle) * radius
    local left_y = player.y + math.sin(left_angle) * radius
    local center_x = player.x + math.cos(center_angle) * radius
    local center_y = player.y + math.sin(center_angle) * radius
    local right_x = player.x + math.cos(right_angle) * radius
    local right_y = player.y + math.sin(right_angle) * radius

    love.graphics.setColor(255 / 255, 0 / 255, 0 / 255)
    love.graphics.line(player.x, player.y, left_x, left_y)
    love.graphics.line(player.x, player.y, right_x, right_y)
    love.graphics.setColor(0 / 255, 255 / 255, 0 / 255)
    love.graphics.line(player.x, player.y, center_x, center_y)
end

function draw_vertical_center_line(x, h)
    local h1 = (height - h) / 2
    love.graphics.rectangle("fill", x, h1, 1, h)
end

function draw_walls()
    local max_height = height * 70
    local max_blue = 255
    for i = 1, ray_count do
        local delta_x = rays[i].x - player.x
        local delta_y = rays[i].y - player.y
        local beta = angle
        local p = math.floor(delta_x * math.cos(beta) + delta_y * math.sin(beta))

        local distance = math.max(p, 1)
        local h = max_height / distance
        local b = max_blue - distance
        if distance > max_height then
            h = 0
        end
        if distance > max_blue then
            b = 0
        end
        love.graphics.setColor(0 / 255, 0 / 255, b / 255)
        draw_vertical_center_line((i - 1) + half_width, h)
    end
end

function love.draw()
    draw_grid()
    draw_player()
    draw_rays()
    draw_viewport()
    draw_horizon()
    draw_walls()
end

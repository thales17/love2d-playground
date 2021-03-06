function love.load()
    width = 1024
    height = 768
    col_width = 2

    fov = math.pi / 2

    grid_cols = 20
    grid_rows = 15
    grid_size = math.floor(width / grid_cols)

    player = {
        x = width / 2,
        y = height / 2,
        size = 5,
        color = {
            r = 255 / 255,
            g = 0 / 255,
            b = 0 / 255
        },
        speed = 1
    }
    angle = 0.01
    rays = {}
    show_map = true
    ray_count = (width / col_width)
    angle_step = fov / ray_count

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
    -- cast_rays()
    my_cast_rays()
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
    local move = {
        move_left = false,
        move_right = false,
        move_up = false,
        move_down = false,
        turn_left = false,
        turn_right = false,
        no_move = true
    }

    if love.keyboard.isDown("w") then
        move.no_move = false
        move.move_up = true
    elseif love.keyboard.isDown("s") then
        move.no_move = false
        move.move_down = true
    end

    if love.keyboard.isDown("d") then
        move.no_move = false
        move.move_right = true
    elseif love.keyboard.isDown("a") then
        move.no_move = false
        move.move_left = true
    end

    if love.keyboard.isDown("h") then
        move.no_move = false
        move.turn_left = true
    elseif love.keyboard.isDown("l") then
        move.no_move = false
        move.turn_right = true
    end

    if love.keyboard.isDown("tab") then
        show_map = true
    else
        show_map = false
    end

    return move
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
    return start_angle + (angle_step * i)
end

function cast_rays()
    local cast_step = 0.0001
    for i = 1, ray_count do
        local local_step = 0.0
        local max = {x = 0, y = 0}
        local local_angle = angle_for_ray(i - 1)
        max.x = math.cos(local_angle) * width
        max.y = math.sin(local_angle) * width
        rays[i] = {x = player.x, y = player.y}
        local cell = grid_cell_for_point(rays[i].x, rays[i].y)
        while grid_data[cell.y + 1][cell.x + 1] == 0 do
            rays[i].x = player.x + (max.x * local_step)
            rays[i].y = player.y + (max.y * local_step)
            local_step = local_step + cast_step
            cell = grid_cell_for_point(rays[i].x, rays[i].y)
        end
    end
end

function upper_right_cast_vals(theta)
    local cell = grid_cell_for_point(player.x, player.y)
    local x = cell.x * grid_size
    local y = cell.y * grid_size
    local dx = math.floor(player.x - x)
    local dy = math.floor(player.y - y)
    local tan_theta = math.tan(theta)
    local x_step = (-1 * (grid_size) / tan_theta)
    local y_step = ((grid_size) * tan_theta)
    local quad_x = 1
    local quad_y = -1
    local tile_step_x = quad_x * grid_size
    local tile_step_y = quad_y * grid_size
    local x_intercept = x + dx + (-1 * dy / tan_theta)
    local y_intercept = y + dy + ((grid_size - dx) * tan_theta)
    return {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        theta = theta,
        tan_theta = tan_theta,
        quad_x = quad_x,
        quad_y = quad_y,
        tile_step_x = tile_step_x,
        tile_step_y = tile_step_y,
        x_step = x_step,
        y_step = y_step,
        x_intercept = x_intercept,
        y_intercept = y_intercept,
        h = {x = x_intercept, y = y},
        v = {x = x + tile_step_x, y = y_intercept}
    }
end

function bottom_right_cast_vals(theta)
    local cell = grid_cell_for_point(player.x, player.y)
    local x = cell.x * grid_size
    local y = cell.y * grid_size
    local dx = math.floor(player.x - x)
    local dy = math.floor(player.y - y)
    local tan_theta = math.tan(theta)
    local x_step = ((grid_size) / tan_theta)
    local y_step = ((grid_size) * tan_theta)
    local quad_x = 1
    local quad_y = 1
    local tile_step_x = quad_x * grid_size
    local tile_step_y = quad_y * grid_size
    local x_intercept = x + dx + ((grid_size - dy) / tan_theta)
    local y_intercept = y + dy + ((grid_size - dx) * tan_theta)
    return {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        theta = theta,
        tan_theta = tan_theta,
        x_step = x_step,
        y_step = y_step,
        quad_x = quad_x,
        quad_y = quad_y,
        tile_step_x = tile_step_x,
        tile_step_y = tile_step_y,
        x_intercept = x_intercept,
        y_intercept = y_intercept,
        h = {x = x_intercept, y = y + tile_step_y},
        v = {x = x + tile_step_x, y = y_intercept}
    }
end

function upper_left_cast_vals(theta)
    local cell = grid_cell_for_point(player.x, player.y)
    local x = cell.x * grid_size
    local y = cell.y * grid_size
    local dx = math.floor(player.x - x)
    local dy = math.floor(player.y - y)
    local tan_theta = math.tan(theta)
    local x_step = (-1 * grid_size / tan_theta)
    local y_step = (-1 * (grid_size) * tan_theta)
    local quad_x = -1
    local quad_y = -1
    local tile_step_x = quad_x * grid_size
    local tile_step_y = quad_y * grid_size
    local x_intercept = x + dx + (-1 * dy / tan_theta)
    local y_intercept = y + dy + (-1 * dx * tan_theta)
    return {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        theta = theta,
        tan_theta = tan_theta,
        quad_x = quad_x,
        quad_y = quad_y,
        tile_step_x = tile_step_x,
        tile_step_y = tile_step_y,
        x_step = x_step,
        y_step = y_step,
        x_intercept = x_intercept,
        y_intercept = y_intercept,
        h = {x = x_intercept, y = y},
        v = {x = x, y = y_intercept}
    }
end

function bottom_left_cast_vals(theta)
    local cell = grid_cell_for_point(player.x, player.y)
    local x = cell.x * grid_size
    local y = cell.y * grid_size
    local dx = math.floor(player.x - x)
    local dy = math.floor(player.y - y)
    local tan_theta = math.tan(theta)
    local x_step = (grid_size) / tan_theta
    local y_step = (-1 * (grid_size) * tan_theta)
    local quad_x = -1
    local quad_y = 1
    local tile_step_x = quad_x * grid_size
    local tile_step_y = quad_y * grid_size
    local x_intercept = x + dx + ((grid_size - dy) / tan_theta)
    local y_intercept = y + dy + (-1 * dx * tan_theta)
    return {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        theta = theta,
        tan_theta = tan_theta,
        quad_x = quad_x,
        quad_y = quad_y,
        tile_step_x = tile_step_x,
        tile_step_y = tile_step_y,
        x_step = x_step,
        y_step = y_step,
        x_intercept = x_intercept,
        y_intercept = y_intercept,
        h = {x = x_intercept, y = y + tile_step_y},
        v = {x = x, y = y_intercept}
    }
end

function cast_vals_for_angle(theta)
    local radius = 10
    local x = math.cos(theta) * radius
    local y = math.sin(theta) * radius
    if x > 0 and y < 0 then
        return upper_right_cast_vals(theta)
    end

    if x < 0 and y < 0 then
        return upper_left_cast_vals(theta)
    end

    if x < 0 and y > 0 then
        return bottom_left_cast_vals(theta)
    end
    if x > 0 and y > 0 then
        return bottom_right_cast_vals(theta)
    end
end

function backtrack_ray(x, y, angle)
    local dist = grid_distance(player, {x = x, y = y})

    local max_backtracks = grid_size
    local backtracks = 0
    local cell = grid_cell_for_point(x, y)
    while grid_data[cell.y + 1][cell.x + 1] ~= 0 and backtracks < max_backtracks do
        dist = dist - 1
        x = math.cos(angle) * dist + player.x
        y = math.sin(angle) * dist + player.y
        backtracks = backtracks + 1
        cell = grid_cell_for_point(x, y)
    end

    return {x = x, y = y}
end

function my_cast_rays()
    for i = 1, ray_count do
        local local_angle = angle_for_ray(i - 1)
        local cast_vals = cast_vals_for_angle(local_angle)
        if cast_vals == nil then
            return
        end

        local i_h = {x = cast_vals.h.x, y = cast_vals.h.y}
        local cell = grid_cell_for_point(i_h.x + cast_vals.quad_x, i_h.y + cast_vals.quad_y)
        while grid_data[cell.y + 1][cell.x + 1] == 0 do
            i_h.x = i_h.x + cast_vals.x_step
            i_h.y = i_h.y + cast_vals.tile_step_y
            cell = grid_cell_for_point(i_h.x + cast_vals.quad_x, i_h.y + cast_vals.quad_y)
        end

        local i_v = {x = cast_vals.v.x, y = cast_vals.v.y}
        cell = grid_cell_for_point(i_v.x + cast_vals.quad_x, i_v.y + cast_vals.quad_y)
        while grid_data[cell.y + 1][cell.x + 1] == 0 do
            i_v.x = i_v.x + cast_vals.tile_step_x
            i_v.y = i_v.y + cast_vals.y_step
            cell = grid_cell_for_point(i_v.x + cast_vals.quad_x, i_v.y + cast_vals.quad_y)
        end

        local h_dist = grid_distance(player, i_h)
        local v_dist = grid_distance(player, i_v)

        if h_dist <= v_dist then
            -- rays[i] = backtrack_ray(i_h.x, i_h.y, local_angle)
            rays[i] = {x = math.floor(i_h.x), y = math.floor(i_h.y)}
        else
            -- rays[i] = backtrack_ray(i_v.x, i_v.y, local_angle)
            rays[i] = {x = math.floor(i_v.x), y = math.floor(i_v.y)}
        end
    end
end

function move_cell(move)
    local m_x = 0
    local m_y = 0

    if move.move_up then
        local x = player.speed * math.cos(angle)
        local y = player.speed * math.sin(angle)
        m_x = m_x + x
        m_y = m_y + y
    elseif move.move_down then
        local x = player.speed * math.cos(angle)
        local y = player.speed * math.sin(angle)
        m_x = m_x - x
        m_y = m_y - y
    end

    if move.move_left then
        local x = player.speed * math.cos(angle - math.pi / 2)
        local y = player.speed * math.sin(angle - math.pi / 2)
        m_x = m_x + x
        m_y = m_y + y
    elseif move.move_right then
        local x = player.speed * math.cos(angle + math.pi / 2)
        local y = player.speed * math.sin(angle + math.pi / 2)
        m_x = m_x + x
        m_y = m_y + y
    end

    return {x = player.x + m_x, y = player.y + m_y}
end

function love.update(dt)
    local move = handle_input()
    if move.no_move then
        return
    end

    local current_cell = grid_cell_for_point(player.x, player.y)
    local next_point = move_cell(move)
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

    if move.turn_left then
        angle = angle - (math.pi / 180)
    elseif move.turn_right then
        angle = angle + (math.pi / 180)
    end

    if should_move or move.turn_left or move.turn_right then
        -- cast_rays()
        my_cast_rays()
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
    while x <= width do
        love.graphics.rectangle("fill", x, 0, 1, height)
        x = x + grid_size
    end
    local y = grid_size
    while y < height do
        love.graphics.rectangle("fill", 0, y, width, 1)
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
        if rays[i] then
            love.graphics.line(player.x, player.y, rays[i].x, rays[i].y)
        end
    end
end

function draw_horizon()
    love.graphics.setColor(222 / 255, 184 / 255, 135 / 255)
    love.graphics.rectangle("fill", 0, height / 2, width, height / 2)
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
    love.graphics.rectangle("fill", x * col_width, h1, col_width, h)
end

function draw_walls()
    local max_height = height * 50
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
        draw_vertical_center_line((i - 1), h)
    end
end

function draw_debug()
    love.graphics.setColor(255 / 255, 255 / 255, 255 / 255)
    love.graphics.line(player.x, player.y, debug_info.ray_angle.x, debug_info.ray_angle.y)
    love.graphics.setColor(255 / 255, 0 / 255, 0 / 255)
    love.graphics.line(player.x, player.y, debug_info.ray.x, debug_info.ray.y)

    love.graphics.setColor(0 / 255, 255 / 255, 0 / 255)
    for i = 1, #debug_info.horizontal_intercepts do
        love.graphics.rectangle(
            "fill",
            debug_info.horizontal_intercepts[i].x - 2.5,
            debug_info.horizontal_intercepts[i].y - 2.5,
            5,
            5
        )
    end

    love.graphics.setColor(255 / 255, 0 / 255, 255 / 255)
    for i = 1, #debug_info.vertical_intercepts do
        love.graphics.rectangle(
            "fill",
            debug_info.vertical_intercepts[i].x - 2.5,
            debug_info.vertical_intercepts[i].y - 2.5,
            5,
            5
        )
    end
end

function love.draw()
    if show_map then
        draw_grid()
        draw_player()
        draw_rays()
        draw_viewport()
    else
        draw_horizon()
        draw_walls()
    end
end

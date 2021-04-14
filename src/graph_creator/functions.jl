function hat_fun(center, dims, height)
    xp = center[1]
    yp = center[2]

    function hat(x, y)
        along_x = (x - xp) / (dims[1] * 2)
        along_y = (y - yp) / (dims[2] * 2)
        r=(along_x^2+along_y^2)^0.5
        f(r) = r < 0.25 ? cos(2*π*r) * height : 0.0
        f(r)
    end

    hat
end

function block_fun(start, dims, height)
    function block(x, y)
        condition  = ((x >= start[1]) & (x <= start[1] + dims[1]))
        condition &= ((y >= start[2]) & (y <= start[2] + dims[2]))
        condition ? height : 0.0
    end
    block
end

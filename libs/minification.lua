local minification = {}
minification.__index = minification

minification.languages = {
    [1] = "unknown",
    [2] = "lua",
}

local detect_language = function(input)
    local language = minification.languages[1]

    if string.match(input, "function%s*%a*%(.-%)%s*end") then
        language = minification.languages[2] -- Lua
    end

    --[[
    elseif string.match(input, "function%s*%(.-%)%s*{") then
        language = minification.languages[3] -- JavaScript
    elseif string.match(input, "<%a+>%s*</%a+>") then
        language = minification.languages[4] -- HTML
    elseif string.match(input, "{%s*%a+:%s*%a+;%s*}") then
        language = minification.languages[5] -- CSS
    end
    --]]

    return language
end

-- Language Specific Functions
local minify_lua = function(input)
    local output = ""
    local is_string = false
    local string_delimiter = nil
    local last_char = nil
    local is_comment = false

    for i = 1, #input do
        local c = input:sub(i, i)

        -- Check if we're inside of a string
        if not is_string and not is_comment and (c == '"' or c == "'") then
            is_string = true
            string_delimiter = c
        elseif is_string and c == string_delimiter then
            is_string = false
            string_delimiter = nil
        end

        -- Check if we're inside of a comment
        if not is_string and not is_comment and c == '-' and last_char == '-' then
            is_comment = true
            output = output:sub(1, -2) -- remove the comment characters
        elseif is_comment and c == '\n' then
            is_comment = false
            c = '' -- Remove newlines at the end of comments
        end

        -- Remove whitespace when not in a comment or string
        if not is_string and not is_comment then
            if c == ' ' and last_char == ' ' then -- Skip double spaces
            elseif c == '\n' then
                -- Replace newlines with a space to avoid breaking the code
                local next_char = i < #input and input:sub(i + 1, i + 1) or nil
                if last_char ~= ' ' and next_char ~= ' ' then
                    output = output .. ' '
                end
            elseif c ~= '\t' then -- Skip tabs
                output = output .. c
            end
        elseif not is_comment then
            output = output .. c
        end

        last_char = c
    end

    return output
end

-- Main Functions
minification.run = function(input)
    local language = detect_language(input)

    if (language == minification.languages[2]) then -- Lua
        input = minify_lua(input)
    end

    return input
end

return minification
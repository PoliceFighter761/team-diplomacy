return function(text, TextSize)
    return ((TextSize or 0) + 5) * string.len(text)
end
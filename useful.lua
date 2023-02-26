local function urlEncode (url)
    return string.gsub(url, "[^%w]", function (char)
        return string.format("%%%X", string.byte(char))
    end)
end

return {
    urlEncode = urlEncode
}
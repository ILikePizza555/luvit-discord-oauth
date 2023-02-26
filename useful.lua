local alphaNumericCharset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(alphaNumericCharset, string.char(c)) end
    for c = 65, 90  do table.insert(alphaNumericCharset, string.char(c)) end
    for c = 97, 122 do table.insert(alphaNumericCharset, string.char(c)) end
end

local function generateRandomString(charset, length)
    local stringBuf = {}
    for i=0,length do
        table.insert(stringBuf, charset[math.random(0, #charset)])
    end
    return table.concat(stringBuf)
end

return {
    alphaNumericCharset = alphaNumericCharset,
    generateRandomString = generateRandomString
}
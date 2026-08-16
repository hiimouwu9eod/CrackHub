local Scripts = {
    [75366259315586] = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/bulidurbase.lua", -- Build Ur Base
    [142823291] = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/mm2.lua" -- Murder Mystery 2
}

local placeId = game.PlaceId
local url = Scripts[placeId]

if url then
    loadstring(game:HttpGet(url, true))()
else
    warn("[Loader] No script for PlaceId:", placeId)
end

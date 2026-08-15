local LoaderFile = {
    CallBackLoader = {
        Ids = {
            75366259315586, -- Build Ur Base
            142823291       -- Murder Mystery 2
        }
    }
}

local Scripts = {
    [75366259315586] = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/bulidurbase.lua",
    [142823291] = "https://raw.githubusercontent.com/hiimouwu9eod/CrackHub/refs/heads/main/mm2.lua"
}

local placeId = game.PlaceId
local url = Scripts[placeId]

if url then
    loadstring(game:HttpGet(url, true))()
end

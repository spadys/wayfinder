--[[
-- Wayfinder by Spades. spades@outlook.cz
-- 
-- MIT License
-- 
-- Copyright (c) [year] [fullname]
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
]]--

local hbd = LibStub("HereBeDragons-2.0")

local function usage()
    print("Wayfinder Usage:")
    print("/way <x>, <y> - Adds a Map Pin at x,y")
end

local function parseSlash(slash)
    -- Parse slash commands
    slash = slash:gsub("(%d)[%.,] (%d)", "%1 %2")
    
    local tokens = {}
    for token in slash:gmatch("%S+") do table.insert(tokens, token) end

    return tokens
end

local function sanitizeCoordinates(x_str, y_str)
    -- Fix commas in waypoints
    x_str = x_str:gsub(',', '.')
    y_str = y_str:gsub(',', '.')
    
    -- Change to numbers
    local x = tonumber(x_str)
    local y = tonumber(y_str)
    
    if x == nil or y == nil then
        return nil, nil
    end
    
    x = math.max(0, math.min(100, x))
    y = math.max(0, math.min(100, y))
    
    return x, y
end

local function removeMapPin()
    -- Clear the Map Pin
    C_Map.ClearUserWaypoint()
end

local function createMapPin(x, y)
    -- Get Current Map ID
    local _, _, mapID = hbd:GetPlayerZonePosition()

    -- Create Map Pin if possible
    if C_Map.CanSetUserWaypointOnMap(mapID) then
        -- Create UiMapPoint
        local point = UiMapPoint.CreateFromCoordinates(mapID, x/100, y/100);
        -- Set the Map Pin on map
        C_Map.SetUserWaypoint(point)
        -- Set the Map Pin as Super Waypoint (HUD Waypoint)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
    else
        -- UI Error "You can't do that right now"
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, RED_FONT_COLOR:GetRGBA());
    end
end

SLASH_WAYFINDER_WAY1 = '/way'
function SlashCmdList.WAYFINDER_WAY(msg, editbox)
    -- No argument
    if msg == nil then
        usage()
        return
    end
    
    tokens = parseSlash(msg)
    
    if tokens[1] == "reset" then
        removeMapPin()
    else
        x, y = sanitizeCoordinates(tokens[1], tokens[2])

        -- Check coordinates
        if x == nil or y == nil then
            usage()
            return
        end
        
        createMapPin(x, y)
    end
end



-- config vars

-- blocks to throw away. match phrase
junk = {"cobble", "gravel", "stone", "asurine", "granite", "slate", "sand", "tuff"}
-- blocks that can be burned as fuel. match phrase
burnable = {"coal", "_plank", "_log", "lava"}

-- Your discord id. enable developer mode and right click your avatar. paste the code here as a string
discordID = "yourdiscordid here"

-- Discord Webhook url. right click a channel. go to integrations and create a new webhook. Paste the url here
webhook = "yourwebhookhere"

-- How often to garbage collect
garbageCollectInterval = 64


-- end config vars
full = false
args = {...}
xx = tonumber(args[1])
yy = tonumber(args[2])
zz = tonumber(args[3])
quarryUp = false
totalBlocks = xx * yy * zz
xx = xx - 1
if yy < 0 then
    yy = math.abs(yy)
    quarryUp = true
end
minedBlocks = 0
moves = 0
discordMention = "<@" .. discordID .. ">"

function notify(message)
    print(message)
    local body = "{\"content\":\"" .. message .. "\"" .. "}"
    local headers = {}
    headers["Content-Type"] = "application/json"
    http.post(webhook, body, headers)
end

function isBurnable(item)
    if item == nil then
        return
    end
    for k, v in pairs(burnable) do
        if string.match(item["name"], v) then
            return true
        end
    end
end

function isJunk(item)
    if item == nil then
        return false
    end
    for k, v in pairs(junk) do
        if string.match(item["name"], v) then
            return true
        end
    end
    return false
end

function refuel()
    for i = 1,16 do
        turtle.select(i)
        if isBurnable(turtle.getItemDetail()) then
            turtle.refuel()
        end
    end
end

function garbageCollect()
    for i = 1,16 do
        turtle.select(i)
        item = turtle.getItemDetail()
        if isJunk(item) then
            turtle.drop()
        elseif isBurnable(item) then
            turtle.refuel()
        end
    end
end

function move(dir)
    moves = moves + 1
    if moves % garbageCollectInterval == 0 then
        notify(minedBlocks .. "/" .. totalBlocks .. " mined")
        garbageCollect()
    end
    if dir == "forward" then
        return turtle.forward()
    end
    if dir == "down" then
        return turtle.down()
    end
    if dir == "up" then
        return turtle.up()
    end
end

function dig(direction)
    minedBlocks = minedBlocks + 1
    if direction == nil then
        return turtle.dig()
    end
    if direction == "down" then
        return turtle.digDown()
    end
    if direction == "up" then
        return turtle.digUp()
    end
end

function mineColumn(size)
    for x = 1,size do
        dig()
        if not move("forward") then
            if turtle.getFuelLevel() == 0 then
                notify("turtle ran out of fuel!")
                error("turtle ran out of fuel")
                break
            end
            notify("turtle stuck!")
            error("turtle stuck")
        end
    end
end

function mineRectangle(sizeX, sizeY)
    for z = 1,sizeX do
        mineColumn(sizeY)
        if z == sizeX then
            break
        end
        if z % 2 == 0 then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
        dig()
        move("forward")
        if z % 2 == 0 then
            turtle.turnLeft()
        else
            turtle.turnRight()
        end
    end
end

function printDone()
    local message = discordMention .. " finished mining job"
    if not args[4] == nil then
        message = message .. " " .. args[4]
    end
    message = message .. " total blocks: " .. tostring(totalBlocks)
    notify(message)
end

function main()
    for y = 1,yy do
        mineRectangle(zz, xx)
        print(y)
        turtle.turnRight()
        if y == yy then
            break
        end
        if quarryUp then
            dig("up")
            move("up")
        else
            dig("down")
            move("down")
        end
    end
    printDone()
end

main()




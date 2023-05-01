local composer = require( "composer" )
local physics = require("physics")
local widget = require("widget")

local scene = composer.newScene()

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"

local totalScore = composer.setVariable("totalScore",0)
local totalTime = composer.setVariable("totalTime",0)
local currentLevel = composer.setVariable("currentLevel",1)

local background
local backButton

local buttonClicked
local levelTheme
local teleportSound
local coinSound
local doorSound

local bgGroup
local playerGroup
local objectsGroup
local platformGroup

local score = 0
local time = 1
local lives = 3
local coinsCollected = 0

local levelText
local scoreText
local timeText
local livesText

local floor
local key
local doorEnd

local player
local playerX = 0
local playerXSpeed = 2.5
local keyPressed = ""

local timeTimer

local platformSheet
local platformSprites =
{
    frames =
    {
        { -- 1
            x = 0,
            y = 0,
            width = 32,
            height = 32
        },
        { -- 2
            x = 0,
            y = 32,
            width = 64,
            height = 32
        },
        { -- 3
            x = 0,
            y = 64,
            width = 96,
            height = 32
        },
        { -- 4
            x = 0,
            y = 96,
            width = 128,
            height = 32
        },
        { -- 5
            x = 0,
            y = 128,
            width = 160,
            height = 32
        },
        { -- 6
            x = 0,
            y = 160,
            width = 192,
            height = 32
        },
        { -- 7
            x = 0,
            y = 192,
            width = 224,
            height = 32
        },
        { -- 8
            x = 0,
            y = 224,
            width = 256,
            height = 32
        },
    }
}

local coinSequence =
{
    {
        name = "blink",
        frames = {1,2,3,4,5,6},
        time = 1000,
        loopCount = 0,
        loopDirection = "forward"
    }
}

local coinOptions =
{
    width = 33,
    height = 32,
    numFrames = 6
}

local doorSequence =
{
    {
        name = "closed",
        frames = {1}
    },
    {
        name = "open",
        frames = {2}
    }
}

local doorOptions =
{
    width = 64,
    height = 81,
    numFrames = 2
}

local teleportSequence =
{
    {
        name = "closed",
        frames = {1}
    },
    {
        name = "active",
        frames = {2}
    }
}

local teleportOptions =
{
    width = 64,
    height = 96,
    numFrames = 2
}

local coinSheet = graphics.newImageSheet("Images/coin.png",coinOptions)
local doorSheet = graphics.newImageSheet("Images/door.png",doorOptions)
local teleportSheet = graphics.newImageSheet("Images/teleport.png",teleportOptions)

local coins = {}
local platforms = {}
local teleports = {}
local teleportCoordinates =
{{display.contentCenterX - 50,display.contentCenterY - 65},
{display.contentCenterX + 265,display.contentCenterY+15},
{display.contentCenterX - 325,display.contentCenterY + 75},
{display.contentCenterX - 65,display.contentCenterY -325},
{display.contentCenterX + 175,display.contentCenterY -125},
{display.contentCenterX + 275,display.contentCenterY-275}}

local currentTP

local function gotoMenu(event)
	if "ended" == event.phase then
        audio.stop(1)
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("mainmenu")
	end
end

local function levelWin()
    score = score + (500 * lives)
    local curTotalScore = composer.getVariable("totalScore")
    local curTotalTime = composer.getVariable("totalTime")
    composer.setVariable("totalScore",score + curTotalScore)
    composer.setVariable("totalTime",time + curTotalTime)
	composer.gotoScene("gameWin")
end

local function activatePhysics()
    physics.addBody(player,"dynamic",{bounce=0})
    physics.addBody(floor,"static",{bounce=0})
    physics.addBody(key,"static",{bounce=0})
    physics.addBody(doorEnd,"static",{bounce=0})

    for x = 1,#teleports do
        physics.addBody(teleports[x],"static",{bounce=0})
    end

    for x = 1,#platforms do
        physics.addBody(platforms[x],"static",{bounce=0})
    end

    for x = 1,#coins do
        physics.addBody(coins[x],"static",{bounce=0})
    end
end

local function movePlayer()
    player.rotation = 0

    if keyPressed == "a" or keyPressed == "left" then
        playerX = playerX - playerXSpeed
    elseif keyPressed == "d" or keyPressed == "right" then
        playerX = playerX + playerXSpeed
    end

    if playerX <= 13 then
        playerX = 13
    elseif playerX >= 1012 then
        playerX = 1012
    end

    player.x = playerX
end

local function onPressed(event)
    if event.phase == "down" then
        local key = event.keyName
        if (key == "a" or key == "left") or (key == "d" or key == "right") then
            keyPressed = key
        end
    else
        keyPressed = ""
    end
end

local function tpPlayer()
    audio.play(teleportSound,{channel=2})

    playerX = teleportCoordinates[currentTP][1]
    player.y = teleportCoordinates[currentTP][2]

    playerXSpeed = 2.5
end

local function updateLevel()
    movePlayer()
    player.rotation = 0
    floor.rotation = 0
end

local function updateTime()
    time = time + 1
    timeText.text = "Time: " .. tostring(time)
end

local function addScore()
    score = score + 100
    scoreText.text = "Score: " .. tostring(score)
end

local function updateDoor()
    audio.play(doorSound,{channel=4})
    doorEnd:setSequence("open")
end

local function onCollision(event)
    local obj1 = event.object1
    local obj2 = event.object2

    if event.phase == "began" then
        if obj1.myName == "key" or obj2.myName == "key" then
            display.remove(key)
            timer.performWithDelay(100,updateDoor,1)
        end

        if obj1.myName == "door" or obj2.myName == "door" then
            if doorEnd.sequence == "open" then
                levelWin()
            end
        end

        if obj1.myName == "teleport" or obj2.myName == "teleport" then
            -- Stop the player
            playerXSpeed = 0

            for i = #teleports, 1, -1 do
				if teleports[i] == obj1 or teleports[i] == obj2 then
                    currentTP = i
                    timer.performWithDelay(100,tpPlayer,1)
                    break
				end
			end
        end

        if obj1.myName == "coin" or obj2.myName == "coin" then
            for i = #coins, 1, -1 do
				if coins[i] == obj1 or coins[i] == obj2 then

                    coinsCollected = coinsCollected + 1
                    if coinsCollected == 5 then
                        score = score + 500
                    end

                    audio.play(coinSound,{channel=3})
                    display.remove(coins[i])
                    addScore()
                    break
				end
			end
        end

    elseif event.phase == "ended" then
        if obj1.myName == "key" or obj2.myName == "key" then
            physics.removeBody(key)
        end

        if obj1.myName == "coin" or obj2.myName == "coin" then
            for i = #coins, 1, -1 do
				if coins[i] == obj1 or coins[i] == obj2 then
                    physics.removeBody(coins[i])
                    break
				end
			end
        end
    end
end

-- create()
function scene:create( event )

    local sceneGroup = self.view
    buttonClicked = audio.loadSound("Audio/buttonClicked.mp3")
    teleportSound = audio.loadSound("Audio/teleport.mp3")
    coinSound = audio.loadSound("Audio/coin.mp3")
    doorSound = audio.loadSound("Audio/door.mp3")
    levelTheme = audio.loadStream("Audio/level1Theme.mp3")

    bgGroup = display.newGroup()
    platformGroup = display.newGroup()
    objectsGroup = display.newGroup()
    playerGroup = display.newGroup()

    background = display.newImageRect(bgGroup,"Images/bg.png",1024,768)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    levelText = display.newText("Level: 1",display.contentCenterX-440,display.contentCenterY-350,font,35)
    levelText:setFillColor(0,0,0)
    sceneGroup:insert(levelText)

    livesText = display.newText("Lives: " .. tostring(lives),display.contentCenterX-440,display.contentCenterY-300,font,35)
    livesText:setFillColor(0,0,0)
    sceneGroup:insert(livesText)

    scoreText = display.newText("Score: " .. tostring(score),display.contentCenterX-275,display.contentCenterY-350,font,35)
    scoreText:setFillColor(0,0,0)
    sceneGroup:insert(scoreText)

    timeText = display.newText("Time: " .. tostring(time),display.contentCenterX-275,display.contentCenterY-300,font,35)
    timeText:setFillColor(0,0,0)
    sceneGroup:insert(timeText)

    backButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY + 325,
			id = "backButton",
			label = "Back",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoMenu,
			defaultFile = buttonNormalSprite,
			overFile = buttonOverSprite,
		}
	)
    sceneGroup:insert(backButton)

    floor = display.newRect(platformGroup,display.contentCenterX,display.contentCenterY+300,display.contentWidth,display.contentCenterY*0.32)
    floor:setFillColor(0,0,0,0)
    floor.myName = "platform"
    sceneGroup:insert(floor)

    platformSheet = graphics.newImageSheet("Images/platforms.png",platformSprites)

    platforms[1] = display.newImage(platformSheet,5,128,512); platforms[1].myName = "platform"

    platforms[2] = display.newImage(platformSheet,6,768,480); platforms[2].myName = "platform"

    platforms[3] = display.newImage(platformSheet,8,448,384); platforms[3].myName = "platform"

    platforms[4] = display.newImage(platformSheet,8,768,288); platforms[4].myName = "platform"

    platforms[5] = display.newImage(platformSheet,6,192,224); platforms[5].myName = "platform"

    platforms[6] = display.newImage(platformSheet,5,448,96); platforms[6].myName = "platform"

    platforms[7] = display.newImage(platformSheet,6,864,128); platforms[7].myName = "platform"

    teleports[1] = display.newSprite(teleportSheet,teleportSequence)
    teleports[1].x = display.contentCenterX-200
    teleports[1].y = display.contentCenterY+200
    teleports[1].myName = "teleport"
    teleports[1]:setSequence("active")

    teleports[2] = display.newSprite(teleportSheet,teleportSequence)
    teleports[2].x = display.contentCenterX-160
    teleports[2].y = display.contentCenterY-60
    teleports[2].myName = "teleport"
    teleports[2]:setSequence("active")

    teleports[3] = display.newSprite(teleportSheet,teleportSequence)
    teleports[3].x = display.contentCenterX+35
    teleports[3].y = display.contentCenterY-60
    teleports[3].myName = "teleport"
    teleports[3]:setSequence("active")

    teleports[4] = display.newSprite(teleportSheet,teleportSequence)
    teleports[4].x = display.contentCenterX+190
    teleports[4].y = display.contentCenterY+35
    teleports[4].myName = "teleport"
    teleports[4]:setSequence("active")

    teleports[5] = display.newSprite(teleportSheet,teleportSequence)
    teleports[5].x = display.contentCenterX-385
    teleports[5].y = display.contentCenterY-220
    teleports[5].myName = "teleport"
    teleports[5]:setSequence("active")

    teleports[6] = display.newSprite(teleportSheet,teleportSequence)
    teleports[6].x = display.contentCenterX+350
    teleports[6].y = display.contentCenterY-155
    teleports[6].myName = "teleport"
    teleports[6]:setSequence("active")

    coins[1] = display.newSprite(coinSheet,coinSequence)
    coins[1].x = display.contentCenterX - 425
    coins[1].y = display.contentCenterY + 90
    coins[1].myName = "coin"
    coins[1]:play()

    coins[2] = display.newSprite(coinSheet,coinSequence)
    coins[2].x = display.contentCenterX + 325
    coins[2].y = display.contentCenterY + 60
    coins[2].myName = "coin"
    coins[2]:play()

    coins[3] = display.newSprite(coinSheet,coinSequence)
    coins[3].x = display.contentCenterX + 250
    coins[3].y = display.contentCenterY - 130
    coins[3].myName = "coin"
    coins[3]:play()

    coins[4] = display.newSprite(coinSheet,coinSequence)
    coins[4].x = display.contentCenterX - 275
    coins[4].y = display.contentCenterY - 200
    coins[4].myName = "coin"
    coins[4]:play()

    coins[5] = display.newSprite(coinSheet,coinSequence)
    coins[5].x = display.contentCenterX - 15
    coins[5].y = display.contentCenterY - 325
    coins[5].myName = "coin"
    coins[5]:play()

    for x = 1,#coins do
        sceneGroup:insert(coins[x])
    end

    for x = 1,#teleports do
        sceneGroup:insert(teleports[x])
    end

    for x = 1,#platforms do
        sceneGroup:insert(platforms[x])
    end

    key = display.newImageRect(objectsGroup,"Images/key.png",32,32)
    key.x = display.contentCenterX+425
    key.y = display.contentCenterY-285
    key.myName = "key"
    sceneGroup:insert(key)

    doorEnd = display.newSprite(doorSheet,doorSequence)
    doorEnd.x = display.contentCenterX + 450
    doorEnd.y = display.contentCenterY + 200
    doorEnd.myName = "door"
    doorEnd:setSequence("closed")
    sceneGroup:insert(doorEnd)

    player = display.newRect(playerGroup,display.contentCenterX - 450,display.contentCenterY+200,16,64)
    player:setFillColor(255,255,255)
    player.myName = "player"
    sceneGroup:insert(player)

    playerX = player.x
end


-- show()
function scene:show( event )
    if ( event.phase == "did" ) then
        physics.start()
        physics.setGravity(0,15)
        activatePhysics()

        audio.stop(1)
        audio.play(levelTheme,{channel=1,loops=-1})

        timeTimer = timer.performWithDelay(1000,updateTime,0)

        Runtime:addEventListener("enterFrame",updateLevel)
        Runtime:addEventListener("collision",onCollision)
        Runtime:addEventListener("key",onPressed)
    end
end


-- hide()
function scene:hide( event )
    if ( event.phase == "did" ) then
        audio.stop(1)
        physics.stop()
        timer.cancelAll()

        Runtime:removeEventListener("enterFrame",updateLevel)
        Runtime:removeEventListener("collision",onCollision)
        Runtime:removeEventListener("key",onPressed)

        composer.removeScene("level1")
    end
end


-- destroy()
function scene:destroy( event )
    audio.dispose(buttonClicked)
    audio.dispose(levelTheme)
    audio.dispose(doorSound)
    audio.dispose(coinSound)
    audio.dispose(teleportSound)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
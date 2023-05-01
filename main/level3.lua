local composer = require( "composer" )
local physics = require("physics")
local widget = require("widget")
 
local scene = composer.newScene()
 
local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"
local filePath = system.pathForFile("Data/highscores.json")

local totalScore = composer.getVariable("totalScore")
local totalTime = composer.getVariable("totalTime")
local currentLevel = composer.setVariable("currentLevel",3)

local background
local backButton

local buttonClicked
local levelTheme
local teleportSound
local coinSound
local doorSound

local bgGroup
local uiGroup
local playerGroup
local objectsGroup
local platformGroup

local score = 0
local time = 0
local lives = 3
local coinsCollected = 0

local levelText
local scoreText
local timeText
local livesText

local key
local doorEnd

local player
local playerX = 0
local playerXSpeed = 2.5
local jumpPower = -0.2
local jump = false
local currentSwitch = 2
local allowToSwitch = false
local keyPressed = ""

local teleports1 = {1,3,5,6}
local teleports2 = {2,4}

local timeTimer
local spikeTimer

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

local switchSequence = 
{
    {
        name = "active",
        frames = {1}
    },
    {
        name = "unactive",
        frames = {2}
    }
}

local switchOptions = 
{
    width = 32,
    height = 36,
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
local switchSheet = graphics.newImageSheet("Images/switch.png",switchOptions)
local teleportSheet = graphics.newImageSheet("Images/teleport.png",teleportOptions)

local coins = {}
local platforms = {}
local teleports = {}
local teleportCoordinates = 
{{display.contentCenterX - 250,display.contentCenterY - 150},
{display.contentCenterX+ 40,display.contentCenterY- 25},
{display.contentCenterX,display.contentCenterY - 250},
{display.contentCenterX+ 400,display.contentCenterY - 100},
{display.contentCenterX - 375,display.contentCenterY - 235},
{display.contentCenterX + 325,display.contentCenterY - 275}}
local switches = {}

local currentTP

local function gotoMenu(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=2})
		composer.gotoScene("mainmenu")
	end
end

local function levelWin()
    score = score + (500 * lives)
    composer.setVariable("totalScore",score + totalScore)
    composer.setVariable("totalTime",time + totalTime)
	composer.gotoScene("gameEnd")
end

local function levelLose()
    composer.setVariable("totalScore",score + 0)
    composer.setVariable("totalTime",time + 0)
	composer.gotoScene("gameLose")
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

    for x = 1,#switches do
        physics.addBody(switches[x],"static",{bounce=0})
        switches[x].isSensor = true
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

local function updateSwitchesAndTeleports()
    if allowToSwitch == true then
        if currentSwitch == 1 then
            for x = 1,#teleports1 do
                teleports[teleports1[x]]:setSequence("closed")
            end
            for x = 1,#teleports2 do
                teleports[teleports2[x]]:setSequence("active")
            end

            currentSwitch = 2

            for x = 1,#switches do
                switches[x]:setSequence("unactive")
            end

        elseif currentSwitch == 2 then
            for x = 1,#teleports1 do
                teleports[teleports1[x]]:setSequence("active")
            end
            for x = 1,#teleports2 do
                teleports[teleports2[x]]:setSequence("closed")
            end

            currentSwitch = 1

            for x = 1,#switches do
                switches[x]:setSequence("active")
            end
        end
    end
end
 
local function onPressed(event)
    if event.phase == "down" then
        local key = event.keyName
        if (key == "a" or key == "left") or (key == "d" or key == "right") then
            keyPressed = key
        end
        if key == "e" then
            updateSwitchesAndTeleports()
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

local function resetPlayer()
    player.alpha = 1
    playerX = display.contentCenterX- 450
    player.y = display.contentCenterY-250
    lives = lives - 1
    livesText.text = "Lives: " .. lives
    if lives == 2 then
        levelLose()
    end
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

local function subtractScore()
    score = score - 100
    scoreText.text = "Score: " .. tostring(score)
end

local function updateDoor()
    audio.play(doorSound,{channel=4})
    doorEnd:setSequence("open")
end

local function onCollision(event)
    if event.phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2
        print(obj1.myName,obj2.myName)
        
        if obj1.myName == "platform" or obj2.myName == "platform" then
            jump = false
        end

        if obj1.myName == "switch" or obj2.myName == "switch" then
            allowToSwitch = true
        end

        if obj1.myName == "key" or obj2.myName == "key" then
            display.remove(key)
            updateDoor()
        end

        if obj1.myName == "door" or obj2.myName == "door" then
            if doorEnd.sequence == "open" then
                levelWin()
            end
        end

        if obj1.myName == "teleport" or obj2.myName == "teleport" then
            for i = #teleports, 1, -1 do
				if teleports[i] == obj1 or teleports[i] == obj2 then
                    if teleports[i].sequence == "active" then
                        print(i)
                        playerXSpeed = 0
                        currentTP = i
                        timer.performWithDelay(100,tpPlayer,1)
                    else
                        playerX = display.contentCenterX - 450
                        player.y = display.contentCenterY + 200
                    end
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
        local obj1 = event.object1
        local obj2 = event.object2
        if obj1.myName == "switch" or obj2.myName == "switch" then
            allowToSwitch = false
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
    levelTheme = audio.loadStream("Audio/level3Theme.mp3")

    bgGroup = display.newGroup()
    platformGroup = display.newGroup()
    objectsGroup = display.newGroup()
    playerGroup = display.newGroup()
    uiGroup = display.newGroup()

    background = display.newImageRect(bgGroup,"Images/bg.png",1024,768)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    levelText = display.newText("Level: 3",display.contentCenterX-440,display.contentCenterY-350,font,35)
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

    platforms[1] = display.newImage(platformSheet,4,96,448); platforms[1].myName = "platform"

    platforms[2] = display.newImage(platformSheet,5,864,512); platforms[2].myName = "platform"

    platforms[3] = display.newImage(platformSheet,8,544,416); platforms[3].myName = "platform"

    platforms[4] = display.newImage(platformSheet,6,288,320); platforms[4].myName = "platform"

    platforms[5] = display.newImage(platformSheet,5,896,320); platforms[5].myName = "platform"

    platforms[6] = display.newImage(platformSheet,4,128,192); platforms[6].myName = "platform"

    platforms[7] = display.newImage(platformSheet,8,512,160); platforms[7].myName = "platform"

    platforms[8] = display.newImage(platformSheet,5,864,128); platforms[8].myName = "platform"

    teleports[1] = display.newSprite(teleportSheet,teleportSequence)
    teleports[1].x = display.contentCenterX-175
    teleports[1].y = display.contentCenterY+200
    teleports[1].myName = "teleport"
    teleports[1]:setSequence("closed")

    teleports[2] = display.newSprite(teleportSheet,teleportSequence)
    teleports[2].x = display.contentCenterX - 160
    teleports[2].y = display.contentCenterY - 125
    teleports[2].myName = "teleport"
    teleports[2]:setSequence("active")

    teleports[3] = display.newSprite(teleportSheet,teleportSequence)
    teleports[3].x = display.contentCenterX + 400
    teleports[3].y = display.contentCenterY + 65
    teleports[3].myName = "teleport"
    teleports[3]:setSequence("closed")

    teleports[4] = display.newSprite(teleportSheet,teleportSequence)
    teleports[4].x = display.contentCenterX - 65
    teleports[4].y = display.contentCenterY - 30
    teleports[4].myName = "teleport"
    teleports[4]:setSequence("active")

    teleports[5] = display.newSprite(teleportSheet,teleportSequence)
    teleports[5].x = display.contentCenterX + 130
    teleports[5].y = display.contentCenterY - 30
    teleports[5].myName = "teleport"
    teleports[5]:setSequence("closed")

    teleports[6] = display.newSprite(teleportSheet,teleportSequence)
    teleports[6].x = display.contentCenterX + 100
    teleports[6].y = display.contentCenterY - 285
    teleports[6].myName = "teleport"
    teleports[6]:setSequence("closed")

    switches[1] = display.newSprite(switchSheet,switchSequence)
    switches[1].x = display.contentCenterX - 335
    switches[1].y = display.contentCenterY + 200
    switches[1].myName = "switch"
    switches[1]:setSequence("unactive")

    switches[2] = display.newSprite(switchSheet,switchSequence)
    switches[2].x = display.contentCenterX - 35
    switches[2].y = display.contentCenterY + 200
    switches[2].myName = "switch"
    switches[2]:setSequence("unactive")

    switches[3] = display.newSprite(switchSheet,switchSequence)
    switches[3].x = display.contentCenterX - 250
    switches[3].y = display.contentCenterY - 110
    switches[3].myName = "switch"
    switches[3]:setSequence("unactive")

    switches[4] = display.newSprite(switchSheet,switchSequence)
    switches[4].x = display.contentCenterX + 325
    switches[4].y = display.contentCenterY + 85
    switches[4].myName = "switch"
    switches[4]:setSequence("unactive")

    switches[5] = display.newSprite(switchSheet,switchSequence)
    switches[5].x = display.contentCenterX + 345
    switches[5].y = display.contentCenterY - 300
    switches[5].myName = "switch"
    switches[5]:setSequence("unactive")

    coins[1] = display.newSprite(coinSheet,coinSequence)
    coins[1].x = display.contentCenterX - 415
    coins[1].y = display.contentCenterY + 25
    coins[1].myName = "coin"
    coins[1]:play()

    coins[2] = display.newSprite(coinSheet,coinSequence)
    coins[2].x = display.contentCenterX + 25
    coins[2].y = display.contentCenterY - 10
    coins[2].myName = "coin"
    coins[2]:play()

    coins[3] = display.newSprite(coinSheet,coinSequence)
    coins[3].x = display.contentCenterX + 410
    coins[3].y = display.contentCenterY - 100
    coins[3].myName = "coin"
    coins[3]:play()

    coins[4] = display.newSprite(coinSheet,coinSequence)
    coins[4].x = display.contentCenterX - 340
    coins[4].y = display.contentCenterY - 225
    coins[4].myName = "coin"
    coins[4]:play()

    coins[5] = display.newSprite(coinSheet,coinSequence)
    coins[5].x = display.contentCenterX + 300
    coins[5].y = display.contentCenterY - 290
    coins[5].myName = "coin"
    coins[5]:play()

    key = display.newImageRect(objectsGroup,"Images/key.png",32,32)
    key.x = display.contentCenterX-425
    key.y = display.contentCenterY-225
    key.myName = "key"
    sceneGroup:insert(key)

    doorEnd = display.newSprite(doorSheet,doorSequence)
    doorEnd.x = display.contentCenterX + 400
    doorEnd.y = display.contentCenterY - 310
    doorEnd.myName = "door"
    doorEnd:setSequence("closed")
    sceneGroup:insert(doorEnd)

    player = display.newRect(playerGroup,display.contentCenterX- 450,display.contentCenterY+200,16,64)
    player:setFillColor(255,255,255)
    player.myName = "player"
    sceneGroup:insert(player)

    playerX = player.x
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
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
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        audio.stop(1)
        physics.stop()
        timer.cancelAll()
        Runtime:removeEventListener("enterFrame",updateLevel)
        Runtime:removeEventListener("collision",onCollision)
        Runtime:removeEventListener("key",onPressed)

        for x = 1,#coins do
            display.remove(coins[x])
        end

        for x = 1,#teleports do
            display.remove(teleports[x])
        end

        for x = 1,#platforms do
            display.remove(platforms[x])
        end

        for x = 1,#switches do
            display.remove(switches[x])
        end

        composer.removeScene("level3")
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    audio.dispose(buttonClicked)
    audio.dispose(levelTheme)
    audio.dispose(doorSound)
    audio.dispose(coinSound)
    audio.dispose(teleportSound)
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene
local composer = require( "composer" )
local widget = require("widget")
local json = require("json")

local scene = composer.newScene()

-- variables

local background
local title

local totalScore = composer.getVariable("totalScore")
local totalTime = composer.getVariable("totalTime")
local currentLevel = composer.getVariable("currentLevel")

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"

local filePath = system.pathForFile("Data/highscores.json")
local highscores = {}

local scoreText
local timeText
local levelText
local encourageText
local result = "Don't worry, I'm sure you'll do better next time!"

local backButton

local loseTheme
local buttonClicked

-- functions

local function gotoMenu(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("mainmenu")
	end
end

local function getHighScores()
	-- open the file
	local file = io.open(filePath,"r")

	-- check if file exists
	if file then
		-- get the contents
        local contents = file:read("*a")
        io.close(file)
		local decodedlist = json.decode(contents)

		-- get highscores
        for x = 1,10 do
            highscores[x] = decodedlist[x]
        end
    end
end

local function checkHighScores()
	-- Check if we got a new high score
	for x = 1,10 do
        if totalScore > highscores[x] then
            highscores[x] = totalScore
            result = "You got a new highscore! Rank is: " .. x
            break
        end
	end
end

local function saveHighScores()
	-- open file
    local file = io.open(filePath,"r")

	-- get the contents
    local contents = file:read("*a")
    io.close(file)
    local decodedlist = json.decode(contents)

	decodedlist = highscores


	-- save the new high scores to the file
    local file = io.open(filePath,"w")
    file:write(json.encode(decodedlist))
    io.close(file)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	getHighScores()
	checkHighScores()
	saveHighScores()

	buttonClicked = audio.loadSound("Audio/buttonClicked.mp3")
    loseTheme = audio.loadStream("Audio/gameLoseTheme.mp3")

	background = display.newImageRect("Images/bg.png",1024,768)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	sceneGroup:insert(background)

	title = display.newText("YOU LOST!",display.contentCenterX,100,font,100)
	title:setFillColor(0,0,0)
	title.alpha = 0
    transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

    levelText = display.newText("You failed at level: " .. currentLevel,display.contentCenterX,250,font,40)
	levelText:setFillColor(0,0,0)
    levelText.alpha = 0
    transition.fadeIn(levelText,{time=500,delay=0})
	sceneGroup:insert(levelText)

    scoreText = display.newText("Your score was: " .. totalScore,display.contentCenterX,325,font,40)
	scoreText:setFillColor(0,0,0)
    scoreText.alpha = 0
    transition.fadeIn(scoreText,{time=500,delay=250})
	sceneGroup:insert(scoreText)

	timeText = display.newText("Your time was: " .. totalTime,display.contentCenterX,400,font,40)
	timeText:setFillColor(0,0,0)
    timeText.alpha = 0
    transition.fadeIn(timeText,{time=500,delay=500})
	sceneGroup:insert(timeText)

	encourageText = display.newText(result,display.contentCenterX,475,font,40)
	encourageText:setFillColor(0,0,0)
    encourageText.alpha = 0
    transition.fadeIn(encourageText,{time=500,delay=750})
	sceneGroup:insert(encourageText)

    backButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY + 300,
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

	backButton.alpha = 0
    transition.fadeIn(backButton,{time=2000})
	sceneGroup:insert(backButton)

end


-- show()
function scene:show( event )
	if ( event.phase == "did" ) then
        audio.stop(1)
        audio.play(loseTheme,{channel=1,loops=-1})
	end
end


-- hide()
function scene:hide( event )
	if ( event.phase == "did" ) then
        audio.stop(1)
		composer.removeScene("gameLose")
	end
end


-- destroy()
function scene:destroy( event )
	audio.dispose(buttonClicked)
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
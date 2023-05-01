
local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()

-- variables

local background
local title

local totalScore = composer.getVariable("totalScore")
local totalTime = composer.getVariable("totalTime")
local currentLevel = composer.getVariable("currentLevel")

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"

local scoreText
local timeText
local levelText
local encourageText

local backButton

local winTheme
local buttonClicked

-- functions

local function gotoNextLevel(event)
	if "ended" == event.phase then
        audio.play(buttonClicked,{channel=5})
        if currentLevel == 1 then
            composer.gotoScene("level2")
        elseif currentLevel == 2 then
			composer.gotoScene("level3")
        end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	buttonClicked = audio.loadSound("Audio/buttonClicked.mp3")
    winTheme = audio.loadStream("Audio/gameWinTheme.mp3")

	background = display.newImageRect("Images/bg.png",1024,768)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	sceneGroup:insert(background)

	title = display.newText("YOU WIN!",display.contentCenterX,100,font,100)
	title:setFillColor(0,0,0)
	title.alpha = 0
    transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

    levelText = display.newText("You finished level: " .. currentLevel,display.contentCenterX,250,font,40)
	levelText:setFillColor(0,0,0)
    levelText.alpha = 0
    transition.fadeIn(levelText,{time=500,delay=0})
	sceneGroup:insert(levelText)

    scoreText = display.newText("Your score is: " .. totalScore,display.contentCenterX,325,font,40)
	scoreText:setFillColor(0,0,0)
    scoreText.alpha = 0
    transition.fadeIn(scoreText,{time=500,delay=250})
	sceneGroup:insert(scoreText)

	timeText = display.newText("Your time is: " .. totalTime,display.contentCenterX,400,font,40)
	timeText:setFillColor(0,0,0)
    timeText.alpha = 0
    transition.fadeIn(timeText,{time=500,delay=500})
	sceneGroup:insert(timeText)

	encourageText = display.newText("Great work! Move on to the next level.",display.contentCenterX,475,font,40)
	encourageText:setFillColor(0,0,0)
    encourageText.alpha = 0
    transition.fadeIn(encourageText,{time=500,delay=750})
	sceneGroup:insert(encourageText)
	
    backButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY + 300,
			id = "backButton",
			label = "Proceed",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoNextLevel,
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

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        audio.stop(1)
        audio.play(winTheme,{channel=1,loops=-1})
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
		composer.removeScene("gameWin")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(buttonClicked)
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
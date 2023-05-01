local composer = require( "composer" )
local widget = require("widget")
local json = require("json")

local scene = composer.newScene()

-- variables

local background
local title

local HIScoreText

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"

local filePath = system.pathForFile("Data/highscores.json")

local scores = {}

local backButton

local buttonClicked

-- functions


local function gotoMenu(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("mainmenu")
	end
end

local function getHighScores()
    local file = io.open(filePath,"r")

    if file then
        local contents = file:read("*a")
        io.close(file)
        scores = json.decode(contents)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local x = display.contentCenterX - 200
    local y = 250
	local count = 1

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

    buttonClicked = audio.loadSound("Audio/buttonClicked.mp3")
    getHighScores()

	background = display.newImageRect("Images/bg.png",1024,768)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	sceneGroup:insert(background)

	title = display.newText("High scores:",display.contentCenterX,100,font,100)
    title:setFillColor(0,0,0)
    title.alpha = 0
    transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

    for a = 1,2 do
        y = 250
        for b = 1,5 do
            HIScoreText = display.newText(tostring(count) .. ". " .. scores[count],x,y,font,50)
            HIScoreText:setFillColor(0,0,0)
            HIScoreText.alpha = 0
            transition.fadeIn(HIScoreText,{time=500,delay=500})
            y = y + 50
			count = count + 1
			sceneGroup:insert(HIScoreText)
        end
        x = x + 400
    end

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
			overFile = buttonNormalSprite,
		}
	)
    backButton.alpha = 0
	transition.fadeIn(backButton,{time=1000,delay=500})
	sceneGroup:insert(backButton)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
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
		composer.removeScene("menuscores")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
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
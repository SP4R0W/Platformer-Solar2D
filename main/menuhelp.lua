
local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()

-- variables

local background
local title

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"

local backButton

local buttonClicked

-- functions

local function gotoMenu(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("mainmenu")
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

	background = display.newImageRect("Images/bg.png",1024,768)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	sceneGroup:insert(background)

	title = display.newText("CONTROLS:",display.contentCenterX,100,font,100)
	title:setFillColor(0,0,0)
	title.alpha = 0
    transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

	local helpText1 = display.newText("Control the player using WASD or arrow keys.",display.contentCenterX,275,font,35)
	helpText1:setFillColor(0,0,0)
    helpText1.alpha = 0
    transition.fadeIn(helpText1,{time=500,delay=250})
	sceneGroup:insert(helpText1)

	local helpText2 = display.newText("To interact with switches, walk into them and press 'E' key.",display.contentCenterX,350,font,35)
	helpText2:setFillColor(0,0,0)
    helpText2.alpha = 0
    transition.fadeIn(helpText2,{time=500,delay=500})
	sceneGroup:insert(helpText2)

	local helpText3 = display.newText("You can only use teleports that are activated.",display.contentCenterX,425,font,35)
	helpText3:setFillColor(0,0,0)
    helpText3.alpha = 0
    transition.fadeIn(helpText3,{time=500,delay=750})
	sceneGroup:insert(helpText3)
	
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
		composer.removeScene("menuhelp")
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
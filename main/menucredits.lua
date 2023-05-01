
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

	title = display.newText("CREDITS:",display.contentCenterX,100,font,100)
	title:setFillColor(0,0,0)
	title.alpha = 0
    transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

    local creatortitle = display.newText("Coded by SP4R0W",display.contentCenterX,200,font,40)
	creatortitle:setFillColor(0,0,0)
    creatortitle.alpha = 0
    transition.fadeIn(creatortitle,{time=500,delay=0})
	sceneGroup:insert(creatortitle)

	local imagesText = display.newText("All images were found on the Internet and are not mine.",display.contentCenterX,300,font,30)
	imagesText:setFillColor(0,0,0)
    imagesText.alpha = 0
    transition.fadeIn(imagesText,{time=500,delay=250})
	sceneGroup:insert(imagesText)

	local creditsText = display.newText("Every image here belongs to its rightful owner. (except the logo)",display.contentCenterX,350,font,30)
	creditsText:setFillColor(0,0,0)
    creditsText.alpha = 0
    transition.fadeIn(creditsText,{time=500,delay=500})
	sceneGroup:insert(creditsText)

	local musicText = display.newText("All music were found on the Internet and are not mine.",display.contentCenterX,400,font,30)
	musicText:setFillColor(0,0,0)
    musicText.alpha = 0
    transition.fadeIn(musicText,{time=500,delay=750})
	sceneGroup:insert(musicText)

	local creditsText = display.newText("Every track here belongs to its rightful owner.",display.contentCenterX,450,font,30)
	creditsText:setFillColor(0,0,0)
    creditsText.alpha = 0
    transition.fadeIn(creditsText,{time=500,delay=1000})
	sceneGroup:insert(creditsText)

	local fontText = display.newText("Font used is Screen Gem made by Raymond Larabie",display.contentCenterX,500,font,30)
	fontText:setFillColor(0,0,0)
    fontText.alpha = 0
    transition.fadeIn(fontText,{time=500,delay=1250})
	sceneGroup:insert(fontText)

	local logoText = display.newText("Logo has been made by Freepik.",display.contentCenterX,550,font,30)
	logoText:setFillColor(0,0,0)
    logoText.alpha = 0
    transition.fadeIn(logoText,{time=500,delay=1500})
	sceneGroup:insert(logoText)
	
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
		composer.removeScene("menucredits")
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

local composer = require( "composer" )
local widget = require("widget")
local json = require("json")

local scene = composer.newScene()

-- variables

local background
local title
local creator

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"
local filePath = system.pathForFile("Data/highscores.json")

local musicState = composer.getVariable("musicState")
local sfxState = composer.getVariable("sfxState")

local musicButton
local sfxButton
local resetScores
local backButton

local defaultScores = {25000,15000,10000,8500,7500,5000,3500,2500,1500,1000}

local buttonClicked

-- functions

local function changeMusic()

    if musicState == true then
        composer.setVariable("musicState",false)
        audio.setVolume(0,{channel=1})
    elseif musicState == false then
        composer.setVariable("musicState",true)
        audio.setVolume(1,{channel=1})
    end

    musicState = composer.getVariable("musicState")

    musicButton:setLabel("Music: " .. tostring(musicState))
end

local function changeSFX()

    if sfxState == true then
        composer.setVariable("sfxState",false)
        audio.setVolume(0,{channel=2})
        audio.setVolume(0,{channel=3})
		audio.setVolume(0,{channel=4})
        audio.setVolume(0,{channel=5})
    elseif sfxState == false then
        composer.setVariable("sfxState",true)
        audio.setVolume(1,{channel=2})
        audio.setVolume(1,{channel=3})
		audio.setVolume(1,{channel=4})
        audio.setVolume(1,{channel=5})
    end

    sfxState = composer.getVariable("sfxState")

    sfxButton:setLabel("SFX: " .. tostring(sfxState))
end

local function resetScores()
	-- save the new high scores to the file
    local file = io.open(filePath,"w")
    file:write(json.encode(defaultScores))
    io.close(file)
end

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

	title = display.newText("Options",display.contentCenterX,100,font,100)
	title:setFillColor(0,0,0)
	title.alpha = 0
	transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

	musicButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY-100,
			id = "menuButton1",
			label = "Music: " .. tostring(musicState),
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = changeMusic,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	musicButton.alpha = 0
	transition.fadeIn(musicButton,{time=2000})
	sceneGroup:insert(musicButton)

	sfxButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY,
			id = "menuButton2",
			label = "SFX: " .. tostring(sfxState),
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = changeSFX,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	sfxButton.alpha = 0
	transition.fadeIn(sfxButton,{time=2000})
	sceneGroup:insert(sfxButton)

	resetButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY+100,
			id = "menuButton3",
			label = "Reset scores",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = resetScores,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	resetButton.alpha = 0
	transition.fadeIn(resetButton,{time=2000})
	sceneGroup:insert(resetButton)

	backButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY + 300,
			id = "menuButton3",
			label = "Back",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoMenu,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite
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

        composer.removeScene("menuoptions")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose(buttonClicked)
	audio.dispose(menuTheme)
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

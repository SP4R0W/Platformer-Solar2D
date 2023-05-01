
local composer = require( "composer" )
local widget = require("widget")

local scene = composer.newScene()

-- variables

local background
local title
local creator

local buttonNormalSprite = "Images/buttonNormal.png"
local font = "screengem.ttf"

local playButton
local scoresButton
local helpButton
local optionsButton
local creditsButton

local buttonClicked
local menuTheme

-- functions

local function gotoGame(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("level1")
	end
end

local function gotoHelp(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("menuhelp")
	end
end

local function gotoScores(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("menuscores")
	end
end

local function gotoOptions(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("menuoptions")
	end
end

local function gotoCredits(event)
	if "ended" == event.phase then
		audio.play(buttonClicked,{channel=5})
		composer.gotoScene("menucredits")
	end
end

local function playMusic()
	if audio.isChannelPlaying(1) == false then
		audio.play(menuTheme,{channel=1,loops=-1})
	end
end

-- create()
function scene:create( event )

	local sceneGroup = self.view

	buttonClicked = audio.loadSound("Audio/buttonClicked.mp3")
	menuTheme = audio.loadStream("Audio/mainmenuTheme.mp3")

	background = display.newImageRect("Images/bg.png",1024,768)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	sceneGroup:insert(background)

	title = display.newText("Platformer",display.contentCenterX,100,font,100)
	title:setFillColor(0,0,0)
	title.alpha = 0
	transition.fadeIn(title,{time=1000})
	sceneGroup:insert(title)

	creator = display.newText("Coded by SP4R0W",display.contentCenterX,200,font,30)
	creator:setFillColor(0,0,0)
	creator.alpha = 0
	transition.fadeIn(creator,{time=1000})
	sceneGroup:insert(creator)

	playButton = widget.newButton(
		{
			x = display.contentCenterX,
			y = display.contentCenterY - 100,
			id = "menuButton1",
			label = "Play",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoGame,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	playButton.alpha = 0
	transition.fadeIn(playButton,{time=2000})
	sceneGroup:insert(playButton)

	helpButton = widget.newButton(
		{
			x = display.contentCenterX - 150,
			y = display.contentCenterY + 25,
			id = "menuButton2",
			label = "Help",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoHelp,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	helpButton.alpha = 0
	transition.fadeIn(helpButton,{time=2000})
	sceneGroup:insert(helpButton)

	scoresButton = widget.newButton(
		{
			x = display.contentCenterX - 150,
			y = display.contentCenterY + 150,
			id = "menuButton2",
			label = "High Scores",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoScores,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	scoresButton.alpha = 0
	transition.fadeIn(scoresButton,{time=2000})
	sceneGroup:insert(scoresButton)

	optionsButton = widget.newButton(
		{
			x = display.contentCenterX + 150,
			y = display.contentCenterY + 25,
			id = "menuButton3",
			label = "Options",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoOptions,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite,
		}
	)

	optionsButton.alpha = 0
	transition.fadeIn(optionsButton,{time=2000})
	sceneGroup:insert(optionsButton)

	creditsButton = widget.newButton(
		{
			x = display.contentCenterX + 150,
			y = display.contentCenterY + 150,
			id = "menuButton4",
			label = "Credits",
			labelColor = {default={0,0,0}},
			font = font,
			fontSize = 30,
			onRelease = gotoCredits,
			defaultFile = buttonNormalSprite,
			overFile = buttonNormalSprite
		}
	)

	creditsButton.alpha = 0
	transition.fadeIn(creditsButton,{time=2000})
	sceneGroup:insert(creditsButton)

end


-- show()
function scene:show( event )
	if ( event.phase == "did" ) then
		playMusic()
	end
end


-- hide()
function scene:hide( event )
	if ( event.phase == "did" ) then
		composer.removeScene("mainmenu")
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

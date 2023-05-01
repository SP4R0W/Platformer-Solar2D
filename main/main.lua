local composer = require("composer")
local widget = require("widget")

local background
local mainButton

local musicState = composer.setVariable("musicState",true)
local sfxState = composer.setVariable("sfxState",true)

function clicked(event)
    if event.phase == "ended" then
        display.remove(background)
        background:removeEventListener("touch",clicked)
        composer.gotoScene("mainmenu")
    end
end

audio.reserveChannels(1) -- channel for bg music
audio.reserveChannels(2)
audio.reserveChannels(3)
audio.reserveChannels(4)
audio.reserveChannels(5)

math.randomseed(os.time())

display.setDefault("background",128,128,128)

background = display.newImageRect("Images/logo.png",1024,768)
background.x = display.contentCenterX
background.y = display.contentCenterY
background.alpha = 0
transition.fadeIn(background,{time=2500})

background:addEventListener("touch",clicked)

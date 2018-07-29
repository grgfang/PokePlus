--[[
Script: pokeplus.lus
Github: https://github.com/grgfang/PokePlus

OS: Android
Automation Environment: Ankulua
Language: Lua
Ankulua Website:
	English: http://ankulua.boards.net/
	Chinese: http://ankulua-tw.boards.net/

Purpose: Pokemon GO script.	
	
Features:
0. Blind Click, then
1. Catch Pokemon.
2. Spin Pokestop.

Disclaimer:
This script may be officially detected and the game account will be dismissed in violation of the Terms of Service.
I am not responsible for any loss caused by the use of this script.
If you want to use it, please bear any possible losses.

Tested Device: Nexus 5, Nexus 5X, Nexus 6P, Pixel.
--]]
-- ========== Settings ================
Settings:setCompareDimension(true, 540)
Settings:setScriptDimension(true, 540)
Settings:set("MinSimilarity", 0.80)

setImmersiveMode(true)

-- ========== Function ================
function antiDragDrop(ps1, ps2)
    modDragDrop = 2
    if modDragDrop == 1 then
        dragDrop(ps1,ps2)
    elseif modDragDrop == 2 then
        swipe(ps1,ps2)
    end
end

function funSnapContinue()
    usePreviousSnap(false)
end

function funSnapScreen()
    usePreviousSnap(false)
    exists("snap_dummy_grey.png", 0) -- just for screen capture
    usePreviousSnap(true)
end

function pcallDragDrop(ps1, ps2)
    rtnPcall = 0
    if pcall(antiDragDrop, ps1, ps2) then
        rtnPcall = 1
    else
        toast("dragDrop error")
    end

    return rtnPcall
end


-- ========== User Interface ================
dialogInit()

newRow()
addTextView("ver：20180728 1239")

newRow()
addTextView("Catch Throw Max = ")
addEditNumber("intPK5_thrMax", 3)

dialogShow("Set Parameters")

thrMax = intPK5_thrMax
thrCnt = 0

regBottom = Region(0, 730, 540, 230)
regMain = regBottom
regCatchFruit = regBottom
regCatchBall = regBottom
regPokestopBottom = regBottom
regPokestopExit = regBottom

regEggOh = Region(0, 200, 540, 150)

modeNum = 0

aryX = {-65, -65, -65,   0,   0,   0,  65,  65,  65}
aryY = {-65,   0,  65, -65,   0,  65, -65,   0,  65}
aryIdx = 0

flgDebug = 0
-- ========== Main Program ================
while true do

    funSnapScreen()

    flgExec = 0

    -- GYM/Raid
    if flgExec == 0 and regBottom:exists("gym_pokestop.png", 0) and regBottom:exists("gym_exit.png", 0) then
        flgExec = 1

        if flgDebug == 1 then toast("gym"); end

        click(regBottom:exists("gym_exit.png", 0))
        wait(5)
    end

    -- Pokestop
    if flgExec == 0 and regPokestopBottom:exists("pokestop_bottom.png", 0) and regPokestopExit:exists("pokestop_exit.png", 0) then
        flgExec = 1

        if flgDebug == 1 then toast("pokestop"); end

        turnBgn = Location(30, 340)
        turnEnd = Location(350, 340)
        pcallDragDrop(turnBgn, turnEnd)
        wait(5)

        --#Bag is full

        click(regPokestopExit:exists("pokestop_exit.png", 0))
        wait(5)
    end

    -- Catch
    if flgExec == 0 and regCatchFruit:exists("catch_fruit.png", 0) and regCatchBall:exists("catch_ball.png", 0) then
        flgExec = 1

        if flgDebug == 1 then toast("catch"); end

        if thrCnt >= thrMax then
            -- Exceed Max
            thrCnt = 0
            click(Location(50, 80))
            wait(5)
        else
            -- Thraw
            thrCnt = thrCnt + 1

            stepCount = 5
            if thrCnt == 2 then stepCount = 7; end -- near ?
            if thrCnt >= 3 then stepCount = 3; end -- far ?

            locEndY = 170 -- below camera

            setDragDropTiming(3000, 0)
            setDragDropStepCount(stepCount)
            setDragDropStepInterval(40)
            pcallDragDrop(Location(270, 852), Location(270, locEndY))
            wait(5)
        end
    end

    -- Gotcha
    if flgExec == 0 and exists("gotcha_total.png", 0) and exists("gotcha_xp.png", 0) and exists("gotcha_ok.png", 0) then
        flgExec = 1

        if flgDebug == 1 then toast("gotcha"); end

        click(exists("gotcha_ok.png", 0))
        wait(5)
    end

    -- Pokemon info
    if flgExec == 0 and regBottom:exists("pokeinfo_menu.png", 0) and regBottom:exists("pokeinfo_exit.png", 0) then
        flgExec = 1

        if flgDebug == 1 then toast("pokeinfo"); end

        click(regBottom:exists("pokeinfo_exit.png", 0))
        wait(5)
    end

    -- Egg
    if flgExec == 0 and (regEggOh:exists("egg_oh.png", 0) or regEggOh:exists("egg_oh_tw.png", 0)) then
        flgExec = 1

        if flgDebug == 1 then toast("egg"); end

        click(regEggOh:getLastMatch())
        wait(5)
    end

    -- Main
    if flgExec == 0 and regMain:exists("main_menu.png", 0) then
        flgExec = 1

        if flgDebug == 1 then toast("main"); end

        thrCnt = 0

        cntTry = 0

        while true do
            funSnapContinue()

            cntTry = cntTry + 1
            if cntTry > 9 then break; end
            aryIdx = aryIdx + 1
            if aryIdx > 9 then aryIdx = 1; end

            funSnapScreen()

            if regMain:exists("main_menu.png", 0) then
                if flgDebug == 1 then toast("main-"..aryIdx); end

                click(regMain:exists(Pattern("main_menu.png"):targetOffset(0 + aryX[aryIdx],-180 + aryY[aryIdx]),0))
            else
                break
            end
        end
    end

end

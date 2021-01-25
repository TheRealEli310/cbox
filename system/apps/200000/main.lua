-- Menu API provided by cyanisaac and ProjectB, licensed under the MIT license.
title = "Dashboard"
--???
cEwaDo = 0
if not save then
	shell.run("/system/crash.lua 001-200000")
elseif not menu then
	shell.run("/system/crash.lua 001-200000")
end
save.registerID(200000)
save.createSavDir("Dashboard")
while true do
    sel = menu.doMenu(title,{"Start Disk","Save Data","Settings","Shell","Apps"})
    if sel == 1 then
        if fs.exists("/disk/main.lua") then
            term.clear()
            term.setCursorPos(1,1)
            bootAnimB()
            shell.run("/disk/main.lua")
			bootAnim()
        else
            menu.doInfoScreen(title,"No disk inserted!")
	    cEwaDo = cEwaDo + 1
	    if cEwaDo == 10 then
	        shell.run("/system/crash.lua 666-666666")
	    end
        end
    end
    if sel == 2 then
        shell.run("/system/apps/200000/sav.lua")
    end
    if sel == 3 then
        shell.run("/system/apps/200000/sett.lua")
    end
    if sel == 4 then
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
        shell.run("shell")
    end
	if sel == 5 then
		while true do
			sela = menu.doMenu("Applications",{"Back","GChat"})
			if sela == 1 then
				break
			end
			if sela == 2 then
				shell.run("chat join CCGCChatClient User")
			end
		end
	end
end

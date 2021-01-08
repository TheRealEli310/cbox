
settings.load("/.settings")
--_G.logm = peripheral.find("monitor")
--logm.write("Loading menu API\n")
os.loadAPI("/system/menu")
function _G.bootAnim()
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
local w,h = term.getSize()
menu.center("Cbox",h/2,colors.lime)
sleep(2)
bootAnimB()
end
function _G.bootAnimB()
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
local w,h = term.getSize()
menu.center("Cbox",h/2,colors.lime)
menu.center("Goldcore",h,colors.white)
sleep(2)
end
bootAnim()
os.loadAPI("/system/apis/save.lua")
os.loadAPI("/system/apis/dlp.lua")
os.loadAPI("/system/apis/3d.lua")
--os.loadAPI("/system/rsa")
--logm.write("Starting Dashboard\n")
function os.version()
	return "CBox"
end
if not (settings.get("setup.done") == true) then
	shell.run("/system/apps/200001/main.lua")
end
shell.run("/system/apps/200000/main.lua")
os.reboot()

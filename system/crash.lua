local tArgs = {...}
term.clear()
term.setCursorPos(1,1)
local w,h = term.getSize()
local tth = (h/2)-1
local tbh = (h/2)+1
menu.center("An error has occured.",tth)
menu.center("Please hold CTRL+R to reboot.",tbh)
menu.center(tArgs[1],h)
os.pullEvent = os.pullEventRaw
while true do
  sleep(0.1)
end

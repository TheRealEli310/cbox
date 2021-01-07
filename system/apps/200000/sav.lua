-- Menu API provided by cyanisaac and ProjectB, licensed under the MIT license.
title = "Save Data"
while true do
    sel = menu.doMenu(title,{"Back","View Saves"})
	if sel == 1 then
		break
	end
	if sel == 2 then
		saves = save.readSaves()
		savesn = {}
		for i,v in ipairs(saves) do
			local f = fs.open("/save/"..tostring(v).."/name.nfo","r")
			savesn[#savesn+1] = f.readAll()
			f.close()
		end
		savsel = menu.doMenu(title,savesn)
		title = savesn[savsel]
		menu.doMenu(title,{"Back","Copy","Move","Erase"})
		title = "Save Data"
	end
end

-- Menu API provided by cyanisaac and ProjectB, licensed under the MIT license.
title = "Save Data"
while true do
    sel = menu.doMenu(title,{"Back","View Saves"})
	if sel == 1 then
		break
	end
	if sel == 2 then
		locsel = menu.doMenu(title,{"Internal Storage","Memory Card"})
		if locsel == 1 then
			loc = "/save/"
		elseif locsel == 2 then
			loc = "/disk/save/"
		end
		saves = save.readSaves()
		savesn = {}
		for i,v in ipairs(saves) do
			local f = fs.open(loc..tostring(v).."/name.nfo","r")
			savesn[#savesn+1] = f.readAll()
			f.close()
		end
		savsel = menu.doMenu(title,savesn)
		title = savesn[savsel]
		sop = menu.doMenu(title,{"Back","Copy","Move","Erase"})
		if sop == 1 then
		end
		if sop == 2 then
		end
		if sop == 3 then
		end
		if sop == 4 then
			save.delSav(saves[savsel],loc)
		end
		title = "Save Data"
	end
end

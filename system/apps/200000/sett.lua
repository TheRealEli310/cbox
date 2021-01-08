-- Menu API provided by cyanisaac and ProjectB, licensed under the MIT license.
title = "Settings"
while true do
    sel = menu.doMenu(title,{"Back","Language","System Update"})
    if sel == 1 then
        break
    end
    if sel == 2 then
        lang = menu.doMenu("Language",{"English"})
        settings.set("sys.language",lang)
    end
	if sel == 3 then
		updsel = menu.doMenu("System Update",{"Update via Internet","Install from disk"})
		if updsel == 1 then
			shell.dir("")
			shell.run("gitget TheRealEli310 cbox main")
			os.reboot()
		end
	end
end

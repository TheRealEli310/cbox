function createSavDir(name)
	if not fs.exists("/save/"..tostring(_G.running)) then
		fs.makeDir("/save/"..tostring(_G.running))
		local nf = fs.open("/save/"..tostring(_G.running).."/name.nfo","w")
		nf.write(name)
		nf.close()
		return true
	else
		return false
	end
end
function registerID(id)
	_G.running = id
end
function readSaves()
	return fs.list("/save")
end
function delSav(id)
	if fs.exists("/save/"..tostring(id)) then
		fs.delete("/save/"..tostring(id))
		return true
	else
		return false
	end
end

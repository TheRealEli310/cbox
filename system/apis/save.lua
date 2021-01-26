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
function readSaves(loc)
	return fs.list(loc)
end
function delSav(id,loc)
	if fs.exists(loc..tostring(id)) then
		fs.delete(loc..tostring(id))
		return true
	else
		return false
	end
end

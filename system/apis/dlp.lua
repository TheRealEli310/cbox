function activate(side)
  return rednet.open(side)
end
function dohost(prog)
  rednet.host("CboxDl",tostring(os.getComputerID()))
  local s,m,p = rednet.receive()
  sleep(0.1)
  rednet.send(s,prog)
end
function listdls()
  return rednet.lookup("CboxDl")
end
function dodl(id)
  rednet.send(id,"")
  local s,m,p = rednet.receive()
  return {s,m}
end

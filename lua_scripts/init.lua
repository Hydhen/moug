print("\n")
print("ESP8266 Started")

node.compile("game.lua")
luaFile = nil
collectgarbage()

dofile("game.lc");

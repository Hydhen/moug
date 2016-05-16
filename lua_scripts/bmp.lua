OSS = 3 -- oversampling setting (0-3)
SDA_PIN = 2 -- sda pin, GPIO2 that is D2 (Put your sensor here, for example on pin 1 and 2 doesn't work, who knows why)
SCL_PIN = 3 -- scl pin, GPIO0 that is D3

gpio.mode(1, gpio.OUTPUT)

function get_data()
	 bmp180 = require("bmp180")
	 bmp180.init(SDA_PIN, SCL_PIN)
	 bmp180.read(OSS)

	 t = bmp180.getTemperature()
	 p = bmp180.getPressure()

	 -- temperature in degrees Celsius  and Farenheit
	 print("Temperature: "..(t))
	 -- pressure in differents units
	 print("Pressure: "..(p))

	 -- release module
	 bmp180 = nil
	 package.loaded["bmp180"]=nil
end

tmr.alarm(0, 5000, 1, function() get_data() end )
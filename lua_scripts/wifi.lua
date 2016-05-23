TMR_GAME    = 0
TMR_WIFI    = 1
TMR_GET     = 2

SSID        = "MougPi"
PASSWORD    = "password"

GET         = "/"

function config()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, PASSWORD, 1)
    print("Trying connection with :")
    print("SSID: " .. SSID)
    print("PASSWORD: " .. PASSWORD)
end

function connect()
    if wifi.sta.getip () == nil then
        print("Waiting for Wifi connection")
    else
        print("ESP8266 mode is: " .. wifi.getmode ())
        print("The module MAC address is: " .. wifi.ap.getmac ())
        print("Config done, IP is " .. wifi.sta.getip ())
        tmr.stop(TMR_WIFI)
    end
end

function get()
    if tmr.state(TMR_WIFI) == false then
        print("== Create connection ==")
        conn = net.createConnection(net.TCP, 0)

        print("== Set receive callback ==")
        conn:on("receive", function(sck, data)
            print("::R::")
            print(data)
            print(":::::")
        end)

        print("== Connect ==")
        conn:connect(80, "192.168.42.1")

        print("== Set connection callback ==")
        conn:on("connection", function(sck, data)
            print("::C::")
            print(data)
            print(":::::")
            print("== Send ==")
            sck:send("GET " .. GET .. " HTTP/1.1\r\n"
                     .. "Host: 192.168.42.1\r\n"
                     .. "Connection: keep-alive\r\nAccept: */*\r\n\r\n")
        end)
        tmr.stop(TMR_GET)
        tmr.start(3)
    end
end

config()

tmr.register(TMR_WIFI, 1000, tmr.ALARM_AUTO, function() connect() end)
tmr.start(TMR_WIFI)

tmr.register(TMR_GET, 1000, tmr.ALARM_AUTO, function() get() end)
tmr.start(TMR_GET)

tmr.register(3, 1000, tmr.ALARM_AUTO, function()
    print("Old GET : " .. GET)
    GET = "/connection"
    print("New GET : " .. GET)
    tmr.stop(3)
    tmr.start(TMR_GET)
end)

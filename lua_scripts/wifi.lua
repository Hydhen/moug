TMR_GAME    = 0
TMR_WIFI    = 1
TMR_GET     = 2
TMR_GAME_TEST = 3

SSID        = "MougPi"
PASSWORD    = "password"

GET         = "/connection"
RESPONSE    = ""

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
        tmr.start(TMR_GAME_TEST)
    end
end

function get()
    if tmr.state(TMR_WIFI) == false then
        print("== Create connection ==")
        conn = net.createConnection(net.TCP, 0)

        print("== Set receive callback ==")
        conn:on("receive", function(sck, data)
            GET_RESPONSE = data
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
--        tmr.stop(TMR_GET)
    end
end

config()

tmr.register(TMR_WIFI, 1000, tmr.ALARM_AUTO, function() connect() end)
tmr.start(TMR_WIFI)

--tmr.register(TMR_GET, 1000, tmr.ALARM_AUTO, function() get() end)
--tmr.start(TMR_GET)

function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

STEP = [
    "CONN",
    "PLAY",
    "SEND",
    "DISC"
]

ID_STEP = 1

tmr.register(TMR_GAME_TEST, 1000, tmr.ALARM_AUTO, function()
--    print("Old GET : " .. GET)
--    GET = "/connection"
--    print("New GET : " .. GET)
    if tmr.state(TMR_GAME_TEST) == true then
        if GET_RESPONSE == nil then
            print("GET_RESPONSE nil")
        else
            print('---')
            print(GET_RESPONSE)
            print('---')
            wordtab = mysplit(GET_RESPONSE, '\n')
            print('wordtab 1: '..wordtab[1])
            print('wordtab 6: '..wordtab[6])
        end
        if STEP[ID_STEP] == "CONN" then

    end
--    while GET_RESPONSE == "" do
--        print('waiting TMR_GET...')
--        tmr.delay(100)
--    end
--    print("--- RESPONSE ---")
--    print(response)
--    print("---  ---")
--    local junk, nugget = response.split("{")
--    print('nugget: ')
--    print(nugget)
--    nugget, junk = nugget.split("}")
--    print('nugget: ')
--    print(nugget)
--    tmr.stop(TMR_GAME_TEST)
--    tmr.start(TMR_GET)
end)

-- GLOBAL --
TMR_WIFI    = 1
TMR_MAIN    = 2
TMR_PLAY    = 3
TMR_GET     = 4
SSID        = "MougPi"
PASSWORD    = "password"
PROBED      = false
GET         = ""
RESPONSE    = ""
TEAM        = ""
SCORE       = 0
TIMER       = 0
STEP        = {
    "CONN",
    "TEAM",
    "SETT",
    "WAIT",
    "PLAY",
    "SEND",
    "DISC"
}
ID_STEP     = 1

-- UTILS --
function split(inputstr, sep)
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

-- WIFI --
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
        tmr.start(TMR_MAIN)
    end
end
function get()
    if tmr.state(TMR_WIFI) == false then
        conn = net.createConnection(net.TCP, 0)
        conn:on("receive", function(sck, data)
            RESPONSE = split(data, '\n')
            if STEP[ID_STEP] == "SETT" then
                print(data)
                tmr.delay(1000)
            end
            tmr.stop(TMR_GET)
            tmr.start(TMR_MAIN)
        end)
        conn:connect(80, "192.168.42.1")
        print('== GET ==')
        conn:on("connection", function(sck, data)
            sck:send("GET " .. GET .. " HTTP/1.1\r\n"
                     .. "Host: 192.168.42.1\r\n"
                     .. "Connection: keep-alive\r\nAccept: */*\r\n\r\n")
        end)
    end
end
tmr.register(TMR_GET, 500, tmr.ALARM_SEMI, function() get() end)

function play()
    if TIMER == 0 then
        SCORE = math.random() * 100
        SCORE = math.floor(SCORE)
        tmr.stop(TMR_PLAY)
        tmr.start(TMR_MAIN)
    else
        TIMER = TIMER - 1
        print(TIMER)
    end
end
tmr.register(TMR_PLAY, 1000, tmr.ALARM_AUTO, function() play() end)

-- MAIN THREAD --
config()
tmr.register(TMR_WIFI, 1000, tmr.ALARM_AUTO, function() connect() end)
tmr.start(TMR_WIFI)

function main()
    if tmr.state(TMR_WIFI) == false then
        print(STEP[ID_STEP]..' '..tostring(PROBED)..' '..tostring(TIMER))
        if STEP[ID_STEP] == "CONN" then
            if PROBED == false then
                GET = "/connection"
                PROBED = true
                tmr.stop(TMR_MAIN)
                tmr.start(TMR_GET)
            else
                PROBED = false
                ID_STEP = ID_STEP + 1
                print(RESPONSE[6])
            end

        if STEP[ID_STEP] == "TEAM" then
            if PROBED == false then
                GET = "/team"
                PROBED = true
                tmr.stop(TMR_MAIN)
                tmr.start(TMR_GET)
            else
                PROBED = false
                print(RESPONSE[6])
                if RESPONSE[6] == "BLUE" or RESPONSE[6] == "RED"
                    TEAM = RESPONSE[6]
                    ID_STEP = ID_STEP + 1
                end
            end

        elseif STEP[ID_STEP] == "SETT" then
            if PROBED == false then
                GET = "/settings"
                PROBED = true
                tmr.stop(TMR_MAIN)
                tmr.start(TMR_GET)
            else
                PROBED = false
                print(RESPONSE[6])
                if RESPONSE[6] != 0 then
                    ID_STEP = ID_STEP + 1
                    TIMER = RESPONSE[6] -- * 60
                end
            end

        elseif STEP[ID_STEP] == "WAIT" then
            if PROBED == false then
                GET = "/wait"
                PROBED = true
                tmr.stop(TMR_MAIN)
                tmr.start(TMR_GET)
            else
                PROBED = false
                print(RESPONSE[6])
                if RESPONSE[6] == "ok" then
                    ID_STEP = ID_STEP + 1
                end
            end

        elseif STEP[ID_STEP] == "PLAY" then
            print ('-----')
            print ('TEAM: '..TEAM)
            print ('SETT: '..tostring(TIMER))
            print ('-----')
            tmr.delay(1000)
            ID_STEP = ID_STEP + 1
            tmr.stop(TMR_MAIN)
            tmr.start(TMR_PLAY)

        elseif STEP[ID_STEP] == "SEND" then
            if PROBED == false then
                GET = "/score/"..SCORE
                PROBED = true
                tmr.stop(TMR_MAIN)
                tmr.start(TMR_GET)
            else
                PROBED = false
                ID_STEP = ID_STEP + 1
                print(RESPONSE[6])
            end

        elseif STEP[ID_STEP] == "DISC" then
            if PROBED == false then
                GET = "/disconnection"
                PROBED = true
                tmr.stop(TMR_MAIN)
                tmr.start(TMR_GET)
            else
                PROBED = false
                ID_STEP = 1
                print(RESPONSE[6])
            end
        end
    end
end
tmr.register(TMR_MAIN, 500, tmr.ALARM_AUTO, function() main() end)

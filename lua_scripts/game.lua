print("Initalisation")
bit = require("bit")
print(".")
i2c.setup(0, 2, 3, i2c.SLOW)
print(".")
gpio.mode(5, gpio.OUTPUT)
print(".")
pwm.setup(6, 100, 1023)
pwm.start(6)
print(".")
pwm.setup(7, 100, 1023)
pwm.start(7)
print(".")
function readRegister(address, reg)
    i2c.start(0)
    i2c.address(0, address, i2c.TRANSMITTER)
    i2c.write(0, reg)
    i2c.stop(0)
    i2c.start(0)
    i2c.address(0, address, i2c.RECEIVER)
    local all = i2c.read(0, 2)
    i2c.stop(0)
    local a = string.byte(all)
    if a == nil then
        a = 0
    end
    local b = string.byte(all, 2)
    if b == nil then
        b = 0
    end
    local ret = 0
    ret = bit.bor(ret, a)
    ret = bit.lshift(ret, 8)
    ret = bit.bor(ret, b)
    return ret
end
function writeRegister(address, reg, value)
    i2c.start(0)
    i2c.address(0, address, i2c.TRANSMITTER)
    i2c.write(0, reg)
    local high = 0
    high = bit.rshift(value, 8)
    i2c.write(0, high)
    local low = 0
    low = bit.band(0xFF)
    i2c.write(0, low)
    i2c.stop(0)
end
function readADC_SingleEnded(channel)
    if channel > 3 then
        return 0
    end
    local config = 0
    config = bit.bor(config, 0x0003)
    config = bit.bor(config, 0x0000)
    config = bit.bor(config, 0x0000)
    config = bit.bor(config, 0x0000)
    config = bit.bor(config, 0x0080)
    config = bit.bor(config, 0x0100)
    if channel == 0 then
        config = bit.bor(config, 0x4000)
    elseif channel == 1 then
        config = bit.bor(config, 0x5000)
    elseif channel == 2 then
        config = bit.bor(config, 0x6000)
    elseif channel == 3 then
        config = bit.bor(config, 0x7000)
    end
    config = bit.bor(config, 0x8000)
    writeRegister(0x48, 0x01, config)
    tmr.delay(8)
    local ret = readRegister(0x48, 0x00)
    return ret
end
function beep(pin, tone, duration)
    pwm.setup(pin, tone, 512)
    pwm.start(pin)
    tmr.delay(duration * 1000)
    pwm.stop(pin)
    tmr.wdclr()
    tmr.delay(20000)
end
function Init()
    beep(5, 880, 100)
    local a = readADC_SingleEnded(0)
    local b = readADC_SingleEnded(1)
    local c = readADC_SingleEnded(2)
    beep(5, 880, 100)
    print('a: '..a)
    print('b: '..b)
    print('c: '..c)
end
function accelerometer(a, b, c)
    local moved = false
    if (a > 10000) then
        moved = true
    elseif (b > 10000) then
        moved = true
    elseif (c > 10000) then
        moved = true
    end
    return moved
end
function melody()
    beep(5, 523, 100)
    beep(5, 659, 100)
    beep(5, 880, 100)
end
function Leds()
    if (BUTTERFLY >= 60) then
        pwm.setduty(6, 0)
    end
    if (BUTTERFLY < 60) then
        pwm.setduty(6, 255)
    end
    if (BUTTERFLY < 40) then
        pwm.setduty(6, 511)
    end
    if (BUTTERFLY < 20) then
        pwm.setduty(6, 767)
    end
    if (BUTTERFLY < 10) then
        pwm.setduty(6, 1023)
    end
end
LASTTIME = tmr.now()
print(".")
GAMETIME = tmr.time()
print(".")
BUTTERFLY = math.random() * 100
print("BT: "..BUTTERFLY)
print(".")
Init()
print(".")
print("READY")
pwm.setduty(7, 0)
PROBED      = false
GET         = ""
RESPONSE    = ""
TEAM        = ""
SCORE       = 0
TIMER       = 0
START_TIME  = 0
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
function config()
    wifi.setmode(wifi.STATION)
    wifi.sta.config("MougPi", "password", 1)
    print("Trying connection with :")
    print("SSID: " .. "MougPi")
    print("PASSWORD: " .. "password")
end
function connect()
    if wifi.sta.getip () == nil then
        print("Waiting for Wifi connection")
        beep(5, 880, 100)
    else
        print("ESP8266 mode is: " .. wifi.getmode ())
        print("The module MAC address is: " .. wifi.ap.getmac ())
        print("Config done, IP is " .. wifi.sta.getip ())
        beep(5, 880, 100)
        beep(5, 880, 100)
        beep(5, 880, 100)
        tmr.stop(1)
        tmr.start(2)
    end
end
function get()
    if tmr.state(1) == false then
        conn = net.createConnection(net.TCP, 0)
        conn:on("receive", function(sck, data)
            RESPONSE = split(data, '\n')
            tmr.stop(4)
            tmr.start(2)
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
tmr.register(4, 500, tmr.ALARM_SEMI, function() get() end)
function game()
    local time = tmr.now()
    local offset = time - START_TIME
    offset = (offset / 1000) / 1000
    if offset < tonumber(TIMER) then
        local a = readADC_SingleEnded(0)
        local b = readADC_SingleEnded(1)
        local c = readADC_SingleEnded(2)
        if (time - LASTTIME) > 1000000 then
            LASTTIME = time
            BUTTERFLY = math.random() * 100
        elseif time < LASTTIME then
            LASTTIME = 0
        end
        Leds()
        if (accelerometer(a, b, c)) then
            local catch = math.random() * 100
            catch = catch - 40
            if (catch > BUTTERFLY) then
                pwm.setduty(7, 1023)
                melody()
                LASTTIME = tmr.now()
                BUTTERFLY = math.random() * 100
                SCORE = SCORE + 1
                pwm.setduty(7, 0)
            end
        end
    else
        tmr.stop(3)
        tmr.start(2)
    end
end
tmr.register(3, 500, tmr.ALARM_AUTO, function() game() end)
config()
tmr.register(1, 1000, tmr.ALARM_AUTO, function() connect() end)
tmr.start(1)
ID_STEP     = 1
function main()
    local STEP = {
        "CONN",
        "TEAM",
        "SETT",
        "WAIT",
        "PLAY",
        "SEND",
        "DISC"
    }
    if tmr.state(1) == false then
        print(STEP[ID_STEP]..' '..tostring(PROBED)..' '..tostring(TIMER))
        if STEP[ID_STEP] == "CONN" then
            if PROBED == false then
                GET = "/connection"
                PROBED = true
                tmr.stop(2)
                tmr.start(4)
            else
                PROBED = false
                ID_STEP = ID_STEP + 1
                print(RESPONSE[6])
            end
        elseif STEP[ID_STEP] == "TEAM" then
            if PROBED == false then
                GET = "/team"
                PROBED = true
                tmr.stop(2)
                tmr.start(4)
            else
                PROBED = false
                print(RESPONSE[6])
                if RESPONSE[6] == "BLUE" or RESPONSE[6] == "RED" then
                    TEAM = RESPONSE[6]
                    ID_STEP = ID_STEP + 1
                end
            end
        elseif STEP[ID_STEP] == "SETT" then
            if PROBED == false then
                GET = "/settings"
                PROBED = true
                tmr.stop(2)
                tmr.start(4)
            else
                PROBED = false
                print(RESPONSE[6])
                if tonumber(RESPONSE[6]) > 0 then
                    ID_STEP = ID_STEP + 1
                    TIMER = RESPONSE[6] -- * 60
                end
            end
        elseif STEP[ID_STEP] == "WAIT" then
            if PROBED == false then
                GET = "/wait"
                PROBED = true
                tmr.stop(2)
                tmr.start(4)
            else
                PROBED = false
                print(RESPONSE[6])
                if RESPONSE[6] == "ok" then
                    ID_STEP = ID_STEP + 1
                end
            end
        elseif STEP[ID_STEP] == "PLAY" then
            ID_STEP = ID_STEP + 1
            START_TIME = tmr.now()
            tmr.stop(2)
            tmr.start(3)
        elseif STEP[ID_STEP] == "SEND" then
            if PROBED == false then
                GET = "/score/"..SCORE
                PROBED = true
                tmr.stop(2)
                tmr.start(4)
            else
                PROBED = false
                ID_STEP = ID_STEP + 1
                print(RESPONSE[6])
            end
        elseif STEP[ID_STEP] == "DISC" then
            if PROBED == false then
                GET = "/disconnection"
                PROBED = true
                tmr.stop(2)
                tmr.start(4)
            else
                PROBED = false
                ID_STEP = 1
                print(RESPONSE[6])
            end
        end
    end
end
tmr.register(2, 500, tmr.ALARM_AUTO, function() main() end)

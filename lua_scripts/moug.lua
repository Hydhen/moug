-- Global
print("Global")

-- Global variable for i2c
ADDR                                = 0x48
SDA                                 = 2
SCL                                 = 3
print(".")

-- Global variable for ADS1115
ADS1115_CONVERTIONDELAY             = 8
ADS1015_REG_POINTER_MASK            = 0x03
ADS1015_REG_POINTER_CONVERT         = 0x00
ADS1015_REG_POINTER_CONFIG          = 0x01
ADS1015_REG_POINTER_LOWTHRESH       = 0x02
ADS1015_REG_POINTER_HITHRESH        = 0x03
ADS1015_REG_CONFIG_MUX_SINGLE_0     = 0x4000
ADS1015_REG_CONFIG_MUX_SINGLE_1     = 0x5000
ADS1015_REG_CONFIG_MUX_SINGLE_2     = 0x6000
ADS1015_REG_CONFIG_MUX_SINGLE_3     = 0x7000
ADS1015_REG_CONFIG_OS_SINGLE        = 0x8000
ADS1015_REG_CONFIG_CQUE_NONE        = 0x0003
ADS1015_REG_CONFIG_CLAT_NONLAT      = 0x0000
ADS1015_REG_CONFIG_CPOL_ACTVLOW     = 0x0000
ADS1015_REG_CONFIG_CMODE_TRAD       = 0x0000
ADS1015_REG_CONFIG_DR_1600SPS       = 0x0080
ADS1015_REG_CONFIG_MODE_SINGLE      = 0x0100
print(".")

-- Global for buzzer
BUZZER                              = 5
TONES                               = {}
TONES["aS"]                         = 880
TONES["cS"]                         = 523
TONES["eS"]                         = 659
print(".")

-- Global LED
WHITE                               = 6
BLUE                                = 7
print(".")

-- Init
print("Initalisation")
bit = require("bit")
print(".")
i2c.setup(0, SDA, SCL, i2c.SLOW)
print(".")
gpio.mode(BUZZER, gpio.OUTPUT)
print(".")
pwm.setup(WHITE, 100, 1023)
pwm.start(WHITE)
print(".")
pwm.setup(BLUE, 100, 1023)
pwm.start(BLUE)
print(".")


-- Function
-- ADS1115
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
    config = bit.bor(config, ADS1015_REG_CONFIG_CQUE_NONE)
    config = bit.bor(config, ADS1015_REG_CONFIG_CLAT_NONLAT)
    config = bit.bor(config, ADS1015_REG_CONFIG_CPOL_ACTVLOW)
    config = bit.bor(config, ADS1015_REG_CONFIG_CMODE_TRAD)
    config = bit.bor(config, ADS1015_REG_CONFIG_DR_1600SPS)
    config = bit.bor(config, ADS1015_REG_CONFIG_MODE_SINGLE)
    if channel == 0 then
        config = bit.bor(config, ADS1015_REG_CONFIG_MUX_SINGLE_0)
    elseif channel == 1 then
        config = bit.bor(config, ADS1015_REG_CONFIG_MUX_SINGLE_1)
    elseif channel == 2 then
        config = bit.bor(config, ADS1015_REG_CONFIG_MUX_SINGLE_2)
    elseif channel == 3 then
        config = bit.bor(config, ADS1015_REG_CONFIG_MUX_SINGLE_3)
    end
    config = bit.bor(config, ADS1015_REG_CONFIG_OS_SINGLE)
    writeRegister(ADDR, ADS1015_REG_POINTER_CONFIG, config)
    tmr.delay(ADS1115_CONVERTIONDELAY)
    local ret = readRegister(ADDR, ADS1015_REG_POINTER_CONVERT)
    return ret
end
-- Buzzer
function beep(pin, tone, duration)
    local freq = TONES[tone]
    pwm.setup(pin, freq, 512)
    pwm.start(pin)
    -- delay in uSeconds
    tmr.delay(duration * 1000)
    pwm.stop(pin)
    --20ms pause
    tmr.wdclr()
    tmr.delay(20000)
end

-- Init
function Init()
    beep(BUZZER, "aS", 100)
    local a = readADC_SingleEnded(0)
    local b = readADC_SingleEnded(1)
    local c = readADC_SingleEnded(2)
    beep(BUZZER, "aS", 100)
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
    beep(BUZZER, "cS", 100)
    beep(BUZZER, "eS", 100)
    beep(BUZZER, "aS", 100)
end

function Leds()
    if (BUTTERFLY >= 60) then
        pwm.setduty(WHITE, 0)
    end
    if (BUTTERFLY < 60) then
        pwm.setduty(WHITE, 255)
    end
    if (BUTTERFLY < 40) then
        pwm.setduty(WHITE, 511)
    end
    if (BUTTERFLY < 20) then
        pwm.setduty(WHITE, 767)
    end
    if (BUTTERFLY < 10) then
        pwm.setduty(WHITE, 1023)
    end
end

-- Game
function Game()
    local a = readADC_SingleEnded(0)
    local b = readADC_SingleEnded(1)
    local c = readADC_SingleEnded(2)
    local time = tmr.now()
    if (time - LASTTIME) > 1000000 then
        LASTTIME = time
        BUTTERFLY = math.random() * 100
--        print("BT: "..BUTTERFLY)
    elseif time < LASTTIME then
        LASTTIME = 0
    end
    Leds()
    if (accelerometer(a, b, c)) then
        local catch = math.random() * 100
        catch = catch - 40
        if (catch > BUTTERFLY) then
--            print("BUTTERFLY CATCHED")
            pwm.setduty(BLUE, 1023)
            melody()
            LASTTIME = tmr.now()
            BUTTERFLY = math.random() * 100
--            print("BT: "..BUTTERFLY)
            tmr.delay(2000000)
            pwm.setduty(BLUE, 0)
        end
    end
    if (a > MAXX) then
        MAXX = a
--        print('NEW MAX X: '..a)
    end
    if (b > MAXY) then
        MAXY = b
--        print('NEW MAX Y: '..b)
    end
    if (c > MAXZ) then
        MAXZ = c
--        print('NEW MAX Z: '..c)
    end
    if (a < MINX) then
        MINX = a
--        print('NEW MIN X: '..a)
    end
    if (b < MINY) then
        MINY = b
--        print('NEW MIN Y: '..b)
    end
    if (c < MINZ) then
        MINZ = c
--        print('NEW MIN Z: '..c)
    end
end

MAXX = 0
MAXY = 0
MAXZ = 0
MINX = 0
MINY = 0
MINZ = 0

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
pwm.setduty(BLUE, 0)
tmr.alarm(0, 500, 1, function() Game() end )

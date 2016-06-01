BUTTON      = 8

function buttonState()
    print("State: " .. gpio.read(BUTTON))
end

gpio.mode(BUTTON, gpio.INPUT)

tmr.alarm(1, 500, tmr.ALARM_AUTO, function() buttonState() end)

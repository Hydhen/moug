WHITE = 6
WHITE2 = 7

function blink()
    pwm.setup(WHITE, 100, 1023)
    pwm.setup(WHITE2, 100, 1023)

    print("FULL LIGHT")
    pwm.start(WHITE)
    pwm.start(WHITE2)
    tmr.delay(1000 * 1000)

    print("THIRD QUARTER LIGHT")
    pwm.setduty(WHITE, 767)
    pwm.setduty(WHITE2, 767)
    tmr.delay(1000 * 1000)

    print("HALF LIGHT")
    pwm.setduty(WHITE, 511)
    pwm.setduty(WHITE2, 511)
    tmr.delay(1000 * 1000)

    print("QUARTER LIGHT")
    pwm.setduty(WHITE, 255)
    pwm.setduty(WHITE2, 255)
    tmr.delay(1000 * 1000)

    print("NO LIGHT")
    pwm.setduty(WHITE, 0)
    pwm.setduty(WHITE2, 0)
    tmr.delay(1000 * 1000)

    pwm.stop(WHITE)
    pwm.stop(WHITE2)
end

blink()

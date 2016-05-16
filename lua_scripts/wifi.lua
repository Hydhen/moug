SSID        = "MougPi"
PASSWORD    = "password"

CONFIG      = {
                ip="192.168.2.3",
                netmask="255.255.255.0",
                gateway="192.168.2.1"
              }

--wifi.setmode(wifi.STATION)
--wifi.sta.config(SSID, PASSWORD)
--print(wifi.sta.getip())

function connect()
    wifi.setmode(wifi.STATION)
--    wifi.ap.setip(CONFIG)
    wifi.sta.config(SSID, PASSWORD, 1)
    print("Trying connection with :")
    print("SSID: " .. SSID)
    print("PASSWORD: " .. PASSWORD)
    wait_for_wifi_conn()
end

function wait_for_wifi_conn()
    tmr.alarm (1, 1000, 1, function()
        if wifi.sta.getip () == nil then
            print("Waiting for Wifi connection")
        else
            tmr.stop (1)
            print("ESP8266 mode is: " .. wifi.getmode ())
            print("The module MAC address is: " .. wifi.ap.getmac ())
            print("Config done, IP is " .. wifi.sta.getip ())
        end
    end)
end

connect()

import network
import socket
import time



from machine import Pin, PWM

right_motor_2 = Pin(15, Pin.OUT) 
right_motor_1 = Pin(14, Pin.OUT) 
left_motor_2 = Pin(11, Pin.OUT) 
left_motor_1 = Pin(12, Pin.OUT)

led = machine.Pin("LED", machine.Pin.OUT)



def backwards():
    print("back")
    right_motor_1.low()
    right_motor_2.high()
   
    left_motor_1.low()
    left_motor_2.high()

    
def forwards():
    print("forward")

    right_motor_1.high()
    right_motor_2.low()
    left_motor_1.high()
    left_motor_2.low()


    
def left():
    print("left")
    right_motor_1.high()
    right_motor_2.low()
    left_motor_1.low()
    left_motor_2.low()
    
    
def right():
    print("right")
    right_motor_1.low()
    right_motor_2.low()
    left_motor_1.high()
    left_motor_2.low()
    
def stop():
    left_motor_1.low()
    left_motor_2.low()
    right_motor_1.low()
    right_motor_2.low()



def action():
    print("action")
    left_motor_1.high()
    left_motor_2.low()
    right_motor_1.low()
    right_motor_2.high()
    #action_pin.low()
    

ssid = 'dlink-CD63'
password = 'gyhbp38833'

wlan = network.WLAN(network.STA_IF)
wlan.active(True)
wlan.connect(ssid, password)

html = """<!DOCTYPE html>
<html>
    <head> <title>Pico W</title> </head>
    <body> <h1>Pico W</h1>
        <p>%s</p>
    </body>
</html>
"""
led_on = False

max_wait = 10
while max_wait > 0:
    if wlan.status() < 0 or wlan.status() >= 3:
        break
    max_wait -= 1
    print('waiting for connection...')
    time.sleep(1)


if wlan.status() != 3:
    raise RuntimeError('network connection failed')
else:
    print('connected')
    status = wlan.ifconfig()
    print( 'ip = ' + status[0] )

addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]

s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(addr)
s.listen(1)

print('listening on', addr)

# Listen for connections
led.on()
while True:
    try:
        if led_on == False:
            led.on()
            led_on = True
        else:
            led.off()
            led_on = False
        cl, addr = s.accept()
        print('client connected from', addr)
        request = cl.recv(1024)
        print(request)

        request = str(request)
        
        if "forward" in request:
            print("forward")
            forwards()
        elif "backward" in request:
            print("backward")
            backwards()
        elif "left" in request:
            print("left")
            left()
        elif "right" in request:
            print("right")
            right()
        elif "stop" in request:
            print("stop")
            stop()
        elif "action" in request:
            print("action")
            action()
        else:
            print("stop")
            stop()

        print(request)

        response = html #% stateis

        cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
        cl.send(response)
        cl.close()
        

    except OSError as e:
        cl.close()
        print('connection closed')
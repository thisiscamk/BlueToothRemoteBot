# Import necessary modules
from machine import Pin, PWM
import bluetooth
from ble_simple_peripheral import BLESimplePeripheral



right_motor_1 = PWM(Pin(9, mode=Pin.OUT))
right_motor_2 = PWM(Pin(10, mode=Pin.OUT))
left_motor_1 = PWM(Pin(12, mode=Pin.OUT))
left_motor_2 = PWM(Pin(11, mode=Pin.OUT))
frequency = 20000
right_motor_1.freq(frequency)
right_motor_2.freq(frequency)
left_motor_1.freq(frequency)
left_motor_2.freq(frequency)

left_right_value = 0
forward_back_value = 0

MAX_DUTY_CYCLE = 65535
MIN_DUTY_CYCLE = 40000

    
led = machine.Pin("LED", machine.Pin.OUT)

def update_lr_value(new_value):
    global left_right_value
    left_right_value = new_value
    change_speed()
    
def update_fb_value(new_value):
    global forward_back_value
    forward_back_value = -1*new_value
    change_speed()

def change_speed():
    print(forward_back_value, left_right_value)
    left_wheels = forward_back_value + (left_right_value/2)
    if left_wheels > 100:
        left_wheels = 100
    if left_wheels < -100:
        left_wheels = -100
    right_wheels = forward_back_value - (left_right_value/2)
    if right_wheels > 100:
        right_wheels = 100
    if right_wheels < -100:
        right_wheels = -100
    
    left_motor_1_duty = 0
    left_motor_2_duty = 0
    right_motor_1_duty = 0
    right_motor_2_duty = 0
    
    if left_wheels > 0:
        left_motor_1_duty = int((left_wheels/100*(MAX_DUTY_CYCLE - MIN_DUTY_CYCLE)+ MIN_DUTY_CYCLE))
        left_motor_2_duty = 0

    elif left_wheels < 0:
        left_motor_1_duty = 0
        left_motor_2_duty = int((-1*left_wheels/100*(MAX_DUTY_CYCLE - MIN_DUTY_CYCLE)+ MIN_DUTY_CYCLE))
        
    if right_wheels > 0:
        right_motor_1_duty = int((right_wheels/100*(MAX_DUTY_CYCLE - MIN_DUTY_CYCLE)+ MIN_DUTY_CYCLE))
        right_motor_2_duty = 0

    elif right_wheels < 0:

        right_motor_1_duty = 0
        right_motor_2_duty = int((-1*right_wheels/100*(MAX_DUTY_CYCLE - MIN_DUTY_CYCLE)+ MIN_DUTY_CYCLE))

    print(left_motor_1_duty, left_motor_2_duty, right_motor_1_duty, right_motor_2_duty)
    
    left_motor_1.duty_u16(left_motor_1_duty)
    left_motor_2.duty_u16(left_motor_2_duty)
    right_motor_1.duty_u16(right_motor_1_duty)
    right_motor_2.duty_u16(right_motor_2_duty)

    


# Create a Bluetooth Low Energy (BLE) object
ble = bluetooth.BLE()

# Create an instance of the BLESimplePeripheral class with the BLE object
sp = BLESimplePeripheral(ble)

# Create a Pin object for the onboard LED, configure it as an output
#led = Pin("LED", Pin.OUT)

# Initialize the LED state to 0 (off)
#led_state = 0

# Define a callback function to handle received data
def on_rx(data, direction):
    #print("Data received: ", data, characteristic)  # Print the received data
    #global led_state  # Access the global variable led_state
    data_int = int.from_bytes(data, "big") - 100
    if direction == "LR":
        #print("Left/right: ", data_int)
        update_lr_value(data_int)
    elif direction == "FB":
        #print("Forward/back", data_int)
        update_fb_value(data_int)


# Start an infinite loop
while True:
    if sp.is_connected():  # Check if a BLE connection is established
        sp.on_write(on_rx)  # Set the callback function for data reception
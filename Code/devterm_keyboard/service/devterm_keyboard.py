import serial
from os import system
from time import sleep

def notify_send(s):
    system(f'/usr/local/bin/root-notify-send "{s}"')

def handle_gear(line):
    try:
        g = int(line[1])
        g = max(g, 1)
        g = min(g, 6)
        system(f'/usr/bin/gearbox-clockworkpi-a06 -s {g}')
        notify_send(f'Gear = {g}')
    except:
        pass

def handle_joystick(line):
    try:
        notify_send(f'Joystick = {line[1]}')
    except:
        pass

def handle_powersave(line):
    try:
        notify_send(f'KBD PowerSave = {line[1]}')
    except:
        pass

def handle_selector(line):
    try:
        notify_send(f'Selector = {line[1]}')
    except:
        pass

def main_loop():
    ser = serial.Serial('/dev/ttyACM0')
    while True:
        line = ser.readline().decode('utf-8').split()
        if len(line) < 1:
            continue
        cmd = line[0]
        if cmd == 'gear':
            handle_gear(line)
        if cmd == 'joystick':
            handle_joystick(line)
        if cmd == 'powersave':
            handle_powersave(line)
        if cmd == 'mode':
            handle_selector(line)

if __name__ == "__main__":
    while True:
        try:
            main_loop();
        except:
            sleep(5)
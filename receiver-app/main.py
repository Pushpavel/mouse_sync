import socket

import mouse

s = socket.socket()
s.bind(('', 15000))
s.listen(5)
print("socket is listening")

c, addr = s.accept()
print("connected")

# calculate screen size
mouse.move(10000, 10000, absolute=True, duration=0)
size = mouse.get_position()

while True:
    m = c.recv(1024).decode()
    p = [float(x) for x in m.split(',')]

    print("updating cursor")
    # move mouse to p position
    mouse.move(p[0] * size[0], p[1] * size[1], absolute=True, duration=0.2)

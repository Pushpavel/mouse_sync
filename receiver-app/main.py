import socket
import pyautogui as pag
import asyncio

sensitivity = 5
SERVER_PORT = 15555
DISCOVERY_PORT = 5001

pag.FAILSAFE = False
pag.PAUSE = 0


async def advertise():
    print("setting up advertisement")
    udp_socket = socket.socket(type=socket.SOCK_DGRAM)
    udp_socket.bind(('0.0.0.0', 0))

    # broadcast to the LAN
    while True:
        print("advertising...")
        udp_socket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        udp_socket.sendto(b'Hello', ('<broadcast>', DISCOVERY_PORT))
        await asyncio.sleep(5)


async def handle_client(reader, _):
    print("connected to client")
    while True:
        m = (await reader.readline()).decode('utf8')
        event = [x for x in m.split(';')]
        event[0] = event[0].strip()
        if event[0] == 'click':
            print("click")
            pag.leftClick()
        elif event[0] == 'rightclick':
            print("right-click")
            pag.rightClick()
        elif event[0] == 'move':
            print("move")
            p = [float(x) for x in event[1].split(',')]
            pag.moveRel(p[0] * sensitivity, p[1] * sensitivity)


async def run_server():
    # listen at the server port in all network interfaces
    server = await asyncio.start_server(handle_client, '0.0.0.0', SERVER_PORT)
    print("accepting clients")
    async with server:
        await server.serve_forever()


# run advertise and server in background
loop = asyncio.get_event_loop()
loop.create_task(advertise())
loop.create_task(run_server())
loop.run_forever()

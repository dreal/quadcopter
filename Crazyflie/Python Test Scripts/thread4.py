import time
import threading
run = True

def foo():
    while run:
        print '.',
        time.sleep(0)

t1 = threading.Thread(target=foo)
t1.start()
time.sleep(2)
run = False
print 'run=False'
while True:
    pass

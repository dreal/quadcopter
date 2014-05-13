import threading
lock = threading.Lock()
x = 0
def foo():
   global x
   for i in xrange(1000000):
        with lock:    # Uncomment this to get the right answer
            x += 1
threads = [threading.Thread(target=foo), threading.Thread(target=foo)]
for t in threads:
    t.daemon = True    
    t.start()
for t in threads:
    t.join()

print(x)

import ctypes
lib = ctypes.cdll.LoadLibrary("../libmath.so")
print "Call Go math.add(1,2) is %d" % lib.add(1,2)

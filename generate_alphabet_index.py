res = []
base = 0

for i in range(0,37):
    if (i%2==0):
        res.append(base)
    else:
        res.append(base+1)
        base += 8

str = "dc.b "
for v in res:
    str += "{:02X}".format(v)+","
print(str)
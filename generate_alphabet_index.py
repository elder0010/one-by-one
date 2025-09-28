res = []
base = 0

tk = 0
for i in range(0,37):
   
    res.append(base)
    
    res.append(base+1)


    base += 8
  

strx = "dc.b "
for v in res:
    strx += str(v) + ","
print(strx)
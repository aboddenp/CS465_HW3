xs = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]

count = 0
start = 0 
lcomplete = 0 
for i in range(len(xs)*5 ):
    for j in range(start,count+start):
            if(xs[j] < 4):
                xs[j] += 1
            if(xs[j] == 4): 
                lcomplete = j + 1
    start = lcomplete  
    if(start == len(xs)-1): 
        break
    if(count + start >= len(xs)):
             count = 0
    else:
         count += 1
    print(xs)
import random
n = 20  #images per person
c = 4   #n in n-cross validation
d = n / c
f = open("files")
x = f.read().split('\n')
g = [ x[i*n:(i+1)*n] for i in range(len(x)/n) ]
f1 = open("files_1", "w")
f2 = open("files_2", "w")
f3 = open("files_3", "w")
f4 = open("files_4", "w")
l1 = open("Labels_1", "w")
l2 = open("Labels_2", "w")
l3 = open("Labels_3", "w")
l4 = open("Labels_4", "w")
for i in range(len(g)):
    random.shuffle(g[i])
    partition = g[i]
    for j in range(n):
        image = partition[j]
        if j%c == 0:
            f1.write(image.split()[0]+'\n')
            l1.write((image.split()[1]).split('B')[1]+'\n')
        if j%c == 1:
            f2.write(image.split()[0]+'\n')
            l2.write((image.split()[1]).split('B')[1]+'\n')
        if j%c == 2:
            f3.write(image.split()[0]+'\n')
            l3.write((image.split()[1]).split('B')[1]+'\n')
        if j%c == 3:
            f4.write(image.split()[0]+'\n')
            l4.write((image.split()[1]).split('B')[1]+'\n')
f.close()
f1.close()
f2.close()
f3.close()
f4.close()
l1.close()
l2.close()
l3.close()
l4.close()

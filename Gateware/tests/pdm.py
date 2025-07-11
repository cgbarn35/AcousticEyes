import numpy as np 
import re


def ds2(x,A,B,ffA=0,ffB=0,ffC=0,R=1):
    n = len(x)
    y = np.zeros(n)
    accum1 = 0;
    accum2 = 0;
    y_o = 0;
    for i in range(n):
        accum1+= R*(x[i] - A * y_o)
        accum2+= R*(accum1 + x[i]*ffA - B*y_o)
        q_in = accum2 + x[i]*ffB + accum1*ffC
        y_o = 1 if q_in >= R*B else 0
        y[i] = y_o 
    return y

def pdm(x):
    n = len(x)
    y = np.zeros(n)
    error = np.zeros(n+1)
    for i in range(n):

        y[i] = 1 if x[i] >= error[i] else 0 
        error[i+1] = y[i] - x[i] + error[i] 
    return y

n = 10000;
fclk = 3125000
t = np.arange(n) / fclk 

with open('pdm.dat','wb') as f:
    for f_sin in range(1000, 21000, 1000):
        x = 0.5 + 0.5 * np.sin(2*np.pi*f_sin*t)
        #y = pdm(x) 
        y = ds2(x,1,1.4)
        f.write(int(''.join(map(lambda x:str(int(x)),y)),2).to_bytes(n//8,'big'))

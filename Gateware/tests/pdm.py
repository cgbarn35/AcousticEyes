import numpy as np 
import matplotlib.pyplot as plt
import re

def pdm(x):
    n = len(x)
    y = np.zeros(n)
    error = np.zeros(n+1)
    for i in range(n):
        y[i] = 1 if x[i] >= error[i] else 0 
        error[i+1] = y[i] - x[i] + error[i] 
    return y, error[0:n]

n = 3000
fclk = 3.125e7 
t = np.arange(n) / fclk 
f_sin = 15000; #2khz


x = 0.5 + 0.5 * np.sin(2*np.pi*f_sin*t)
y, error = pdm(x) 

print("date out "+''.join(map(lambda x:str(int(x)),y)))
#print(int(''.join(map(lambda x:str(int(x)),y)),2).to_bytes(n//8,'little'))
with open('pdm.dat','wb') as f:
    f.write(int(''.join(map(lambda x:str(int(x)),y)),2).to_bytes(n//8,'big'))

#plt.plot(1e9*t, x, label='input signal')
#plt.step(1e9*t, y, label='pdm signal',  linewidth=2.0)
#plt.step(1e9*t, error, label='error')
#plt.xlabel('Time (ns)')
#plt.ylim(-0.05,1.05)
#plt.legend()
#plt.show()


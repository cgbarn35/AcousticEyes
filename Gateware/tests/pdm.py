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



n = 10000;
fclk = 3.125e7 
t = np.arange(n) / fclk 

with open('pdm.dat','wb') as f:
    for f_sin in range(1000, 21000, 1000):
        x = 0.5 + 0.5 * np.sin(2*np.pi*f_sin*t)
        y, error = pdm(x) 
        f.write(int(''.join(map(lambda x:str(int(x)),y)),2).to_bytes(n//8,'little'))

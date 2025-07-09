import io
import numpy as np 
import matplotlib.pyplot as plt
import csv


#TRASH CODE, WILL REFACTOR EVENTUALLY, CAN DO SMALL VISUALIZATION

with open('pdm.csv', 'r') as f:
    reader = csv.reader(f)
    data = list(reader)
    t = np.asarray([float(row[0]) for row in data], dtype=float)
    y = np.asarray([float(row[1]) for row in data], dtype=float)
    y2= np.asarray([float(row[2]) for row in data], dtype=float)

n = 10000;
fclk = 3.125e7
torig = np.arange(n) / fclk
f_sin = 16000
x = 0.5 + 0.5 * np.sin(2*np.pi*f_sin*torig);
plt.plot(torig*1e4, x, label='16khz input signal')

plt.step(t*1e-4, y/2**11, label='cic signal',  linewidth=2.0)
plt.step(t*1e-4, y2/2**34, label='halfband signal',  linewidth=2.0)
plt.xlabel('Time (ms)')
plt.ylim(-0.05,1.05)
plt.legend()
plt.show()

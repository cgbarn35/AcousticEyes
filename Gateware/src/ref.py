import io
import numpy as np 
import matplotlib.pyplot as plt
import csv
import math
import bitarray


#TRASH CODE, WILL REFACTOR EVENTUALLY, CAN DO SMALL VISUALIZATION

sample_rate = 3125000
decimation_factor = 16
N = 4
integrator_outputs = [0] * N
integrator_delays = [0] * N
combs = [0] * (N+1);
comb_delays = [0] * N
sample_num = 0

integrator_bits = 26
def wrap(x):
    return x % (2**integrator_bits)

def process_sample_cic(x):
    integrator_outputs[0] = wrap(integrator_outputs[0] + x)
    for i in range(1,N):
        integrator_outputs[i] = wrap(integrator_outputs[i-1] + integrator_outputs[i])
    if sample_num % decimation_factor == 0:
        combs[0] = integrator_outputs[N-1]
        for i in range(1, N+1):
            combs[i] = wrap(combs[i-1] - comb_delays[i-1])
            comb_delays[i-1] = combs[i-1]
        return combs[N]
    return None


def pull_pdm(n):
    with open('pdm.dat','rb') as f:
        byteCount = 10000//8
        f.seek(n*byteCount)#magic number, 1250 is 10000 bits
        data = f.read(byteCount)
    ba = bitarray.bitarray()
    ba.frombytes(data)
    return ba
        

def pull_cic():
    with open('pdm.csv', 'r') as f:
        reader = csv.reader(f)
        data = list(reader)
        t_v = np.asarray([float(row[0]) for row in data], dtype=float)
        y = np.asarray([float(row[1]) for row in data], dtype=float)
        y2= np.asarray([float(row[2]) for row in data], dtype=float)
    return t_v,y,y2

t_v,y,y2 = pull_cic()
pdm = pull_pdm(1)

t = 0;
f_sin = 2000

sin = []
cic = []
while sample_num < 3000:
    c = process_sample_cic(pdm[sample_num])
    if c:
        cic.append(c / 2**16)
        sin.append(math.sin(2*np.pi*f_sin*t) * 0.5 + 0.5)
    elif c == 0:
        cic.append(0)
        sin.append(math.sin(2*np.pi*f_sin*t) * 0.5 + 0.5)
    sample_num += 1
    t += 1.0 / sample_rate 



    
ts = [t / sample_rate * decimation_factor * 1000 for t in range(len(sin))] 
plt.plot(ts, sin, label='Python Input')
plt.step(ts, cic, label='python CIC')
plt.step(t_v*1e-4, y/2**15, label='Verilog CIC',  linewidth=2.0)
#plt.plot(t_v*1e-4, y2/2**38, label='Verilog HB1',  linewidth=2.0)
plt.xlabel('Time (ms)')
plt.ylim(-0.05,1.05)
plt.legend()
plt.show()

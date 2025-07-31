import io 
import numpy as np 
import csv 
import math 
import bitarray
import wave 
import struct



with open('music.csv', 'r') as f:
    reader = csv.reader(f)
    data = list(reader)
    t = np.asarray([float(row[0]) for row in data], dtype=float)
    x = np.asarray([float(row[1]) for row in data], dtype=float)
    print(len(x))

fir_sample = 48000
with wave.open('fir.wav','w') as w:
    w.setnchannels(1) 
    w.setsampwidth(2) #16 bits
    w.setframerate(fir_sample)
    for sample in x:
        w.writeframes(struct.pack('<h', int(sample)-32768)) #magic number for half of 16 bits



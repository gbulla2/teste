#!/usr/bin/env python3
import sys
import numpy as np

f_mhz = float(sys.argv[1])
path = sys.argv[2] if len(sys.argv) > 2 else 'port_ez.txt'
z=[]; e=[]
for line in open(path):
    p=line.split()
    if len(p) < 10:
        continue
    z.append(float(p[4]))
    e.append(float(p[-2]) + 1j*float(p[-1]))
z=np.asarray(z); e=np.asarray(e)
o=np.argsort(z); z=z[o]; e=e[o]
V=-np.trapezoid(e,z)
Z=V  # impressed current is exactly 1 A
S=(Z-50.0)/(Z+50.0)
s11=20*np.log10(abs(S)+1e-30)
print(f'{f_mhz/1000:.6f},{Z.real:.12g},{Z.imag:.12g},{s11:.12g}')

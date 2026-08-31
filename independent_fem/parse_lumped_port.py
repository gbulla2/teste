#!/usr/bin/env python3
import sys, math

f_mhz=float(sys.argv[1])
path=sys.argv[2] if len(sys.argv)>2 else 'port_I.txt'
I=None
for line in open(path):
    p=line.split()
    if len(p)>=3 and p[0]=='3000':
        I=complex(float(p[1]),float(p[2]))
        break
if I is None:
    raise RuntimeError('Port current row for region 3000 not found')
# Port voltage coefficient is -1 because the edge orientation is ground->patch;
# the physical terminal voltage V_patch-V_ground is +1 V.  Current orientation
# is chosen so that positive real input power corresponds to Re(Z)>=0.
Z=1.0/I
if Z.real < 0:
    I=-I
    Z=1.0/I
S=(Z-50.0)/(Z+50.0)
print(f'{f_mhz/1000:.6f},{I.real:.12g},{I.imag:.12g},{Z.real:.12g},{Z.imag:.12g},{abs(Z):.12g},{20*math.log10(abs(S)+1e-30):.12g}')

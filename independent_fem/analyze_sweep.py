#!/usr/bin/env python3
import csv
rows=[]
with open('../results/getdp_sweep.csv') as f:
    for r in csv.DictReader(f):
        rows.append({k:float(v) for k,v in r.items()})
best=min(rows,key=lambda r:r['S11_dB'])
near207=min(rows,key=lambda r:abs(r['f_GHz']-2.07))
near242=min(rows,key=lambda r:abs(r['f_GHz']-2.421))
with open('../results/getdp_summary.txt','w') as f:
    f.write('best='+repr(best)+'\n')
    f.write('near_2p07='+repr(near207)+'\n')
    f.write('near_2p421='+repr(near242)+'\n')
print('best',best)
print('near 2.07',near207)
print('near 2.421',near242)

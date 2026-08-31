#!/usr/bin/env python3
import csv
rows=[]
with open('../results/getdp_lumped_sweep.csv') as f:
    for r in csv.DictReader(f):
        rows.append({k:float(v) for k,v in r.items()})
if not rows:
    raise RuntimeError('Empty sweep')
best=min(rows,key=lambda r:r['S11_dB'])
near207=min(rows,key=lambda r:abs(r['f_GHz']-2.07))
near242=min(rows,key=lambda r:abs(r['f_GHz']-2.421))
# Local minima on sampled grid
mins=[]
for i in range(1,len(rows)-1):
    if rows[i]['S11_dB'] < rows[i-1]['S11_dB'] and rows[i]['S11_dB'] < rows[i+1]['S11_dB']:
        mins.append(rows[i])
mins=sorted(mins,key=lambda r:r['S11_dB'])
with open('../results/getdp_lumped_summary.txt','w') as f:
    f.write('best='+repr(best)+'\n')
    f.write('near_2p07='+repr(near207)+'\n')
    f.write('near_2p421='+repr(near242)+'\n')
    f.write('local_minima='+repr(mins[:8])+'\n')
print('best',best)
print('near 2.07',near207)
print('near 2.421',near242)
print('local minima',mins[:8])

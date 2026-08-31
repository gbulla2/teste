#!/usr/bin/env python3
import csv
rows=list(csv.DictReader(open('../results/getdp_lumped_refined.csv')))
best=min(rows,key=lambda r:float(r['S11_dB']))
with open('../results/getdp_lumped_refined_summary.txt','w') as f:
    f.write('refined_best='+repr({k:float(v) for k,v in best.items()})+'\n')
print('refined_best',best)

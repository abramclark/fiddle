// Q version
find_pairs:{[l;t]
    fp_unused::(0#0)!(0#0);
    sum 0,{[t;x] v:t - x; $[ (v in key fp_unused) & fp_unused[v] >= 1;
        [fp_unused[v] -: 1; 1]; [fp_unused[x] +: 1; 0]] }[t]
    each l }
tests:((();0;0);(enlist 0;0;0);((-10 -30 50 100 20 0);20;2);((20 20 20 20 20);40;2))

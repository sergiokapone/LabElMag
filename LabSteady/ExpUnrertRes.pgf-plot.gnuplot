set table "ExpUnrertRes.pgf-plot.table"; set format "%.5f"
set format "%.7e";; f(x) = A*x + B; fit f(x) "ExpUnrertRes.dat"u 1:2 via A,B; plot [x=1:2.3] f(x); 

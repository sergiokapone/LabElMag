set table "LabCoulombsLaw.pgf-plot.table"; set format "%.5f"
set format "%.7e";; f(x) = k/4*x**(1+e/2) + C; k=2.8e+9; e=2e-2; C = -0.1e12 ; fit f(x) "A.dat"u (1/$1**2):2 via k,C; plot [x=150:650] f(x); 

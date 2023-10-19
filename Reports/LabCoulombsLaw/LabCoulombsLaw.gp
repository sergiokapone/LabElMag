f(x) = A*x**(1 + s/2);  # Define the function to fit
A=1e+12; s = 1e-4 ;     # Set reasonable starting values here
fit f(x) "QF.dat" using ($7**2):8 via A,B; 
plot  [x=0:6.5e-16] f(x), "QF.dat" u ($7**2):8;
set print "fit_parameters.txt"
print A,A_err,s
set print
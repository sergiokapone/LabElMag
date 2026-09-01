python field_lines_generator.py --q 1 1 --distance 3 --bounds -6 6 -5 5 --n-lines 20 --n-equi 8 --equi-range 1 80 --output like.tex --caption "Два однакові точкові заряди"

python field_lines_generator.py --q 1 -1 --distance 3 --bounds -6 6 -5 5 --n-lines 20 --n-equi 8 --equi-range 1 80 --output opposite.tex --caption "Два різнойменні точкові заряди"

python field_lines_generator.py --q 1 --plane --height 5 --bounds -10 10 -5 5 --n-lines 20 --n-equi 8 --equi-range 1 80 --output plane.tex --label fig:plane --caption "Заряд над заземленою площиною"

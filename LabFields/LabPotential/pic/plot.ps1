# 1) Два однакові заряди (відштовхування) — класична картинка для лабораторної
python field_lines_generator.py --q 1 1 --distance 3 --output q_q.tex --label fig:like --caption "Два однакові точкові заряди"

# 2) Диполь (заряди різного знаку) — притягання
python field_lines_generator.py --q 1 -1 --distance 3 --output dipole.tex --label fig:dipole --caption "Електричний диполь"

# 3) Один заряд сам по собі (радіальне поле)
python field_lines_generator.py --q 1 --output single.tex --label fig:single --caption "Поле одиночного точкового заряду"

# 4) Заряд над заземленою провідною площиною (метод зображень)
python field_lines_generator.py --q 1 --plane --height 2 --output charge_plane.tex --label fig:plane --caption "Заряд над заземленою площиною"

# 5) Два різнойменні заряди над площиною
python field_lines_generator.py --q 1 -1 --distance 3 --plane --height 2.5 --output dipole_plane.tex --label fig:dipole_plane --caption "Диполь над заземленою площиною"

# 6) Заряди різної величини (несиметричний диполь)
python field_lines_generator.py --charges 2,-2,0 -1,2,0 --output asym.tex --label fig:asym --caption "Заряди різної величини"

# 7) Три заряди довільно розташовані (трикутник)
python field_lines_generator.py --charges 1,-2,0 1,2,0 -1,0,2.5 --output triangle.tex --label fig:triangle --caption "Система трьох зарядів"

# 8) Квадруполь (4 заряди по кутах квадрата, знаки чергуються)
python field_lines_generator.py --charges 1,-1.5,1.5 -1,1.5,1.5 1,1.5,-1.5 -1,-1.5,-1.5 --output quad.tex --label fig:quad --caption "Квадруполь"

# 9) Ручний контроль області малювання + густіші лінії/еквіпотенціалі
python field_lines_generator.py --q 1 -1 --distance 3 --bounds -6 6 -5 5 --n-lines 20 --n-equi 8 --output dense.tex

# 10) Швидкий чорновий перегляд (мало ліній, без зайвих файлів)
python field_lines_generator.py --q 1 -1 --distance 2 --n-lines 8 --n-equi 3 --output draft.tex

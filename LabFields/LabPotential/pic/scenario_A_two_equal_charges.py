import numpy as np
from field_to_tikz import (
    Charge, trace_line, downsample, to_tikz_coords, contour_polylines,
)

# --- геометрія (як в fig:q6, заряди на осі x) ---
d = 1.5
q = 1.0
x0, x1, y0, y1 = -4.5, 4.5, -3.2, 3.2
R = 0.03
n_half = 7  # ліній на "чверть" => всього 4*n_half ліній

charges = [Charge(q, [-d, 0]), Charge(q, [d, 0])]

# 1) рахуємо лінії ЛИШЕ для одного заряду (лівого), у верхній половині
#    (кут від ~6 до ~174 град, щоб уникнути сингулярної осі x)
angles = np.linspace(6, 174, n_half) * np.pi / 180
base_lines = []
dt = 0.8 * R  # q>0 => лінії йдуть від заряду
for a in angles:
    xs, ys = trace_line(
        charges, -d + R * np.cos(a), R * np.sin(a),
        dt, (x0, x1, y0, y1), R=R,
    )
    base_lines.append((xs, ys))

# 2) решта картини -- точні дзеркальні відображення (гарантована симетрія)
def mirror_x(lines):
    return [(-xs, ys) for xs, ys in lines]

def mirror_y(lines):
    return [(xs, -ys) for xs, ys in lines]

all_lines = (
    base_lines
    + mirror_y(base_lines)          # нижня половина лівого заряду
    + mirror_x(base_lines)          # верхня половина правого заряду
    + mirror_x(mirror_y(base_lines))  # нижня половина правого заряду
)

# 3) еквіпотенціалі (contour) -- симетричні "з коробки", бо V(x,y) для
#    цієї конфігурації сама по собі симетрична відносно обох осей
levels = [0.9, 1.3, 1.9, 3.0]
polys = contour_polylines(charges, x0, x1, y0, y1, levels)

# --- запис у TikZ ---
lines_out = []
for xs, ys in all_lines:
    xs_d, ys_d = downsample(xs, ys, n_max=30)
    lines_out.append(r"    \draw[line] plot coordinates {%s};" % to_tikz_coords(xs_d, ys_d))

equi_out = []
for xs, ys in polys:
    xs_d, ys_d = downsample(xs, ys, n_max=30)
    equi_out.append(r"    \draw[equi] plot coordinates {%s};" % to_tikz_coords(xs_d, ys_d))

tex = r"""%% Автоматично згенеровано: silovi linii + ekvipotentsiali,
%% симетрична заміна для рис. 6 (fig:q6) в LabPotential.tex
\begin{figure}[h!]
  \centering
  \begin{tikzpicture}[scale=0.9,
      charge/.style={circle, fill=orange!70, draw=black, thick, minimum size=22pt, font=\bfseries},
      line/.style={thick, blue, decoration={markings, mark=at position 0.55 with {\arrow{latex}}},
                   postaction=decorate},
      equi/.style={black, dashed, thin}
    ]
%s
%s
    \node[charge] at (-%.2f,0) {$+$};
    \node[charge] at ( %.2f,0) {$+$};
  \end{tikzpicture}
  \caption{Силові лінії та еквіпотенціалі поля двох однойменних точкових зарядів}
  \label{fig:q6}
\end{figure}
""" % ("\n".join(equi_out), "\n".join(lines_out), d, d)

with open("/home/claude/fig_q6_symmetric.tex", "w") as f:
    f.write(tex)

print("OK, ліній:", len(all_lines), " еквіпотенціальних кривих:", len(polys))

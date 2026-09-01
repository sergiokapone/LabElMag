import numpy as np
from field_to_tikz import (
    Charge, trace_line, downsample, to_tikz_coords, contour_polylines,
)

# --- геометрія: заряд q на висоті h над заземленою площиною y=0 ---
h = 2.0
q = 1.0
x0, x1, y0, y1 = -4.0, 4.0, 0.0, 4.5
R = 0.03
n_half = 9

real = Charge(q, [0, h])
image = Charge(-q, [0, -h])  # заряд-зображення (лише для розрахунку поля в y>0!)
charges_for_field = [real, image]

# 1) лінії лише для x>=0 боку (кут від -85 до 85 відносно заряду),
#    інтегруємо в полі (реальний+зображення), обриваємо на площині y=0
angles = np.linspace(-85, 85, n_half) * np.pi / 180
base_lines = []
dt = 0.8 * R
for a in angles:
    xs, ys = trace_line(
        charges_for_field, R * np.cos(a), h + R * np.sin(a),
        dt, (x0, x1, y0 - 0.001, y1), y_min=0.0, R=R,
    )
    base_lines.append((xs, ys))

# лінія точно вниз (перпендикулярно до площини) -- сама собі дзеркало
xs, ys = trace_line(charges_for_field, 0, h - R, -dt, (x0, x1, -0.001, y1), y_min=0.0, R=R)
straight_down = (xs, ys)

def mirror_x(lines):
    return [(-xs, ys) for xs, ys in lines]

all_lines = base_lines + mirror_x(base_lines) + [straight_down]

# 2) еквіпотенціалі -- рахуємо потенціал реал+зображення, тільки в y>0
#    (площина y=0 сама автоматично виходить лінією V=0)
levels = [0.15, 0.3, 0.5, 0.8]
polys = contour_polylines(charges_for_field, x0, x1, 0.02, y1, levels, y_min=0.02)

lines_out = []
for xs, ys in all_lines:
    xs_d, ys_d = downsample(xs, ys, n_max=30)
    lines_out.append(r"    \draw[line] plot coordinates {%s};" % to_tikz_coords(xs_d, ys_d))

equi_out = []
for xs, ys in polys:
    xs_d, ys_d = downsample(xs, ys, n_max=30)
    equi_out.append(r"    \draw[equi] plot coordinates {%s};" % to_tikz_coords(xs_d, ys_d))

tex = r"""%% Автоматично згенеровано: заряд (кулька) над провідною площиною,
%% метод зображень; фізичне поле існує лише в y>0.
\begin{figure}[h!]
  \centering
  \begin{tikzpicture}[scale=0.9,
      charge/.style={circle, fill=orange!70, draw=black, thick, minimum size=22pt, font=\bfseries},
      line/.style={thick, blue, decoration={markings, mark=at position 0.55 with {\arrow{latex}}},
                   postaction=decorate},
      equi/.style={black, dashed, thin},
      plane/.style={thick, postaction={pattern=north east lines}},
    ]
%s
%s
    \node[charge] at (0,%.2f) {$+$};
    %% провідна (заземлена) площина
    \fill[pattern=north east lines] (%.2f,-0.35) rectangle (%.2f,0);
    \draw[thick] (%.2f,0) -- (%.2f,0);
  \end{tikzpicture}
  \caption{Силові лінії та еквіпотенціалі заряду (кульки) над провідною площиною (метод зображень)}
  \label{fig:qplane}
\end{figure}
""" % ("\n".join(equi_out), "\n".join(lines_out), h, x0, x1, x0, x1)

with open("/home/claude/fig_charge_plane.tex", "w") as f:
    f.write(tex)

print("OK, ліній:", len(all_lines), " еквіпотенціальних кривих:", len(polys))

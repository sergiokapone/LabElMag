# -*- coding: utf-8 -*-
"""
Розрахунок силових ліній та еквіпотенціальних ліній для системи точкових
зарядів (в т.ч. заряд + провідна площина через метод зображень) і
експорт результату як готових TikZ-координат для \\draw plot[smooth]
coordinates {...}.

Ідея: вся "фізика" (інтегрування ліній напруженості, побудова
еквіпотенціалей) рахується в Python (numpy/scipy/matplotlib), а TikZ
лише малює вже готові набори точок -- це і швидше, і дає гарантовану
симетрію (бо симетрію можна нав'язати дзеркальним відображенням масивів
точок, а не "на око" підбираючи координати вручну, як зараз зроблено
в LabPotential.tex для рис. 6).
"""

import numpy as np
from scipy.integrate import ode


class Charge:
    def __init__(self, q, pos):
        self.q = q
        self.pos = np.array(pos, dtype=float)


def E_total(x, y, charges):
    Ex = Ey = 0.0
    for c in charges:
        dx, dy = x - c.pos[0], y - c.pos[1]
        r3 = (dx**2 + dy**2) ** 1.5
        Ex += c.q * dx / r3
        Ey += c.q * dy / r3
    return Ex, Ey


def V_total(x, y, charges):
    V = 0.0
    for c in charges:
        dx, dy = x - c.pos[0], y - c.pos[1]
        V += c.q / np.sqrt(dx**2 + dy**2)
    return V


def _E_dir(t, y, charges):
    Ex, Ey = E_total(y[0], y[1], charges)
    n = np.hypot(Ex, Ey)
    return [Ex / n, Ey / n]


def trace_line(charges, x_start, y_start, dt, bounds, y_min=None, R=0.01, max_steps=4000):
    """Інтегрує одну силову лінію з точки (x_start,y_start)."""
    x0, x1, y0, y1 = bounds
    r = ode(_E_dir)
    r.set_integrator("vode")
    r.set_f_params(charges)
    r.set_initial_value([x_start, y_start], 0)
    xs, ys = [x_start], [y_start]
    steps = 0
    while r.successful() and steps < max_steps:
        r.integrate(r.t + dt)
        xs.append(r.y[0])
        ys.append(r.y[1])
        steps += 1
        hit_charge = any(
            np.hypot(r.y[0] - c.pos[0], r.y[1] - c.pos[1]) < R for c in charges
        )
        out_of_box = not (x0 < r.y[0] < x1 and y0 < r.y[1] < y1)
        hit_plane = y_min is not None and r.y[1] <= y_min
        if hit_charge or out_of_box or hit_plane:
            break
    return np.array(xs), np.array(ys)


def field_lines_symmetric(q, pos_x, x0, x1, y0, y1, n_half=8, R=0.02, y_min=None):
    """
    Силові лінії для ОДНОГО заряду в правій верхній чверті (кути 5..85 град,
    щоб уникнути сингулярної осі), інтегровані один раз, а решта трьох
    чвертей (або дві половини, якщо є площина y_min) отримуються точним
    дзеркальним відображенням -- це і дає ідеальну симетрію картини.
    """
    dt = 0.8 * R * (1 if q > 0 else -1)
    lines = []
    angles = np.linspace(5, 85, n_half) * np.pi / 180
    for a in angles:
        xs, ys = trace_line(
            [Charge(q, [pos_x, 0])],
            pos_x + R * np.cos(a), R * np.sin(a),
            dt, (x0, x1, y0, y1), y_min=y_min, R=R,
        )
        lines.append((xs, ys))
    return lines


def downsample(xs, ys, n_max=40):
    """Рівномірна вибірка ПО ДОВЖИНІ ДУГИ (не по індексу!).

    Це критично для TikZ: якщо точки лягають нерівномірно (близько
    одна до одної там, де лінія рухається повільно біля заряду, і
    рідко там, де швидко), decorations/markings при обчисленні
    arc-length на сплайні може переповнити регістр розмірності TeX
    ("Dimension too large"). Рівномірний крок вздовж довжини лінії
    цю проблему знімає.
    """
    if len(xs) <= 2:
        return xs, ys
    seg = np.hypot(np.diff(xs), np.diff(ys))
    s = np.concatenate([[0], np.cumsum(seg)])
    if s[-1] == 0:
        return xs[:1], ys[:1]
    s_uniform = np.linspace(0, s[-1], min(n_max, len(xs)))
    xs_new = np.interp(s_uniform, s, xs)
    ys_new = np.interp(s_uniform, s, ys)
    return xs_new, ys_new


def to_tikz_coords(xs, ys, decimals=3):
    return "".join(f"({x:.{decimals}f},{y:.{decimals}f})" for x, y in zip(xs, ys))


def contour_polylines(charges, x0, x1, y0, y1, levels, n=250, y_min=None):
    """Витягує polylines еквіпотенціалей через matplotlib.contour (без figure)."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    xg = np.linspace(x0, x1, n)
    yg = np.linspace(y0 if y_min is None else y_min, y1, n)
    XX, YY = np.meshgrid(xg, yg)
    VV = np.zeros_like(XX)
    for c in charges:
        dx, dy = XX - c.pos[0], YY - c.pos[1]
        VV += c.q / np.sqrt(dx**2 + dy**2 + 1e-9)

    fig, ax = plt.subplots()
    cs = ax.contour(XX, YY, VV, levels=levels)
    polylines = []
    # Matplotlib >=3.8 : cs.allsegs ; older : same attribute name.
    for segs in cs.allsegs:
        for seg in segs:
            if len(seg) > 3:
                polylines.append((seg[:, 0], seg[:, 1]))
    plt.close(fig)
    return polylines

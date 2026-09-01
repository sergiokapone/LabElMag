# -*- coding: utf-8 -*-
"""
ЗАГАЛЬНИЙ генератор фігури "силові лінії + еквіпотенціалі" для довільного
набору точкових зарядів (і, за бажанням, провідної заземленої площини).

Як користуватись
-----------------
Варіант 1 -- без командного рядка: відредагуйте блок CONFIG нижче
(величини й положення зарядів -- в тих самих "сантиметрах", в яких малює
tikzpicture) і запустіть:

    python3 field_lines_generator.py

Варіант 2 -- через параметри командного рядка (мають пріоритет над CONFIG):

    # довільні заряди, явно задані координати (q,x,y; см)
    python3 field_lines_generator.py --charges 1,-1.5,0 1,1.5,0

    # два симетричні заряди на осі x на заданій відстані одне від одного
    python3 field_lines_generator.py --q 1 -1 --distance 4

    # те саме, але над заземленою провідною площиною y=0 (заряди на висоті 2 см)
    python3 field_lines_generator.py --q 1 -1 --distance 4 --plane --height 2

Повний список опцій: python3 field_lines_generator.py --help

Отримаєте файл out.tex (готовий \\begin{figure}...\\end{figure}), який можна
одразу \\input{out.tex} у LabPotential.tex.

Підтримує довільну кількість зарядів довільного знаку й величини, розміщених
де завгодно -- ніякої симетрії не вимагається (для симетричних конфігурацій
картина вийде симетричною сама по собі, бо ODE-інтегрування стабільне всюди,
крім вузької околиці сідлової точки між однойменними зарядами -- її ми
уникаємо, просто не пускаючи лінію рівно вздовж осі, що з'єднує такі заряди).
"""

import argparse
import re
import sys

import numpy as np
from field_to_tikz import Charge, trace_line, downsample, to_tikz_coords, contour_polylines

# ============================== CONFIG ====================================
# Використовується, якщо відповідні параметри НЕ задані через командний
# рядок -- зручно для швидких експериментів без набору аргументів.

# Заряди: (величина q [в умовних одиницях, знак важливий], x, y [см])
CHARGES = [
    (+1.0, -1.5, 0.0),
    (+1.0, 1.5, 0.0),
]

# Якщо є провідна заземлена площина y = Y_PLANE (метод зображень).
# Всі заряди повинні бути розташовані з боку y > Y_PLANE.
WITH_PLANE = False
Y_PLANE = 0.0

# Область малювання/інтегрування (см); None -> підбирається автоматично
BOUNDS = None  # напр. (-5, 5, -4, 4)
MARGIN = 2.5   # запас навколо зарядів, якщо BOUNDS=None

N_LINES_PER_CHARGE = 14     # ліній навколо кожного заряду (масштабується з |q|)
N_EQUI_LEVELS = 5           # скільки еквіпотенціальних рівнів намалювати
OUTPUT_TEX = "out.tex"
FIGURE_LABEL = "fig:custom"
FIGURE_CAPTION = "Силові лінії та еквіпотенціалі заданої системи зарядів"

# ===========================================================================


def parse_args(argv=None):
    p = argparse.ArgumentParser(
        description="Генератор TikZ-фігури 'силові лінії + еквіпотенціалі' "
                     "для довільної системи точкових зарядів.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Приклади:\n"
            "  # явні координати зарядів (q,x,y у см)\n"
            "  %(prog)s --charges 1,-1.5,0 -1,1.5,0\n\n"
            "  # два заряди симетрично на осі x на заданій відстані\n"
            "  %(prog)s --q 1 -1 --distance 4\n\n"
            "  # те саме над заземленою площиною (висота над площиною 2 см)\n"
            "  %(prog)s --q 1 -1 --distance 4 --plane --height 2\n"
        ),
    )

    charge_group = p.add_argument_group("заряди")
    charge_group.add_argument(
        "--charges", nargs="+", metavar="q,x,y",
        help="Явний список зарядів у форматі 'q,x,y' (см), напр. "
             "--charges 1,-1.5,0 -1,1.5,0. Має пріоритет над --q/--distance.",
    )
    charge_group.add_argument(
        "--q", nargs="+", type=float, metavar="Q",
        help="Величини зарядів (знак важливий), які буде розставлено "
             "автоматично симетрично на осі x з кроком --distance, напр. "
             "--q 1 -1  (потрібен разом з --distance, якщо зарядів більше 1).",
    )
    charge_group.add_argument(
        "--distance", type=float, default=None,
        help="Відстань між сусідніми зарядами (см) при автоматичному "
             "розставленні через --q; заряди центруються навколо x=0.",
    )
    charge_group.add_argument(
        "--height", type=float, default=2.0,
        help="Висота зарядів над площиною y=Y_PLANE (см) при автоматичному "
             "розставленні через --q разом з --plane. За замовчуванням 2.0. "
             "Без --plane заряди розставляються на y=0.",
    )

    plane_group = p.add_argument_group("провідна площина")
    plane_group.add_argument(
        "--plane", action="store_true",
        help="Увімкнути заземлену провідну площину (метод зображень).",
    )
    plane_group.add_argument(
        "--plane-y", type=float, default=None,
        help="Положення площини y=... (см). За замовчуванням 0.0.",
    )
    plane_group.add_argument(
        "--min-angle", type=float, default=None,
        help="Додає, крім рівномірного набору, ще й пологі 'прибережні' лінії, "
             "що йдуть майже вздовж площини й лягають на неї далеко від заряду. "
             "Значення -- найменший кут від горизонталі (град), з якого починається "
             "такий пологий пучок (типово 1-3; чим менше, тим ближче до площини "
             "лягає найпологіша лінія, і тим ШИРШІ мають бути --bounds, бо вона "
             "довго йде майже горизонтально). Діє лише разом з --plane. "
             "Приклад: --min-angle 1.5 --n-near-plane 3",
    )
    plane_group.add_argument(
        "--n-near-plane", type=int, default=3,
        help="Скільки додаткових пологих ліній додати з кожного боку кожного "
             "заряду, якщо задано --min-angle (типово 3).",
    )

    geom_group = p.add_argument_group("область малювання")
    geom_group.add_argument(
        "--bounds", nargs=4, type=float, metavar=("X0", "X1", "Y0", "Y1"),
        help="Явна область малювання/інтегрування (см). За замовчуванням "
             "підбирається автоматично з відступом --margin.",
    )
    geom_group.add_argument(
        "--margin", type=float, default=None,
        help="Відступ навколо зарядів для автоматичної області (см).",
    )

    out_group = p.add_argument_group("вивід")
    out_group.add_argument("--n-lines", type=int, default=None,
                            help="Кількість силових ліній на заряд (масштабується з |q|).")
    out_group.add_argument("--n-equi", type=int, default=None,
                            help="Кількість еквіпотенціальних рівнів.")
    out_group.add_argument(
        "--equi-range", nargs=2, type=float, default=None, metavar=("LOW", "HIGH"),
        help="Діапазон percentile (0-99) розподілу |V| по сітці, з якого "
             "обираються рівні еквіпотенціалей. Percentile ближче до 0 -- "
             "це МАЛІ |V|, тобто лінії, що йдуть ДАЛЕКО від заряду і тому "
             "лягають ближче до площини й пласкішають там (як на класичних "
             "малюнках); percentile ближче до 99 -- це ВЕЛИКІ |V|, тобто "
             "тісні кола впритул біля самого заряду. За замовчуванням (5, 60) -- "
             "щоб частина еквіпотенціалей обов'язково діставала до площини. "
             "Хочете картину ще ближче до площини -- зменшуйте LOW (напр. 2); "
             "хочете більше ліній щільно біля заряду -- піднімайте HIGH.",
    )
    out_group.add_argument("--output", default=None, help="Ім'я вихідного .tex файлу.")
    out_group.add_argument("--label", default=None, help="LaTeX \\label{} фігури.")
    out_group.add_argument("--caption", default=None, help="LaTeX \\caption{} фігури.")

    # За замовчуванням argparse вважає "схожим на число" (а не на невідому
    # опцію) лише токен виду -3 чи -3.5. Наші заряди/спеки типу "-1,1.5,0"
    # або просто "-1" для --q цьому не відповідають і без цього патчу
    # сприймались би як невідома опція. Жодна з наших опцій сама не виглядає
    # як від'ємне число, тож розширення регексу безпечне.
    p._negative_number_matcher = re.compile(r"^-\d.*$")

    return p.parse_args(argv)


def charges_from_args(args):
    """Формує список (q, x, y) із аргументів командного рядка, або None,
    якщо ні --charges, ні --q не задано (тоді використовується CONFIG)."""
    if args.charges:
        result = []
        for spec in args.charges:
            parts = spec.split(",")
            if len(parts) != 3:
                sys.exit(f"Помилка: '--charges {spec}' повинен мати вигляд q,x,y")
            try:
                q, x, y = (float(v) for v in parts)
            except ValueError:
                sys.exit(f"Помилка: не вдалось розпарсити числа в '--charges {spec}'")
            result.append((q, x, y))
        return result

    if args.q:
        n = len(args.q)
        with_plane = args.plane
        y_plane = args.plane_y if args.plane_y is not None else Y_PLANE
        y = (y_plane + args.height) if with_plane else 0.0
        if n == 1:
            xs = [0.0]
        else:
            if args.distance is None:
                sys.exit("Помилка: при декількох --q потрібно також задати --distance")
            total_span = args.distance * (n - 1)
            xs = list(np.linspace(-total_span / 2, total_span / 2, n))
        return [(q, x, y) for q, x in zip(args.q, xs)]

    return None


def build_charge_list(charges_cfg, with_plane, y_plane):
    """Повертає (реальні_заряди, заряди_для_поля{включно з зображеннями})."""
    real = [Charge(q, [x, y]) for q, x, y in charges_cfg]
    if not with_plane:
        return real, real
    field_charges = list(real)
    for c in real:
        field_charges.append(Charge(-c.q, [c.pos[0], 2 * y_plane - c.pos[1]]))
    return real, field_charges


def auto_bounds(real_charges, margin):
    xs = [c.pos[0] for c in real_charges]
    ys = [c.pos[1] for c in real_charges]
    return (min(xs) - margin, max(xs) + margin, min(ys) - margin, max(ys) + margin)


def field_lines_for_charge(c, field_charges, bounds, n_lines, y_min, R=0.03,
                            extra_angles_deg=None):
    """N ліній рівномірно по куту навколо заряду c, з обходом сингулярних
    напрямків точно на іншій заряд (щоб не влучити у сідлову точку).

    extra_angles_deg -- необов'язковий список ДОДАТКОВИХ кутів (град, у тій
    самій системі відліку: 0=+x, проти год. стрілки), які додаються до
    рівномірного набору. Приклад використання -- "прибережні" лінії, майже
    паралельні площині (див. build_near_plane_angles нижче): їх позиції
    відносно площини визначаються не рівномірним кроком по колу, а свідомо
    обраним вузьким пучком кутів, тому додаємо їх окремо, а не намагаємось
    "влучити в потрібну зону" збільшенням n_lines для всього кола.

    Для від'ємних зарядів масив точок розвертається (кінець лінії -- це
    точка біля самого заряду), щоб стрілка на лінії (яка малюється в
    напрямку від першої до останньої координати) була напрямлена ДО
    заряду, як і має бути фізично для силових ліній негативного заряду."""
    x0, x1, y0, y1 = bounds
    # кути точно на інші заряди -- уникаємо (в межах +-2 град)
    banned = set()
    for other in field_charges:
        if other is c:
            continue
        ang = np.degrees(np.arctan2(other.pos[1] - c.pos[1], other.pos[0] - c.pos[0]))
        banned.add(round(ang))

    angles_deg = np.linspace(0, 360, n_lines, endpoint=False)
    if extra_angles_deg:
        angles_deg = np.concatenate([angles_deg, np.asarray(extra_angles_deg, dtype=float)])
    dt = 0.8 * R * (1 if c.q > 0 else -1)
    lines = []
    for a_deg in angles_deg:
        if any(abs((a_deg - b + 180) % 360 - 180) < 3 for b in banned):
            a_deg += 4  # трохи зсунути, щоб не влучити точно в іншу зарядку
        a = np.radians(a_deg)
        xs, ys = trace_line(
            field_charges, c.pos[0] + R * np.cos(a), c.pos[1] + R * np.sin(a),
            dt, bounds, y_min=y_min, R=R,
        )
        if c.q < 0:
            # лінія повинна "входити" в заряд -- розвертаємо порядок точок,
            # щоб стрілка (яка малюється в напрямку 1а точка -> остання)
            # вказувала всередину, на заряд, а не назовні від нього.
            xs, ys = xs[::-1], ys[::-1]
        lines.append((xs, ys))
    return lines


def build_near_plane_angles(min_angle, n_extra, max_angle=None):
    """Пучок кутів, майже паралельних площині (0 = вправо, 180 = вліво),
    що лежать ЗАВЖДИ під горизонталлю (в бік площини) -- тобто трохи ВИЩЕ
    за 180..360 у звичному відліку, а саме в діапазоні (-max_angle,-min_angle)
    та (180+min_angle,180+max_angle).

    min_angle -- найближчий до горизонталі кут (найдовша, найпологіша лінія,
    лягає на площину найдалі); max_angle -- найдальший (типово 4*min_angle,
    щоб пучок був вузьким і справді "прибережним", а не просто дублював
    рівномірний набір).
    """
    if max_angle is None:
        max_angle = min_angle * 4
    band = np.linspace(min_angle, max_angle, max(1, n_extra))
    # обидва боки заряду (вправо і вліво вздовж площини)
    return list(-band) + list(180 + band)


def main():
    args = parse_args()

    cli_charges = charges_from_args(args)
    charges_cfg = cli_charges if cli_charges is not None else CHARGES

    with_plane = args.plane or WITH_PLANE
    y_plane = args.plane_y if args.plane_y is not None else Y_PLANE

    if with_plane:
        below = [(q, x, y) for q, x, y in charges_cfg if y <= y_plane]
        if below:
            sys.exit(
                "Помилка: усі заряди повинні бути розташовані з боку y > "
                f"{y_plane} (площина). Заряди під/на площині: {below}"
            )

    bounds = tuple(args.bounds) if args.bounds else BOUNDS
    margin = args.margin if args.margin is not None else MARGIN
    n_lines_per_charge = args.n_lines if args.n_lines is not None else N_LINES_PER_CHARGE
    n_equi_levels = args.n_equi if args.n_equi is not None else N_EQUI_LEVELS
    output_tex = args.output if args.output is not None else OUTPUT_TEX
    figure_label = args.label if args.label is not None else FIGURE_LABEL
    figure_caption = args.caption if args.caption is not None else FIGURE_CAPTION

    real, field_charges = build_charge_list(charges_cfg, with_plane, y_plane)
    bounds = bounds or auto_bounds(real, margin)
    y_min = y_plane if with_plane else None

    extra_angles = None
    if with_plane and args.min_angle is not None:
        extra_angles = build_near_plane_angles(args.min_angle, args.n_near_plane)

    all_lines = []
    for c in real:
        n = max(6, round(n_lines_per_charge * np.sqrt(abs(c.q))))
        all_lines += field_lines_for_charge(
            c, field_charges, bounds, n, y_min, extra_angles_deg=extra_angles,
        )

    # еквіпотенціалі: рівні підбираємо автоматично з розподілу |V| в області
    x0, x1, y0, y1 = bounds
    xg = np.linspace(x0, x1, 150)
    yg = np.linspace(y0 if y_min is None else y_min, y1, 150)
    XX, YY = np.meshgrid(xg, yg)
    VV = np.zeros_like(XX)
    for c in field_charges:
        dx, dy = XX - c.pos[0], YY - c.pos[1]
        VV += c.q / np.sqrt(dx**2 + dy**2 + 1e-6)
    finite = VV[np.isfinite(VV) & (np.abs(VV) < np.percentile(np.abs(VV), 99))]
    # Percentile 60..97 (як було раніше) бере лише ВЕЛИКІ |V| -- тобто точки
    # близько до заряду -- і тому еквіпотенціалі виходять тісними петлями
    # навколо заряду, жодна не встигає дійти до площини й "розпластатись"
    # там, як на класичних малюнках (рис. 2.5). Щоб частина ліній йшла
    # далі й лягала ближче до площини, треба захопити й НИЗЬКІ percentile
    # (малі |V|, далекі точки) -- звідси діапазон (5, 60) за замовчуванням.
    equi_low, equi_high = args.equi_range if args.equi_range else (5.0, 60.0)
    levels = np.unique(np.round(
        np.percentile(np.abs(finite), np.linspace(equi_low, equi_high, n_equi_levels)), 2
    ))
    levels = sorted(set(list(levels) + list(-levels)))
    polys = contour_polylines(field_charges, x0, x1, y0, y1, levels, y_min=y_min)

    lines_out = []
    for xs, ys in all_lines:
        xs_d, ys_d = downsample(xs, ys, n_max=30)
        if len(xs_d) < 2:
            continue
        lines_out.append(r"    \draw[line] plot coordinates {%s};" % to_tikz_coords(xs_d, ys_d))

    equi_out = []
    for xs, ys in polys:
        xs_d, ys_d = downsample(xs, ys, n_max=30)
        if len(xs_d) < 2:
            continue
        equi_out.append(r"    \draw[equi] plot coordinates {%s};" % to_tikz_coords(xs_d, ys_d))

    nodes_out = []
    for q, x, y in charges_cfg:
        color = "red!70" if q > 0 else "blue!70"
        sign = "+" if q > 0 else "-"
        size = 16 + 10 * np.sqrt(abs(q))
        nodes_out.append(
            r"    \node[text= white, circle, ball color=%s, draw=%s, thick, minimum size=%.1fpt, font=\bfseries] at (%.3f,%.3f) {$%s$};"
            % (color, color, size, x, y, sign)
        )

    plane_out = ""
    if with_plane:
        plane_out = (
            r"    \fill[pattern=north east lines] (%.2f,%.2f) rectangle (%.2f,%.2f);"
            "\n    \\draw[thick] (%.2f,%.2f) -- (%.2f,%.2f);"
        ) % (x0, y_min - 0.4, x1, y_min, x0, y_min, x1, y_min)

    tex = r"""%% Автоматично згенеровано field_lines_generator.py
\begin{figure}[h!]
  \centering
  \begin{tikzpicture}[scale=0.9,
      line/.style={thick, blue, decoration={markings, mark=at position 0.55 with {\arrow{latex}}},
                   postaction=decorate},
      equi/.style={black, dashed, thin}
    ]
%s
%s
%s
%s
  \end{tikzpicture}
  \caption{%s}
  \label{%s}
\end{figure}
""" % ("\n".join(equi_out), "\n".join(lines_out), "\n".join(nodes_out), plane_out,
       figure_caption, figure_label)

    # явно UTF-8 -- у caption/коментарях кирилиця, а open() без encoding
    # покладається на локаль системи (яка не завжди utf-8, напр. на CI
    # або Windows), через що можна отримати UnicodeEncodeError або
    # побитий за кодуванням .tex файл.
    with open(output_tex, "w", encoding="utf-8") as f:
        f.write(tex)
    print(f"Записано {output_tex}: {len(lines_out)} ліній, {len(equi_out)} еквіпотенціалей "
          f"({len(real)} зарядів{', з площиною' if with_plane else ''})")


if __name__ == "__main__":
    main()

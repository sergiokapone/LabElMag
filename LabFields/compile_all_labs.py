#!/usr/bin/env python3
"""
compile_all_labs.py

Автоматично генерує окремий .tex-файл для кожної лабораторної роботи,
перерахованої у блоці \\Chapters майстер-файлу SingleLabWork.tex,
і компілює кожен через latexmk (LuaLaTeX + Biber, згідно з вашим .latexmkrc).

Логіка виведена з файлу-шаблону:
  - у \\newcommand{\\Chapters}{ ... } перелічені всі лаби, кожна своїм рядком,
    рядок або закоментований (%), або ні — активна рівно одна;
  - \\setcounter{chapter}{N} — це індекс активного рядка у списку,
    рахуючи з нуля (перший рядок -> 0, другий -> 1, і т.д.).

Скрипт сам знаходить порядок лаб у файлі (нічого не хардкодить),
тож якщо ви додасте/приберете рядок у \\Chapters — все підхопиться саме.

ВАЖЛИВО: сам SingleLabWork.tex НІКОЛИ не змінюється — для кожної лаби
створюється окрема копія з назвою <ІмяЛаби>.tex поруч із шаблоном.
Це важливо ще й тому, що \\addbibresource{\\jobname.bib} шукає файл
<ІмяЛаби>.bib — переконайтесь, що такі .bib-файли вже існують поруч
(наприклад LabPotential.bib), інакше на кроці biber буде помилка.

Використання:
    python3 compile_all_labs.py [шлях_до_SingleLabWork.tex] [опції]

Типова поведінка (без опцій): після компіляції ВСІХ лаб скрипт сам видаляє
згенеровані .tex-файли та прибирає допоміжні файли (.aux/.bbl/.log/...).

Опції:
    --only NAME [NAME ...]   скомпілювати лише вказані лаби (за іменем)
    --keep-tex                НЕ видаляти згенеровані .tex файли (типово вони видаляються)
    --no-keep-tex              (типово, прапорець необов'язковий) видалити .tex після компіляції ВСІХ лаб
    --clean-aux                (типово, прапорець необов'язковий) прибрати допоміжні файли після компіляції ВСІХ лаб
    --no-clean-aux              НЕ прибирати допоміжні файли (.aux/.bbl/.bcf/.log/... залишаться)
    --dry-run                  тільки показати, що буде згенеровано/виконано, нічого не писати/не компілювати
"""

import argparse
import re
import subprocess
import sys
from pathlib import Path

CHAPTERS_BLOCK_RE = re.compile(
    r"(\\newcommand\{\\Chapters\}\{\n)(.*?)(\n\})",
    re.DOTALL,
)
CHAPTER_LINE_RE = re.compile(r"^(?P<indent>[ \t]*)(?P<comment>%?)[ \t]*(?P<name>[A-Za-z0-9_]+)[ \t]*,[ \t]*$")
SETCOUNTER_RE = re.compile(r"(\\setcounter\{chapter\}\{)(\d+)(\})")

AUX_EXTENSIONS = [
    ".aux", ".bbl", ".bcf", ".blg", ".log", ".out", ".run.xml",
    ".toc", ".fdb_latexmk", ".fls", ".synctex.gz", ".xdv",
]


def parse_chapters(text: str):
    """Повертає (список_імен_у_порядку, match_object_блоку)."""
    m = CHAPTERS_BLOCK_RE.search(text)
    if not m:
        sys.exit("Не вдалося знайти блок \\newcommand{\\Chapters}{...} у файлі.")
    names = []
    for line in m.group(2).splitlines():
        lm = CHAPTER_LINE_RE.match(line)
        if lm:
            names.append(lm.group("name"))
    if not names:
        sys.exit("У блоці \\Chapters не знайдено жодної лаби.")
    return names, m


def build_variant(text: str, block_match: re.Match, names, active_index: int) -> str:
    """Повертає текст файлу з розкоментованою лише names[active_index] і виправленим setcounter."""
    lines_out = []
    for i, name in enumerate(names):
        prefix = "" if i == active_index else "%"
        lines_out.append(f"\t{prefix}{name},")
    new_block = block_match.group(1) + "\n".join(lines_out) + block_match.group(3)

    new_text = text[: block_match.start()] + new_block + text[block_match.end():]

    def repl_counter(m):
        return f"{m.group(1)}{active_index}{m.group(3)}"

    new_text, n = SETCOUNTER_RE.subn(repl_counter, new_text, count=1)
    if n == 0:
        sys.exit("Не вдалося знайти \\setcounter{chapter}{...} у файлі.")
    return new_text


def run_latexmk(tex_path: Path, dry_run: bool) -> bool:
    cmd = ["latexmk", "-lualatex", "-interaction=nonstopmode", tex_path.name]
    print(f"  $ {' '.join(cmd)}   (у {tex_path.parent})")
    if dry_run:
        return True
    result = subprocess.run(cmd, cwd=tex_path.parent)
    return result.returncode == 0


def clean_aux(tex_path: Path):
    stem = tex_path.stem
    for ext in AUX_EXTENSIONS:
        f = tex_path.parent / f"{stem}{ext}"
        if f.exists():
            f.unlink()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("template", nargs="?", default="SingleLabWork.tex", help="шлях до майстер-файлу")
    ap.add_argument("--only", nargs="+", help="скомпілювати лише ці лаби (за іменем)")
    keep_group = ap.add_mutually_exclusive_group()
    keep_group.add_argument("--keep-tex", dest="keep_tex", action="store_true", default=False,
                             help="НЕ видаляти згенеровані .tex після компіляції всіх лаб (типово вони видаляються)")
    keep_group.add_argument("--no-keep-tex", dest="keep_tex", action="store_false",
                             help="(типова поведінка, прапорець не обов'язковий) видалити згенеровані .tex")
    aux_group = ap.add_mutually_exclusive_group()
    aux_group.add_argument("--clean-aux", dest="clean_aux", action="store_true", default=True,
                            help="(типова поведінка, прапорець не обов'язковий) прибрати допоміжні файли після компіляції всіх лаб")
    aux_group.add_argument("--no-clean-aux", dest="clean_aux", action="store_false",
                            help="НЕ прибирати допоміжні файли (.aux/.log/... залишаться)")
    ap.add_argument("--dry-run", action="store_true", help="нічого не писати й не компілювати, лише показати план")
    args = ap.parse_args()

    template_path = Path(args.template).resolve()
    if not template_path.exists():
        sys.exit(f"Файл не знайдено: {template_path}")

    text = template_path.read_text(encoding="utf-8")
    names, block_match = parse_chapters(text)

    targets = args.only if args.only else names
    unknown = [n for n in targets if n not in names]
    if unknown:
        sys.exit(f"Невідомі лаби: {unknown}. Доступні: {names}")

    print(f"Знайдено лаб у {template_path.name}: {names}")
    print(f"Буде оброблено: {targets}\n")

    failures = []
    out_paths = []  # усі згенеровані .tex-файли, для прибирання після циклу
    for name in targets:
        idx = names.index(name)
        out_path = template_path.parent / f"{name}.tex"
        out_paths.append(out_path)
        print(f"[{name}] -> {out_path.name} (chapter counter = {idx})")

        variant_text = build_variant(text, block_match, names, idx)

        if not args.dry_run:
            out_path.write_text(variant_text, encoding="utf-8")

        ok = run_latexmk(out_path, args.dry_run)
        if not ok:
            print(f"  !! Помилка компіляції {name}")
            failures.append(name)
        else:
            print(f"  OK -> {out_path.with_suffix('.pdf').name}")

        print()

    # Прибирання виконується один раз, після того як усі лаби скомпільовано,
    # а не після кожної окремої лаби.
    if not args.dry_run:
        if args.clean_aux:
            print("Прибирання допоміжних файлів (.aux/.log/... ) для всіх лаб...")
            for out_path in out_paths:
                clean_aux(out_path)

        if not args.keep_tex:
            print("Видалення згенерованих .tex-файлів для всіх лаб...")
            for out_path in out_paths:
                out_path.unlink(missing_ok=True)

    if failures:
        print(f"Завершено з помилками у: {failures}")
        sys.exit(1)
    print("Готово. Усі лаби скомпільовано.")


if __name__ == "__main__":
    main()

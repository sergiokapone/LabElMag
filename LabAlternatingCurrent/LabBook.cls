\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{LabBook}[2018/01/21]
\LoadClass[onecolumn, twoside, 14pt]{extbook}

%===============================================================================
%
%										Геометрія сторінки
%
%===============================================================================
\newlength{\topspace}
\setlength{\topspace}{2cm}
\RequirePackage[%
	a4paper,%
	footskip=1cm,%
	headsep=0.3cm,%
	top=\topspace, %поле сверху
	bottom=2cm, %поле снизу
	left=2cm, %поле ліворуч
	right=2cm, %поле праворуч
]{geometry}

%===============================================================================
%
%										Налаштування мови та компіляторів
%
%===============================================================================

\RequirePackage{ifluatex,ifxetex}
\newif\ifxetexorluatex
\ifxetex
	\xetexorluatextrue
\else
	\ifluatex
		\xetexorluatextrue
	\else
		\xetexorluatexfalse
	\fi
\fi
\ifxetexorluatex
	\RequirePackage{fontspec}
	\setsansfont{CMU Sans Serif}%{Arial}
	\setmainfont{stix}%{CMU Serif}%{Times New Roman}
	\setmonofont{CMU Typewriter Text}%{Consolas}
	\defaultfontfeatures{Ligatures={TeX}}
	\RequirePackage{luacolor}
	\usepackage{luatexbase} % TexLive2018 bug
\else
	\RequirePackage[T2A,T1]{fontenc}
	\RequirePackage[utf8]{inputenc}
	\input{glyphtounicode}
	\pdfgentounicode=1
	\RequirePackage{cmap}
	\renewcommand{\sfdefault}{fos}
	\renewcommand{\bfdefault}{b}
\fi
\RequirePackage[english,russian,ukrainian]{babel}


%===============================================================================
%
%										Налаштування типографських вимог
%
%===============================================================================

\RequirePackage{microtype}
%\usepackage[defaultlines=4,all]{nowidow}
%\clubpenalty =1000
%\widowpenalty=1000
%\setlength{\parskip}{0.5ex}%
\setlength{\parindent}{2.5em}%
%\renewcommand{\baselinestretch}{1.1}
\def\@textbottom{\vskip \z@ \@plus 1pt}
\let\@texttop\relax
%\setlength{\emergencystretch}{1em}

%===============================================================================
%
%										Пакети
%
%===============================================================================

\RequirePackage[overload]{textcase}
\let\MakeUppercase\MakeTextUppercase
\RequirePackage{indentfirst}
\RequirePackage{currfile}
% ------------------------------------ Плаваючі об'єкти -----------------------
%\RequirePackage{subfig}і
%\renewcommand\thesubfigure{\alph{subfigure}}
\RequirePackage{wrapfig}
\RequirePackage[final]{pdfpages}
% ------------------------------------ Таблиці --------------------------------
\RequirePackage{subcaption}
\RequirePackage{colortbl}
\RequirePackage{makecell}
\RequirePackage{longtable}
\RequirePackage{array,ragged2e}
\setlength\arrayrulewidth{1pt}

% ------------------------------------ Математика ------------------------------
\ifxetexorluatex
	\RequirePackage{amsmath}
%	\RequirePackage{lualatex-math}
%	\RequirePackage[math-style=TeX,bold-style=TeX]{unicode-math}
%	\setmathfont[]{Stix Two Math}
\else
	\RequirePackage{amsfonts}
	\RequirePackage{amssymb}
\fi

\RequirePackage{esint}
\RequirePackage{nicefrac}
\let\nfrac\nicefrac
\allowdisplaybreaks
% -------------------------------- Визначення математичних команд -----------------------------------

\AtBeginDocument{%
	\let\phi\varphi
	\let\epsilon\varepsilon
	\DeclareMathOperator{\const}{const}
	\DeclareMathOperator{\inv}{inv}
	\newcommand{\Laplasian}{\Delta}
	\newcommand{\vect}[1]{\symbf{#1}}
	\def\Efield{\vect{E}}          % --- Визначення вектора електричного поля            ---
	\def\Dfield{\vect{D}}          % --- Визначення електричної індукції                 ---
	\def\Bfield{\vect{B}}          % --- Визначення вектора магнітногї індукції          ---
	\def\Hfield{\vect{H}}          % --- Визначення вектора напруженості магнітного поля ---
}
\def\eff{e\kern-.3ex f\kern-.5ex f}

\RequirePackage{mhchem}
% ---------------------------------------- Таблиці ------------------------------------------------------
\RequirePackage{booktabs}
\RequirePackage{tabularx}
\newcolumntype{R}{>{\footnotesize}r}
\newcolumntype{L}{>{\footnotesize}l}
\newcolumntype{C}{>{\centering\arraybackslash}p{5em}}
\RequirePackage{varwidth}
\newcolumntype{M}[1]{>{\begin{varwidth}[t]{#1}}l<{\end{varwidth}}}
\newcommand{\centercell}[1]{\multicolumn{1}{c}{#1}}
\newcommand{\specialcell}[3][c]{%
	\begin{tabular}[#1]{@{}#2@{}}#3\end{tabular}}
\RequirePackage{colortbl}
\setlength{\aboverulesep}{0pt}
\setlength{\belowrulesep}{0pt}
\setlength{\extrarowheight}{0.75ex}
\RequirePackage[justification=centering,labelsep=period]{caption}
\RequirePackage{multirow}
% ------------------------------------- Фалові операції -------------------------------------------------
\RequirePackage{currfile}
% ------------------------------------- Пакети LaTeX3 ---------------------------------------------------
\RequirePackage{xparse}
% -------------------------------------------------------------------------------------------------------
\RequirePackage{epigraph}
\setlength\epigraphwidth{.8\textwidth}
\setlength\epigraphrule{0pt}
\renewcommand{\textflush}{flushepinormal}
\RequirePackage{lastpage}
\RequirePackage[disable]{todonotes}
\RequirePackage{pdftexcmds}
\RequirePackage[most, many]{tcolorbox}
\tcbset{highlight math style={enhanced, colframe=red,
			colback=white,arc=0pt,boxrule=1pt}}
\tcbset{colframe=black,colback=white,colupper=black,
	fonttitle=\bfseries,nobeforeafter,center title,size=small,box align=base}
\newtcolorbox{More}[1][]{
	fontupper=\small,
	parbox=false,
	breakable,
	top=10pt,
	lower separated=false,
	colback=gray!10,
	colframe=white, fonttitle=\bfseries,
	colbacktitle=gray!15,
	coltitle=black,
	enhanced,
	attach boxed title to top left={xshift=0.5cm,yshift=-4mm},
	title=Додаткова інформація,#1}

\newtcolorbox{Warning}[1][]{
	top=10pt,
    enhanced jigsaw,breakable,
    fontupper=\small,
	lower separated=false,
	colback=white!80!red,
	colframe=red, fonttitle=\bfseries,
	colbacktitle=white!50!red,
	coltitle=white,
	enhanced,
	attach boxed title to top left={xshift=0.5cm,yshift=-1mm},
	title=Увага}

\newtcolorbox{Definition}[1][]{
	fontupper=\small,
	parbox=false,
	breakable,
	top=10pt,
	lower separated=false,
	colback=gray!10,
	colframe=white, fonttitle=\bfseries,
	colbacktitle=gray!15,
	coltitle=black,
	enhanced,
	attach boxed title to top left={xshift=0.5cm,yshift=-4mm},
	title=Формулювання,#1}

\newtcolorbox{Example}[1][]{
	top=10pt,
	lower separated=false,
	colback=white!80!red,
	colframe=white, fonttitle=\bfseries,
	colbacktitle=white!50!red,
	coltitle=black,
	enhanced,
	attach boxed title to top left={xshift=0.5cm,yshift=-1mm},
	title=Example,#1}

\newtcolorbox{tornpage}{%
	enhanced jigsaw, % allow page breaks
	frame hidden, % hide the default frame
	overlay={%
			\draw [
				fill=white, % fill paper
				draw=white!50!black, % boundary colour
				decorate, % decoration
				decoration={random steps,segment length=2pt,amplitude=1pt},
				drop shadow, % shadow
			]
			% top line
			(frame.north west)--(frame.north east)--
			% right line
			(frame.north east)--(frame.south east)--
			% bottom line
			(frame.south east)--(frame.south west)--
			% left line
			(frame.south west)--(frame.north west);
		},
	% paragraph skips obeyed within tcolorbox
	parbox=false,
}

\usetikzlibrary{decorations.pathmorphing}
\usetikzlibrary{shadows}
\usetikzlibrary{circuits.ee.IEC}
\usetikzlibrary{intersections}
\tikzset{
	partial ellipse/.style args={#1:#2:#3}{
			insert path={+ (#1:#3) arc (#1:#2:#3)}
		}
}
\tikzset{circuit ee IEC,
	every info/.style=red,
	semithick,
	every info/.style={font=\footnotesize},
	small circuit symbols,
	circuit declare symbol = ocontact,
	circuit declare symbol = ampermeter,
	circuit declare symbol = voltmeter,
	circuit declare symbol = galvanometer,
	set ampermeter graphic = {draw,generic circle IEC, minimum size=5mm,info=center:A},%
	set voltmeter graphic = {draw,generic circle IEC, minimum size=5mm,info=center:V},
	set galvanometer graphic = {draw,generic circle IEC, minimum size=10mm,info=center:G},
	set ocontact graphic = {draw, fill = white, generic circle IEC, shape=circle, minimum size=1mm},
}
\tikzset{%
	amplifier/.pic={
			code={\tikzset{scale=0.5}
					\draw[] (0,1) -- (0,-1) -- (1,0) -- cycle;
					\draw[red] (0,0.5) --++(-1,0) -- ++(0,1) coordinate (-top);
					\node[right=-0.7ex] at (0,0.5) {\tiny $-$};\node[right=-0.7ex] at (0,-0.5) {\tiny $+$};
					\draw[blue] (0,-0.5) --++(-1,0) -- ++(0,-1) coordinate (-bottom);
					\coordinate (-head) at (1,0);
				}},%
}

%===============================================================================
%
%										Рисування
%
%===============================================================================

\RequirePackage{tikz}
\RequirePackage{pgfplots, pgfplotstable}
\pgfplotsset{LabPlotGrid/.style={%
			legend style={font=\scriptsize},
			grid = both,
			grid style={line width=.1pt, draw=brown!10},
			major grid style={line width=.2pt,draw=brown!50},
			minor tick num = 4,
			minor grid style = {line width=.1pt,draw=brown!10},
		}}

\newcommand{\fputrue}{\pgfkeys{/pgf/fpu=true}}
\newcommand{\fpufalse}{\pgfkeys{/pgf/fpu=false}}
\RequirePackage{tikz}
\usetikzlibrary{fpu}

\newcommand{\maxVal}[3]{
	\pgfkeys{/pgf/fpu}
	\pgfmathsetmacro{#3}{0.0}
	\pgfplotstableforeachcolumnelement{#2}\of#1\as\cellValue{\pgfmathsetmacro{#3}{max(#3,\cellValue)}}
}

\newcommand{\averageVal}[3]{
	\pgfkeys{/pgf/fpu}
	\pgfmathsetmacro{\buffer}{0.0}
	\pgfmathsetmacro{\ibuffer}{0.0}
	\pgfplotstableforeachcolumnelement{#2}\of#1\as\cellValue{\pgfmathsetmacro{\buffer}{\buffer + \cellValue}}
	\pgfplotstableforeachcolumnelement{#2}\of#1\as\cellNumber{\pgfmathsetmacro{\ibuffer}{\ibuffer + 1}}
	\pgfmathsetmacro{#3}{\buffer/\ibuffer}
}

\newcommand{\minVal}[3]{
	\pgfkeys{/pgf/fpu}
	\pgfplotstableforeachcolumnelement{#2}\of#1\as\cellValue{\pgfmathsetmacro{#3}{\cellValue}}
	\pgfplotstableforeachcolumnelement{#2}\of#1\as\cellValue{\pgfmathsetmacro{#3}{min(#3,\cellValue)}}
}

\usepgfplotslibrary{groupplots,units}
\usetikzlibrary{decorations.text, decorations.markings, decorations.pathreplacing}
\usetikzlibrary{arrows.meta}
\usetikzlibrary{backgrounds,scopes}   %<------- Load librariesr)
\usetikzlibrary{shapes.geometric,calc}
\usetikzlibrary{fpu}
\usetikzlibrary{external}
\pgfplotsset{
	add text to legend/.style={
			legend image code/.code={%
					\node[anchor=center] at (0.3cm,0cm) {#1};
				}
		},
}

\pgfkeys{/pgf/number format/.cd,custom exponent/.initial=2}%
\newcommand{\pgfmathprintnumberFE}[2][]{%
	\begingroup
	\pgfkeys{/pgf/number format/.cd,fixed,#1}%
	\pgfset{fpu=true}%
	\pgfmathparse{#2}%
	\pgfmathfloattomacro{\pgfmathresult}{\F}{\M}{\E}%
	\pgfset{fpu=false}%
	\pgfmathtruncatemacro{\redexp}{\E-\pgfkeysvalueof{/pgf/number format/custom exponent}}%
	\ifnum\pgfkeysvalueof{/pgf/number format/custom exponent}=0
		\ensuremath{\pgfmathprintnumber[#1]{\pgfmathresult}}%
	\else
		\pgfmathsetmacro{\newnum}{\M*pow(10,\redexp)}%
		\ensuremath{\pgfmathprintnumber{\newnum}\cdot10^{\pgfkeysvalueof{/pgf/number format/custom exponent}}}%
	\fi
	\endgroup}

\newcommand*\circled[2][1.6]{\tikz[baseline=(char.base)]{
		\node[shape=circle, draw, inner sep=1pt,
			minimum height={\f@size*#1},] (char) {\vphantom{WAH1g}#2};}}
% -------------------------------------------------  Оптика ---------------------------------------------

\tikzset{%
screw/.pic={
		code={\tikzset{scale=1}
				\fill[left color = gray, right color = gray, middle color = white, draw = black] (-0.1, -0.03) rectangle (0.1,0.03);
				\draw (0, -0.03) -- ++(0,0.06);
				\draw (-0.07, -0.03) -- ++(0,0.06)
				(0.07, -0.03) -- ++(0,0.06)
				(0.04, -0.03) -- ++(0,0.06)
				(-0.04, -0.03) -- ++(0,0.06);
				\fill[left color=gray, right color = gray, middle color = white, draw=black] (-0.03, 0.03) rectangle ++(0.06,0.12);
				\foreach \i in {0.05, 0.07, 0.09, 0.11, 0.13} {\draw[ultra thin] (-0.03,\i) -- ++(0.06,0);}
				\coordinate (-top) (0,0.15);
			}},
foot/.pic={
		code={
				\fill[semithick, draw = black, left color=gray, right color = gray, middle color = white] (-0.3,0) rectangle (0.3,0.2);
				\fill[semithick, draw = black, left color=gray, right color = gray, middle color = white] (-0.1,0.2) rectangle (0.1,0.4);
			}},
lava/.pic={
		code ={
				\fill[ultra thick,  left color=gray, right color = gray, middle color = white, draw = black] (-4,-0.2) rectangle (4,0.2);
				\fill[white, draw=black] (-3.8,-0.05) rectangle (3.8,0.05);
				\foreach \i in {-3.8, -3.6,...,3.8} {\draw (\i,-0.05) -- (\i,+0.05);}
				\foreach \i in {-3.7, -3.5,...,3.7} {\draw (\i,-0.05) -- (\i,+0);}
				\pic at (-3,-0.6) {foot};
				\pic at (3,-0.6) {foot};
			}},
reuter/.pic={
		code={\tikzset{scale=1, yshift=0.1cm}
				\pgfmathsetmacro{\ReutThickness}{0.2}
				\fill[semithick, draw = black, left color=gray] (-0.3,0) rectangle (0.3,0.2);
				\draw (0,0) -- (0,0.1);
				\fill[semithick, draw = black, left color=gray, right color = gray, middle color = white] ({-0.5*\ReutThickness},0.2) rectangle ({0.5*\ReutThickness},0.8);
					\pic[rotate=-90] at (-0.25,0.4) {screw};
				\coordinate (-rtop) at (0, 0.8);
			}},
laser/.pic={
		code={
				\begin{scope}[yshift=-1.7cm]
					\fill[semithick, draw = black, left color=gray] (-0.3,0) rectangle (0.3,0.2);
					\draw (0,0) -- (0,0.1);
					\fill[semithick, draw = black, left color=gray, right color = gray, middle color = white] (-0.1,0.2) rectangle (0.1,1.4);
					\pic[rotate=-90] at (-0.25,0.4) {screw};
				\end{scope}
				\fill[semithick, draw = black, bottom color=gray, middle color = white] (-0.8,-0.2) rectangle (0.8,0.2);
				\fill[semithick, gray, draw=black] (0.8,-0.19) -- ++(45:0.1) -- ++(0,0.24) -- ++(135:0.1) -- cycle;
				\fill[semithick, black] (-0.4,-0.25) rectangle (0.4,-0.2);
				\fill[semithick, black] (-0.6,-0.3) rectangle (0.6,-0.25);
				\pic at (-0.5,-0.45)  {screw};
				\fill[semithick, black] (-0.4,-0.42) rectangle (0.4,-0.37);
				\fill[semithick, black] (-0.6,-0.37) rectangle (0.6,-0.32);
				\coordinate  (-top) at (0,0.2);

			}},
difrhole/.pic={
		\pgfmathsetmacro{\DhHeight}{0.6}
		\pgfmathsetmacro{\DhWidth}{0.25}
		\pgfmathsetmacro{\DhThickness}{0.05}
		\pgfmathsetmacro{\DhAngle}{20}
		\pgfmathsetmacro{\DhLine}{\DhWidth*tan(\DhAngle)}
		\pgfmathsetmacro{\ArrWidth}{0.1}
		\pgfmathsetmacro{\ArrHeight}{0.65}


		\begin{scope}[yshift=1.85cm, xshift=-0.02 cm]

			\fill[draw = black, left color=gray, right color = gray, middle color = white, xshift=0.02 cm] (-0.5*\ArrWidth,-0.5*\DhHeight) -- ++(\ArrWidth,0) -- ++(0,-\ArrHeight) -- ++(-\ArrWidth,0) -- cycle;

			\fill[thin, line join=bevel, gray, draw = black] (-0.5*\DhWidth, 0.5*\DhHeight) -- ++(0.04,0.02) -- ++(\DhWidth,-\DhLine) coordinate(-edge) --++(0,-\DhHeight) -- ++(-0.04,-0.02) -- ++(0,\DhHeight) -- cycle (-edge) -- ++(-0.04,-0.02);

			\fill[line join=bevel,gray, draw=black] (-0.5*\DhWidth, 0.5*\DhHeight) -- ++(\DhWidth,-\DhLine) --++(0,-\DhHeight) --++(-\DhWidth,\DhLine) -- cycle;


			\fill[white, draw=black] (0,-0.5*\DhLine) ellipse ({0.1*\DhHeight} and 0.2*\DhHeight);

		\end{scope}
		\pic {reuter};
		%            \coordinate  (-center) at (0,0);
	},
plate/.pic={
		code={
%				\fill[thin, draw = blue, top color = cyan!50, bottom color = cyan!50, middle color = white] (-0.12,-0.6) rectangle (0.12,0.6);
		\pgfmathsetmacro{\PlHeight}{1.5}
		\pgfmathsetmacro{\PlWidth}{0.5}
		\pgfmathsetmacro{\PlThickness}{0.05}
		\pgfmathsetmacro{\PlAngle}{20}
		\pgfmathsetmacro{\PlLine}{\PlWidth*tan(\PlAngle)}
		\pgfmathsetmacro{\ArrWidth}{0.1}
		\pgfmathsetmacro{\ArrHeight}{1}


		\begin{scope}[yshift=1.705cm, xshift=0.02 cm]

			\fill[draw = black, left color=gray, right color = gray, middle color = white, xshift=-0.02 cm] (-0.5*\ArrWidth,-0.5*\ArrHeight) -- ++(\ArrWidth,0) -- ++(0,-\ArrHeight) -- ++(-\ArrWidth,0) -- cycle;



			\fill[line join=bevel,cyan!50, draw=black] (-0.5*\PlWidth, 0.5*\PlHeight)  --++(-0.1,0.05) -- ++(\PlWidth,\PlLine) -- ++(0.1,-0.05) -- ++(-\PlWidth,-\PlLine) --++(0,-\PlHeight) -- ++(-0.1,0.05) --++(0, \PlHeight) -- cycle;



			\fill[line join=bevel,cyan!50, draw=black, left color=cyan!50, right color = cyan!50, middle color = white] (-0.5*\PlWidth, 0.5*\PlHeight) -- ++(\PlWidth,\PlLine) --++(0,-\PlHeight) --++(-\PlWidth,-\PlLine) -- cycle;

            \coordinate (-top) at (0,{0.5*(\PlHeight + \PlLine)}) ;
%            \draw (-0.5*\EcWidth,0) -- ++(\EcWidth,\EcLine);


		\end{scope}
		\pic {reuter};
			}},
biprism/.pic={
code={
        \pgfmathsetmacro{\BPHeight}{0.6}
        \pgfmathsetmacro{\BPWidth}{0.25}
        \pgfmathsetmacro{\BPThickness}{0.05}
        \fill[line join=bevel,gray, draw=black, left color=cyan!50, right color=cyan!50, middle color = white] (0,{0.5*\BPHeight})  -- ++(45:{0.5*\BPWidth/cos(45)}) coordinate (BP1)-- ++(0,-\BPHeight) -- ++(225:{\BPWidth/cos(45)}) coordinate (BP2) -- ++(0,\BPHeight) coordinate (BP3) -- cycle;
        \fill[line join=bevel,gray, draw=black, top color=cyan!50, bottom color=cyan!50, middle color = white] (BP3) -- ++(0.07,0.12) -- (BP1) -- cycle;
        \coordinate  (-top) at (BP1);
        \coordinate  (-center) at (0,0);
%            \fill[thin, draw = blue, top color = cyan!50, bottom color = cyan!50, middle color = white, rounded corners=0.5pt] (-0.3,1.1) coordinate (A) -- (0.3,0.9) coordinate (B) -- (-0.12,0.95) coordinate (C) -- cycle;
%            \fill[yshift=-0.8cm, thin, draw = blue, left color = cyan!50, right color = cyan!50, middle color = white, rounded corners=0.5pt] (-0.3,1.1) coordinate (A1) -- (0.3,0.9) coordinate (B1) -- (-0.12,0.95) coordinate (C1) -- cycle;
%            \fill[thin, draw = blue, left color = cyan!50, right color = white, rounded corners=0.5pt] (A) -- (A1) -- (C1) --  (C) -- cycle;
%            \fill[thin, draw = blue, left color = white, right color =  cyan!50, rounded corners=0.5pt] (B) -- (B1) -- (C1) -- (C) -- cycle;
%%            \coordinate  (-top) at (0,0.32);
%%            \coordinate  (-bottom) at (0.12,-0.32);
%            \coordinate  (-topcenter) at ($(C)!0.5!(C1)$);
%            \coordinate  (-top) at (A);
}},
%ecran/.pic={
%		\pgfmathsetmacro{\EcHeight}{1}
%		\pgfmathsetmacro{\EcWidth}{0.5}
%		\pgfmathsetmacro{\EcThickness}{0.05}
%		\pgfmathsetmacro{\EcAngle}{20}
%		\pgfmathsetmacro{\EcLine}{\EcWidth*tan(\EcAngle)}
%		\pgfmathsetmacro{\ArrWidth}{0.1}
%		\pgfmathsetmacro{\ArrHeight}{0.65}
%
%
%		\begin{scope}[yshift=1.85cm, xshift=-0.02 cm]
%
%			\fill[draw = black, left color=gray, right color = gray, middle color = white, xshift=0.02 cm] (-0.5*\ArrWidth,-0.5*\EcHeight) -- ++(\ArrWidth,0) -- ++(0,-\ArrHeight) -- ++(-\ArrWidth,0) -- cycle;
%
%			\fill[thin, line join=bevel, gray, draw = black] (-0.5*\EcWidth, 0.5*\EcHeight) -- ++(0.04,0.02) -- ++(\EcWidth,-\EcLine) coordinate(-edge) --++(0,-\EcHeight) -- ++(-0.04,-0.02) -- ++(0,\EcHeight) -- cycle (-edge) -- ++(-0.04,-0.02);
%
%			\fill[line join=bevel,gray, draw=black] (-0.5*\EcWidth, 0.5*\EcHeight) -- ++(\EcWidth,-\EcLine) --++(0,-\EcHeight) --++(-\EcWidth,\EcLine) -- cycle;
%
%
%			\fill[white, draw=black] (0,-0.5*\EcLine) ellipse ({0.1*\EcHeight} and 0.2*\EcHeight);
%
%		\end{scope}
%		\pic {reuter};
%		%            \coordinate  (-center) at (0,0);
%	},
ecranlens/.pic={
		\pgfmathsetmacro{\EclHeight}{1.5}
		\pgfmathsetmacro{\EclWidth}{0.5}
		\pgfmathsetmacro{\EclThickness}{0.05}
		\pgfmathsetmacro{\EclAngle}{20}
		\pgfmathsetmacro{\EclLine}{\EclWidth*tan(\EclAngle)}
		\pgfmathsetmacro{\ArrWidth}{0.1}
		\pgfmathsetmacro{\ArrHeight}{1}


		\begin{scope}[yshift=1.705cm, xshift=0.02 cm]

			\fill[draw = black, left color=gray, right color = gray, middle color = white, xshift=-0.02 cm] (-0.5*\ArrWidth,-0.5*\ArrHeight) -- ++(\ArrWidth,0) -- ++(0,-\ArrHeight) -- ++(-\ArrWidth,0) -- cycle;



			\fill[line join=bevel,gray, draw=black] (-0.5*\EclWidth, 0.5*\EclHeight)  --++(-0.04,0.02) -- ++(\EclWidth,\EclLine) -- ++(0.04,-0.02) -- ++(-\EclWidth,-\EclLine) --++(0,-\EclHeight) -- ++(-0.04,0.02) --++(0, \EclHeight) -- cycle;
%
%
%
			\fill[line join=bevel,white, draw=black] (-0.5*\EclWidth, 0.5*\EclHeight) -- ++(\EclWidth,\EclLine) --++(0,-\EclHeight) --++(-\EclWidth,-\EclLine) -- cycle;
%
            \draw (0,{0.5*(\EclHeight + \EclLine)}) -- ++(0,-\EclHeight);
            \coordinate (-eltop) at (0,{0.5*(\EclHeight + \EclLine)}) ;
            \draw (-0.5*\EclWidth,0) -- ++(\EclWidth,\EclLine);
%
  			\fill[draw = black, top color=gray, bottom color = gray, middle color = white] (0,0.13) -- ++(0.3,0) coordinate (-ecledge) --++(0,-0.075) -- ++(-0.3,0) -- cycle;

		\end{scope}
		\pic {reuter};
		%            \coordinate  (-center) at (0,0);
	},
}

\tikzset{%
	add/.style args={#1 and #2}{
			to path={%
					($(\tikztostart)!-#1!(\tikztotarget)$)--($(\tikztotarget)!-#2!(\tikztostart)$)%
					\tikztonodes},add/.default={.2 and .2}}
}


\tikzset{%
	mark coordinate/.style={inner sep=0pt,outer sep=0pt,minimum size=2pt,
			fill=black,circle}%
}

\newcommand\pgfmathsinandcos[3]{%
	\pgfmathsetmacro#1{sin(#3)}%
	\pgfmathsetmacro#2{cos(#3)}%
}
\newcommand\LongitudePlane[2][current plane]{%
	\pgfmathsinandcos\sinEl\cosEl{\Elevation} % elevation
	\pgfmathsinandcos\sint\cost{#2} % azimuth
	\tikzset{#1/.estyle={cm={\cost,\sint*\sinEl,0,\cosEl,(0,0)}}}
}
\newcommand\LatitudePlane[2][current plane]{%
	\pgfmathsinandcos\sinEl\cosEl{\Elevation} % elevation
	\pgfmathsinandcos\sint\cost{#2} % latitude
	\pgfmathsetmacro\ydelta{\cosEl*\sint}
	\tikzset{#1/.estyle={cm={\cost,0,0,\cost*\sinEl,(0,\ydelta)}}} %
}

\newcommand\NewLatitudePlane[4][current plane]{%
	\pgfmathsinandcos\sinEl\cosEl{#3} % elevation
	\pgfmathsinandcos\sint\cost{#4} % latitude
	\pgfmathsetmacro\yshift{#2*\cosEl*\sint}
	\tikzset{#1/.style={cm={\cost,0,0,\cost*\sinEl,(0,\yshift)}}} %
}

\newcommand\DrawLongitudeCircle[1]{
	\LongitudePlane{#1}
	\tikzset{current plane/.prefix style={scale=\R}}
	\pgfmathsetmacro\angVis{atan(sin(#1)*cos(\Elevation)/sin(\Elevation))} %
	\draw[current plane,thin,black]  (\angVis:1)     arc (\angVis:\angVis+180:1);
	\draw[current plane,thin,dashed] (\angVis-180:1) arc (\angVis-180:\angVis:1);
}%

\NewDocumentCommand\DrawLatitudeCircle{O{red}m}{
	\LatitudePlane{#2}
	\tikzset{current plane/.prefix style={scale=\R}}
	\pgfmathsetmacro\sinVis{sin(#2)/cos(#2)*sin(\Elevation)/cos(\Elevation)}
	\pgfmathsetmacro\angVis{asin(min(1,max(\sinVis,-1)))}

	\draw[current plane,thick, line width=1pt, #1, ] (\angVis:1) arc (\angVis:-\angVis-180:1);

	\draw[current plane,line width=1pt, #1, opacity=0.2] (180-\angVis:1) arc (180-\angVis:\angVis:1);
}%

%===============================================================================
%
%									      Налаштування для титульних сторінок
%
%===============================================================================

\newenvironment{alwayssingle}{%
	\thispagestyle{empty}
	\@restonecolfalse
	\if@twocolumn\@restonecoltrue\onecolumn
	\else\if@openright\cleardoublepage\else\clearpage\fi
	\fi}%
{\if@restonecol\twocolumn
	\else\newpage\thispagestyle{empty}\fi
}

\tcbset{%
	titlepagestyle/.style={%
			enhanced,
			colback=themecolordark,
			colframe=themecolorlight,
			arc=0pt,
			outer arc=0pt,
			leftrule=0pt,
			rightrule=0pt,
			enlarge left by=-1in-\hoffset-\oddsidemargin,
			enlarge right by=-\paperwidth+1in+\hoffset+\oddsidemargin+\textwidth,
			width=\paperwidth,
			left=1in+\hoffset+\oddsidemargin,
			right=\paperwidth-1in-\hoffset-\oddsidemargin-\textwidth,
		}%
}%

\ExplSyntaxOn
\RenewDocumentCommand{\title}{m}
{
	\tl_gset:cn { @title } { #1 } % needed by \maketitle
	\tl_gset:Nn { \realtitle } { #1 }
	  \seq_set_split:Nnn \l_tmpa_seq { \\ } { #1 }
	  \tl_gset:Nx \inlinetitle { \seq_use:Nn \l_tmpa_seq { ~ } }
}
\ExplSyntaxOff


%===============================================================================
%
%										   Рубрикація
%
%===============================================================================

\let\cleardoublepage\clearpage

\RequirePackage[pagestyles]{titlesec}


\newcommand\labworklayout{%
	\addtocontents{toc}{\protect\setcounter{tocdepth}{0}}
	\titleformat{\chapter}[display]
	{\Large\bfseries\sffamily}{\filright\normalfont\normalsize Робота\ \thechapter}
	{10pt}{\Large\filcenter}

	\titlespacing{\chapter}{0pt}{0pt}{0pt}
}

\titleformat{\section}
   {\normalfont\large\bfseries}{\thesection.}{1em}{}

\titleformat{\subsection}
   {\normalfont\normalsize\bfseries}{\thesubsection.}{1em}{}

\titlelabel{\thetitle.\quad}
\renewcommand{\thesection}{\arabic{section}}

\RequirePackage{titletoc}
\titlecontents{chapter}% level to be modified
[0pt]{\addvspace{10pt}}%
{Робота\ \thecontentslabel:\ }
{}% for star chapters
{\titlerule*[1pc]{.}\contentspage}



\newpagestyle{main}{%
	\headrule\sethead{\hfill\small Робота\ \thechapter. \chaptertitle\hfill}{}{}
	\setfoot{}{\small\thepage}{}}

\newpagestyle{theorpart}{%
	\headrule\sethead{\hfill\small Теоретична частина\hfill}{}{}
	\setfoot{}{\small\thepage}{}
	\settitlemarks{part}
}



\titleformat{\part}[display]
{\sffamily\bfseries\raggedright}{\LARGE\thepart}{0mm}{\Huge}{}
\titlespacing*{\part}{0mm}{30mm}{30mm}
\titleclass{\part}{top}
\newcommand\partbreak{\bigskip}
\newcommand\chapterbreak{\clearpage}

%===============================================================================
%
%										Підписи під таблицями, рисунками та списки
%
%===============================================================================

\def\tabcaption{\def\@captype{table}\caption}
\def\figcaption{\def\@captype{figure}\caption}
\RequirePackage[inline]{enumitem}
\setlist{nolistsep}


% ------------------------------------------------ Відступи в формулах ----------------------------------

\setlength\abovedisplayskip{1ex}
\setlength\belowdisplayskip{1ex}
\setlength\abovedisplayshortskip{1ex}
\setlength\belowdisplayshortskip{1ex}

% ----------------------------------------- Відступ між написом та рисунком -----------------------------

\setlength{\textfloatsep}{5pt}

% ---------------------------------------- Підписи до рисунку (розмір тексту) ---------------------------

\captionsetup[figure]{font=small,labelfont=small}
\captionsetup[table]{font=small,labelfont=small}

% --------------------------------------------- Bibliography spacing ------------------------------------
\newlength{\bibitemsep}\setlength{\bibitemsep}{.1\baselineskip plus .05\baselineskip minus .05\baselineskip}
\newlength{\bibparskip}\setlength{\bibparskip}{0pt}
\let\oldthebibliography\thebibliography
\renewcommand\thebibliography[1]{%
	\oldthebibliography{#1}%
	\setlength{\parskip}{\bibitemsep}%
	\setlength{\itemsep}{\bibparskip}%
}

%===============================================================================
%
%									Бібіліографія
%
%===============================================================================
\RequirePackage[backend=biber, style=numeric-comp, babel=other, isbn=true, url=false, defernumbers=false]{biblatex}
\AtBeginBibliography{\small}
\newbibmacro{string+url}[1]{%
	\iffieldundef{url}{#1}{\href{\thefield{url}}{#1}}%
}
\DeclareFieldFormat{title}{\usebibmacro{string+url}{#1}}
\renewbibmacro*{begentry}{%
	\iffieldundef{note}
	{\undef\bbxnote}
	{\savefield{note}{\bbxnote}%
		\clearfield{note}}}

\renewbibmacro*{finentry}{%
	\restorefield{note}{\bbxnote}%
	\iffieldundef{note}
	{\finentry}
	{%\setunit{\finentrypunct\par\vspace{\bibitemsep}\nobreak}
		\par\textbf{Рекомендується прочитати: }\printfield{note}%
		\finentry}}





%===============================================================================
%
%										Генеррування преамбули
%
%===============================================================================
\let\@abstract\@empty
\let\@apparatusprint\@empty
\let\@workprint\@empty
\let\@keywordprint\@empty
\let\@apparatusPDFprint\@empty

\DeclareRobustCommand\worktitle[1]{\gdef\@worktitle{#1}}
\newcommand\makeworktitle{\par
	\noindent\hrulefill \\
	\vskip 5\p@
	\noindent{\large\bfseries Мета роботи} \\
	\vskip 5\p@
	\noindent\@abstract
	\vskip 5\p@
	\noindent\@keywordprint
	\vskip 5\p@
	\noindent\@apparatusprint
	\smallskip\noindent\hrulefill\medskip
	\vskip 40\p@
}


\newcommand{\abstract}[1]{\gdef\@abstract{%
		\begingroup
		#1
		\endgroup
	}}

\def\workname{Робота}
\def\apparatusname{Обладнання}

\def\apparatus#1{%
	\if\relax\detokenize{#1}\relax
	\else
		\def\@apparatusPDFprint{#1}
		\def\@apparatusprint{{\bfseries\apparatusname}:\,{\itshape #1}\par}
	\fi
}

\def\work#1{%
	\if\relax\detokenize{#1}\relax
	\else
		\def\@workprint{\workname\hskip1ex#1}
		\def \@worknum{#1}
	\fi
}

\def\keyname{Ключові слова}
\def\keywords#1{%
	\if\relax\detokenize{#1}\relax
	\else
		\def\@keywordPDFprint{#1}
		\def\@keywordprint{{\bfseries\keyname}:\,{\itshape #1}\par}
	\fi
}


%===============================================================================
%
%									Команда вставки задач та відповідей
%
%       https://tex.stackexchange.com/questions/382776/how-to-create-list-and-assign-it-to-variable
%===============================================================================
\ExplSyntaxOn
% ---------------------------------------- Another good solution ----------------------------------------
%\NewDocumentCommand{\multiinclude}{ m O{} }
% {
%  \clist_map_inline:cn {chapter_list_#1_clist} { \InputIfFileExists{##1/##1#2}{}{}\par}
% }

%\NewDocumentCommand{\MakeChapterList}{ m m }
% {
%  \clist_set:cn {chapter_list_#1_clist} { #2 }
% }
% -------------------------------------------------------------------------------------------------------
\NewDocumentCommand{\multiinclude}{ m O{} }
{
	\clist_set:Nx \l_Chapters_clist{ #1 }
	\clist_map_inline:Nn \l_Chapters_clist { \InputIfFileExists{##1/##1#2}{}{}\par}
}

\ExplSyntaxOff
%===============================================================================

%===============================================================================
%
%										            HYPERREF
%
%===============================================================================


\RequirePackage[%
	colorlinks = true,
	linkcolor = red!60!black,
	urlcolor  = blue,
	citecolor = green!60!black,
	bookmarks = true,
	bookmarksnumbered=true,
	unicode,
	linktocpage = true,
	hypertexnames=false,
	pdftoolbar=false,
	pdfpagelayout=TwoPageRight,
	pdfauthor={Ponomarenko S.M.},
	pdfdisplaydoctitle=true,
	pdfkeywords={Electrostatics, Magnetostatics, Electrodynamics, Current, Field},
	pdfencoding=auto
]%
{hyperref}
\RequirePackage[all]{hypcap}
\RequirePackage{bookmark}

% ------------------------------------ Патч для україомовної назви розділу для nameref ------------------ %
\addto\extrasukrainian{%
	\renewcommand{\chapterautorefname}{}%
}
% ------------------------------------------------------------------------------------------------------- %

\ifdefined\inlinetitle%
	\AtBeginDocument{\hypersetup{pdftitle={\inlinetitle}}}
\fi

\endinput
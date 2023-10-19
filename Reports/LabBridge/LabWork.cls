\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{LabWork}[2019/09/25]
\LoadClass[onecolumn, twoside, 14pt]{extarticle}

%------------------------------------------------------------------------------------------------------
\usepackage{ifluatex}
%%                                                                        %%
%%========================== Мови, шрифти та кодування ===================%%
%%
\RequirePackage{amsmath}
\ifluatex                                                                        %%
	\RequirePackage[no-math]{fontspec}
	\setsansfont{CMU Sans Serif}%{Arial}
	\setmainfont{STIX Two Text}%{Times New Roman}
	\setmonofont{CMU Typewriter Text}%{Consolas}
%	\defaultfontfeatures{Ligatures={TeX}}
	\RequirePackage{unicode-math, lualatex-math}
    \setmathfont{STIX Two Math}%{xits-math}
    \RequirePackage{microtype}
\else
	\usepackage[utf8]{inputenc}
	\usepackage[T2A,T1]{fontenc}
	\RequirePackage{mmap}
	\RequirePackage{cmap}
    \renewcommand{\sfdefault}{opensans-LF}
    \renewcommand{\bfdefault}{b}
    \input{glyphtounicode}
    \pdfgentounicode=1
    \RequirePackage[protrusion=true, expansion, tracking=true, kerning=true]{microtype}
\fi
\RequirePackage[english,ukrainian]{babel}


%------------------------------------------------------------------------------------------------------
\bibliographystyle{ugost2008}
\renewcommand{\@biblabel}[1]{#1.}
%------------------------------------------------------------------------------------------------------
\RequirePackage[%
	a4paper,%
	footskip=1cm,%
	headsep=0.3cm,% 
	top=2cm, %поле сверху
	bottom=2cm, %поле снизу
	left=2cm, %поле ліворуч
	right=2cm, %поле праворуч
]{geometry}

\RequirePackage{indentfirst}
\RequirePackage{siunitx}
\RequirePackage{textcomp}
\RequirePackage{multicol}
\RequirePackage{graphicx}
\RequirePackage{wrapfig}
\RequirePackage[justification=centering,labelsep=period]{caption}
\RequirePackage{multirow}
\RequirePackage{makecell}
\RequirePackage{booktabs}
\newcolumntype{C}{>{\centering\arraybackslash}p{5em}}
\RequirePackage[many, most]{tcolorbox}
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
\tcbset{highlight math style={enhanced, colframe=red,
  colback=white,arc=0pt,boxrule=1pt}}
\usetikzlibrary{decorations.pathmorphing}
\usetikzlibrary{shadows}
\usetikzlibrary{circuits.ee.IEC}
\tikzset{circuit ee IEC,
every info/.style=red,
semithick,
every info/.style={font=\footnotesize},
small circuit symbols,
circuit declare symbol = ampermeter,
circuit declare symbol = voltmeter,
circuit declare symbol = galvanometer,
set ampermeter graphic = {draw,generic circle IEC, minimum size=10mm,info=center:A},%
set voltmeter graphic = {draw,generic circle IEC, minimum size=10mm,info=center:V},
set galvanometer graphic = {draw,generic circle IEC, minimum size=10mm,info=center:G},
}
\definecolor{paper}{RGB}{255,255,255}
\newtcolorbox{tornpage}{%
    enhanced jigsaw, breakable, % allow page breaks
    frame hidden, % hide the default frame
    overlay={%
        \draw [
            fill=paper, % fill paper
            draw=paper!50!black, % boundary colour
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

\RequirePackage{pgfplots, pgfplotstable}
\pgfplotsset{
    add text to legend/.style={
        legend image code/.code={%
            \node[anchor=center] at (0.3cm,0cm) {#1};
        }
    },
}
\tikzset{
    partial ellipse/.style args={#1:#2:#3}{
        insert path={+ (#1:#3) arc (#1:#2:#3)}
    }
}
\pgfplotsset{LabPlotGrid/.style={%
    legend style={font=\scriptsize},
	grid = both,
	grid style={line width=.1pt, draw=brown!10},
	major grid style={line width=.2pt,draw=brown!50},
	minor tick num = 5,
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

\usetikzlibrary{decorations.text, decorations.markings, decorations.pathreplacing, decorations.pathmorphing}
\usetikzlibrary{shadows}
\usetikzlibrary{arrows.meta}  
\usetikzlibrary{backgrounds,scopes}   %<------- Load librariesr)
\usetikzlibrary{shapes.geometric,calc}

%------------------------------------------------------------------------------------------------------
\def\tabcaption{\def\@captype{table}\caption}
\def\figcaption{\def\@captype{figure}\caption}
%-------------------Підписи до рисунку (розмір тексту)--------------------------------------------------
\captionsetup[figure]{font=small,labelfont=small}
\captionsetup[table]{font=small,labelfont=small}
\RequirePackage{enumitem}
\setlist{nolistsep}





%-------------------------------------Назви, залежні від мови------------------------------------------
\def\workname{Лабораторна робота з електрики та магентизму}
%------------------------------------------------------------------------------------------------------
\let\phi\varphi
\let\epsilon\varepsilon

\addto\captionsukrainian{%
\def\refname{Перелік літературних джерел}%
}
%------------------------------------------------------------------------------------------------------

\let\@workprint\@empty
\let\@keywordprint\@empty
\let\@groupprint\@empty

\def\work#1{%
	\if\relax\detokenize{#1}\relax
		\else
			\def\@workprint{\workname\hskip1ex\textnumero #1}
			\def \@worknum{#1}
	\fi
}

\def\group#1{%
	\if\relax\detokenize{#1}\relax
		\else
			\def\@groupprint{#1}
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

%------------------------------------Подавление висячих строк------------------------------------------
\clubpenalty =10000
\widowpenalty=10000
%------------------------------------------------------------------------------------------------------
\renewcommand{\theequation}{\arabic{equation}}
\renewcommand{\thefigure}{\arabic{figure}}
\renewcommand{\thetable}{\arabic{table}}
%---------------------------------Redefining sections and title----------------------------------------
\renewcommand\section{\@startsection {section}{1}{\z@}%
                                   {-2ex \@plus -1ex \@minus -.2ex}%
                                   {1.3ex \@plus.2ex}%
                                   {\normalfont\large\bfseries}}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1.5ex \@plus .2ex}%
	                                 {\normalfont\bfseries}}
\RequirePackage{titlesec}
\titlelabel{\thetitle.\quad}
\let\@abstract\@empty
\renewcommand{\abstract}[1]{\gdef\@abstract{%
\begingroup
#1
\endgroup
}}
\date{}
\renewcommand{\@maketitle}{%

\begin{center}
	\@workprint
	\vskip 1em%
	{\large\sffamily\bfseries\MakeUppercase{\@title}}\par%
	\vskip 1.5em%
	\@groupprint \par
	\vskip 1ex%
	\@author
\end{center}%
}
\renewcommand\maketitle{\par
\begingroup
	\@maketitle
	\noindent\hrulefill%\vspace*{-2ex}
	\section*{Мета роботи}
	%{\noindent\large\bfseries\abstractname\par\vskip1em}
	\noindent\small\@abstract
	\par
	\vskip1em
	\noindent\@keywordprint
	\smallskip\noindent\hrulefill\medskip  
\endgroup
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}   



\let\@authortofile\@empty
\newcounter{i}
\setcounter{i}{0}
\def\@separatora{\def\@separatora{, }}% Delay comma once
\let\email\@empty
\newcommand{\addauthor}[3][]{%
  \if\relax\detokenize{#1}\relax	
  \g@addto@macro\@author{\@separatora#2\textsuperscript{#3}}
  \else
	  \g@addto@macro\@author{\@separatora#2\if\relax\detokenize{#3}\relax\else\textsuperscript{#3\@separatora\hskip-0.5ex}\fi\thanks{#1}}
  \fi	 
  \g@addto@macro\@authortofile{\@separator#2}
}

\let\@affiliation\@empty
\def\affiliation#1#2{%
  \g@addto@macro\@affiliation{\par\textsuperscript{#2}{\itshape#1}\smallskip}
}
%-------------------------------definition of newwrite as \writedatatofile-----------------------------
\def\process@authors{\expandafter{\@authortofile\@separator!}}

\def\@separator#1\@separator#2{%
\immediate\write\titleauthorfile{%   
     \string\thispaperauthor{\unexpanded{#1}}}%
\ifx!#2%
\else
 \expandafter\@separator\expandafter#2%
\fi
}%
\newwrite\infofile
\newcommand\writedatatofile[1]{%
  \immediate\openout\infofile=#1.dat
  \immediate\write\infofile{%
     \string\thisworktitle{\unexpanded\expandafter{\@title}}}%

\immediate\write\infofile{%
\string\thisworknomber{\unexpanded\expandafter{\@worknum}}}%

\immediate\closeout\infofile
}
%------------------------------------------------------------------------------------------------------
\let\author\addauthor
\def\ntuu{Національний технічний університет України <<Київський політехнічний інститут>>}
%---------------Відступи в формулах--------------------------------------------------------------------
\g@addto@macro\normalsize{%
	\setlength\abovedisplayskip{1ex}
	\setlength\belowdisplayskip{1ex}
	\setlength\abovedisplayshortskip{1ex}
	\setlength\belowdisplayshortskip{1ex}
}
%-------------------Відступ між написом та рисунком-----------------------------------------------------
\setlength{\textfloatsep}{5pt}
%--------------------Bibliography spacing------------------------------------------------------------------
\newlength{\bibitemsep}\setlength{\bibitemsep}{.1\baselineskip plus .05\baselineskip minus .05\baselineskip}
\newlength{\bibparskip}\setlength{\bibparskip}{0pt}
\let\oldthebibliography\thebibliography
\renewcommand\thebibliography[1]{%
  \oldthebibliography{#1}%
  \setlength{\parskip}{\bibitemsep}%
  \setlength{\itemsep}{\bibparskip}%
}
\RequirePackage{tocloft}
\renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}}
\setlength{\cftbeforesecskip}{1pt}
	\renewcommand{\tableofcontents}{	
		\section*{\MakeUppercase{\contentsname}}
		\begin{multicols}{2}
			\@starttoc{toc}
		\end{multicols}
		\bigskip
	}

%========================================================================================================
%
%									Бібіліографія
%
%========================================================================================================
\RequirePackage[backend=biber, style=gost-numeric, babel=other, isbn=true, url=false, defernumbers=true]{biblatex}
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
		\par\textbf{Please, read the following sections: }\printfield{note}%
		\finentry}}
%------------------------------------------------------------------------------------------------------
\RequirePackage[%colorlinks=true,
	urlcolor = blue, %Colour for external hyperlinks
	%linkcolor  = malina, %Colour of internal links
	citecolor  = green!60!red, %Colour of citations
	bookmarks,
	bookmarksnumbered=true,
	pdftoolbar=false,
	pdfpagelayout=TwoPageRight,
	unicode,
	linktoc = all,
	hypertexnames=false,
	]{hyperref}
		\AtBeginDocument{
		\hypersetup{
			pdfinfo={
			%Author={\@authortoPDFfile},
			Title={\@title},
			}
		}
	}
\endinput
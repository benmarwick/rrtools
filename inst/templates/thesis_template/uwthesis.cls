%  ========================================================================
%  Copyright (c) 1995-2014 The University of Washington
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
%  ========================================================================
%
%
% University of Washington Thesis class
% by Jim Fox
% fox@washington.edu
%
%    For the most recent edition of this class file see:
%         http://staff.washington.edu/fox/tex/
%    or
%         https://github.com/UWIT-IAM/UWThesis.git
%
%
% Version history
%
% 9.01,03/03/15, rename singlespace to uwsinglespace so no collision with setspace style
% 9.00,11/13/14, modify for proquest style.  Adjust sample thesis appropriately
% 8.04,03/06/14, return multi-page abstract to two sided
% 8.03,06/19/12, fix textofChair for co-chairs
% 8.02,04/02/12, Slight mods to fixup title and other fornt pages
% 8.01,03/21/12, Slight modification to title pages
% 8.00,02/03/12, Revise for electronic submission.  Revised title, no signature nor quoteslip
% 7.00,06/27/11, Fix output page bug, add copyright page
% 6.14,07/24/08, Remove large font from abstract title
% 6.14,04/15/08, Re-Fix first page bottom margin; raise quote slip
% 6.13,03/31/08, Fix first page bottom margin;
% 6.12,03/21/07, Better handling of label inside footnote with chapternotes
% 6.11,08/02/06, Bold "abstract", "Page" heading on toc
% 6.10,10/25/05, Fix co-chair lines
% 6.9, 10/25/05, Several small changes for 2005 style guide
% 6.8, 07/26/05, Add some single-spacing in prelim pages
% 6.7, 06/29/05, Remove "by" from abstract page
% 6.6, 06/08/05, Change signature page baseline to 1.0
% 6.5, 03/10/05, Change bibliography baseline to 1.0
% 6.4, 03/09/05, Quote slip copy to "Proquest Information and Learning"
% 6.3, 09/22/04, Add column titles to lof and lot
% 6.2, 07/23/04, Lowercase 'doctoral' in quote slip
% 6.1, 07/08/04, Allow option 'natbib' to load natbib package correctly
% 6.0, 07/14/03, Change names: thesis.xxx -> uwthesis.xxx
% 5.8, 06/12/03, Minor changes to the endnotes pagenation
% 5.7, 08/14/00, Minor changes to the quote slip
% 5.6, 06/19/00, 'Doctorial' -> 'Doctoral'
% 5.5, 05/30/00, New text for quote slips (and 'doctorial' -> 'doctoral')
% 5.4, 10/29/99, Add \xtrafullpage for oneside fullpage figures
% 5.3, 08/09/99, Correct spelling errors in quote slips
% 5.2, 07/20/99, Allow 10pt, 11pt, and 12pt class options
% 5.1, 02/08/99, Add \thesissignaturepage
% 5.0, 01/05/99, Modify for revised uw grad school guidelines
%
% 4.8, 10/22/98, Allow multi-page abstract
%                Allow co-chairs
%                Fix single-sided facing pages (for new latex)
% 4.7, 8/19/98,  Set caption text back to normal size
% 4.6, 3/11/98,  Add default-text quoteslip macros
% 4.5, 7/14/97,  fix \@makefntext to work in math mode
% 4.4, 5/13/97,  change margin calculations (allows non-letter paper)
%                minor reformatting of abstract
%                provide single-spaced captions, footnotes, and quotes
% 4.3, 2/13/97,  allow \\ in text (bug fix)
% 4.2, 8/12/96,  added \@normalsize for setspace.sty (and others?)
% 4.1, 11/6/95,  no page numbers on chapter start for oneside printing
%
% Documentation is in the companion document (uwthesis.tex)
%

\ProvidesClass{uwthesis}[2015/03/03]
\NeedsTeXFormat{LaTeX2e}

%
% footnote stuff for option processing
%

\newwrite\tf@not

\newif\ifproquest\proquestfalse
\DeclareOption{proquest}% sets electrons-only, proquest style
  {\proquesttrue}

\newif\ifendnotes      % true if doing endnotes
  \endnotesfalse
\newif\ifchapternotes  % true if doing chapternotes
  \chapternotesfalse
\let\printchapternotes\relax
\let\printendnotes\relax

\DeclareOption{widebindingmargin}% selects ProQuest style
  {\widebindingmargintrue}  % is the default

\DeclareOption{footnotes}% selects bottom-of-page notes (default)
  {}
\DeclareOption{chapternotes}% selects end-of-chapter notes
  {\chapternotestrue}
\DeclareOption{endnotes}% selects end-of-thesis notes
  {\endnotestrue}

%
% ----  Timely loading of specific packages -----------------------------
%
\newif\if@natbib      % true if including natbib
  \@natbibfalse
\DeclareOption{natbib}% includes natbib package
  {\@natbibtrue}


%
% ----  Thesis is a modified (default 12pt) book style  -----------------
%

\def\@f@ntsize{12pt}
\DeclareOption{10pt}{\def\@f@ntsize{10pt}}
\DeclareOption{11pt}{\def\@f@ntsize{11pt}}
\DeclareOption{12pt}{\def\@f@ntsize{12pt}}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}

\PassOptionsToClass{\@f@ntsize}{book}
\PassOptionsToClass{openany}{book}
\ProcessOptions
\LoadClass{book}

\ifproquest
  \typeout{Formatting for ProQuest}
  \@twosidefalse
  \@openrightfalse
\fi

\if@natbib
  \usepackage{natbib}
\fi

%
% ---- page sizes ----------------------------------------------
%
% margins are 1 inch (72pt) all around,
% except possibly 1.5" at binding
%
% text size computed from paper size
%

\voffset -1in  % undo primitive default margins
\hoffset -1in

\topmargin 72\p@
\headheight 12\p@
\headsep 36\p@
\oddsidemargin 108\p@
\ifproquest\oddsidemargin 72\p@\fi
\oddsidemargin 72\p@
\evensidemargin 72\p@
\newdimen\botmargin
\botmargin 72\p@
\marginparwidth 72\p@
\marginparsep 7\p@
\footskip \z@ % set later
\footnotesep 14\p@
\parindent 1.5em

\textheight\paperheight
  \advance\textheight by-\topmargin
  \advance\textheight by-\headheight
  \advance\textheight by-\headsep
   \advance\textheight by-\footskip
  \advance\textheight by-\botmargin
\textwidth\paperwidth
  \advance\textwidth by-\oddsidemargin
  \advance\textwidth by-\evensidemargin

% ---------------

% set most text to 'double' space
\def\baselinestretch{1.5}    % not quite doublespaced

% make it easier to switch to single-space lines in figures, tables, ...
\def\uwsinglespace{\def\baselinestretch{1.0}\normalfont}

\setcounter{totalnumber}{5}
\setcounter{topnumber}{5}
\renewcommand\topfraction{.7}
\renewcommand\textfraction{.2}
\setlength\floatsep    {18\p@ \@plus 2\p@ \@minus 4\p@}
\setlength\textfloatsep{30\p@ \@plus 2\p@ \@minus 4\p@}
\setlength\intextsep   {20\p@ \@plus 4\p@ \@minus 4\p@}
\let\@normalsize\normalsize  % retain old definition
\setlength\abovecaptionskip{10\p@}
\setlength\belowcaptionskip{10\p@}


%
%  ----  Footnotes  ------------------------------------------
%
% Footnote placement option
%
%   [endnotes] put the references at the thesis end
%   [chapternotes] put the references at the chapter end
%   [footnotes] put the references at the page bottom
%
%   When text is written to file (.not) the source linebreaks
%   are maintained.  This keeps the individual lines in the file short.
%   Control sequences in the note text are not expanded.
%

\let\n@teitem\relax
\def\@n@teitem#1{\def\@currentlabel{#1}\item[#1]}

\def\@chapternotetext{\begingroup
  \catcode`\^^M=12\newlinechar=`\^^M
  \catcode`\\=12
  \d@chapternote}

\long\def\d@chapternote#1{%
  \immediate \write\tf@not
      {\n@teitem{\note@label} #1\relax}%
  \endgroup}

%
\def\@startnotes{%  opens the .not file
  \immediate \openout\tf@not\jobname.not\relax
  \immediate \write\tf@not{\relax}
  \setcounter{footnote}{0}}

%
% chapternotes
%

\ifchapternotes
  % \typeout{Doing chapternotes}
  \let\@footnotetext\@chapternotetext
  \@startnotes
  \def\note@label{\arabic{footnote}}
  \def\printchapternotes{% Prints the accumulated notes
    \ifnum\c@footnote>0
      \clearpage
      \begin{center} Notes to Chapter \arabic{chapter} \end{center}\par
      \addcontentsline{toc}{section}{\protect
          \numberline{}{Notes to Chapter \arabic{chapter}}}
      \begin{description}
      \immediate\closeout\tf@not
      \catcode`@=11
      \let\n@teitem\@n@teitem
      \@input{\jobname.not}
      \end{description}
      \clearpage
      \@startnotes
    \fi
  }
  \let\old@enddocument\enddocument
  \def\enddocument{\printchapternotes\old@enddocument}
\fi

%
% endnotes
%

\ifendnotes
  % \typeout{Doing endnotes}
  \let\@footnotetext\@chapternotetext
  \@startnotes
  \def\note@label{\arabic{chapter}.\arabic{footnote}}
  \def\printendnotes{% Prints the accumulated notes
    \chapter*{Notes}
    \addcontentsline{toc}{chapter}{Notes}
    \thispagestyle{empty}
    \begin{description}
    \immediate\closeout\tf@not
    \catcode`@=11
    \let\n@teitem\@n@teitem
    \@input{\jobname.not}
    \end{description}
    \@startnotes  % allows multiple endnotes
   }
\fi

%
%  bottom-of-page footnotes format
%  full width line and hanging indent
%
\def\footnoterule{\kern-3\p@
 \hrule width \columnwidth \kern 2.6\p@}
\long\def\@makefntext#1{\parindent 1em\noindent \hangindent\parindent
 \uwsinglespace
 \hb@xt@1.8em{\hss\@makefnmark}#1}

%
%  ----  Text pages  ----------------------------------
%
%  In two-sided style Chapter 1 is right handed
%
\def\textofChapter#1{\gdef\@textofChapter{#1}}  \textofChapter{Chapter}
\def\textofAppendix#1{\gdef\@textofAppendix{#1}}  \textofAppendix{Appendix}

\def\textpages{% Start of text pages
     \advance\textheight by\footskip % has to be done before the clearpage
   \clearpage
   \pagestyle{empty}
   \cleardoublepage
   \pagestyle{myheadings}\markboth{}{}
   \def\@chapapp{\protect\@textofChapter}
   \def\Thechapter{\arabic{chapter}}
   \pagenumbering{arabic}
     \footskip\z@
   }

\def\appendix{\par
 \setcounter{chapter}{0}
 \setcounter{section}{0}
 \def\@chapapp{\protect\@textofAppendix}
 \def\Thechapter{\Alph{chapter}}
 \def\thechapter{\Alph{chapter}}}


%
%  Parts
%
\def\@makeparthead#1{ \vspace*{2pc} {\centering
 \ifnum \c@secnumdepth >\m@ne \large Part \thepart \par
 \vspace{10\p@} \fi
  \uwsinglespace
  \large\bf \uppercase\expandafter{#1}\par
 \nobreak \vspace{20\p@}} }
%
\def\@makesparthead#1{ \vspace*{2pc} {\centering
 \large\bf \uppercase\expandafter{#1}\par
 \nobreak \vspace{20\p@}} }
%
\def\part{%
   \printchapternotes
   \if@openright\cleardoublepage\else\clearpage\fi
   % \thispagestyle{empty}%
   \global\@topnum\z@
   \@afterindenttrue
   % \let\\\relax
   \secdef\@part\@spart}
%
%  Complication is added here to allow line breaks
%  in the part titles (via \\).
%
\def\@part[#1]#2{
  \ifnum \c@secnumdepth >\m@ne
  \refstepcounter{part}
  \typeout{<<\thepart>>}
  {\def\\{ }  % allow \\ in title
   \addcontentsline{toc}{part}{\protect
     \numberline{Part\ \thepart:}#1}}\else
  {\def\\{ }  % allow \\ in title
   \addcontentsline{toc}{part}{#1}}\fi
 \addtocontents{lof}{\protect\addvspace{5\p@}}
 \addtocontents{lot}{\protect\addvspace{5\p@}}
 \if@twocolumn
  \@topnewpage[\@makeparthead{#2}]
  \else \@makeparthead{#2}
  \@afterheading \fi}
\def\@spart#1{\if@twocolumn \@topnewpage[\@makesparthead{#1}]
  \else \@makesparthead{#1}
  \@afterheading\fi}


%
%  Chapter headings
%
\def\@makechapterhead#1{ \vspace*{2pc} {\centering
 \ifnum \c@secnumdepth >\m@ne \large \@chapapp{} \Thechapter \par
 \vspace{10\p@} \fi
  \uwsinglespace
  \large\bf \uppercase\expandafter{#1}\par
 \nobreak \vspace{20\p@}} }
%
\def\@makeschapterhead#1{ \vspace*{2pc} {\centering
 \large\bf \uppercase\expandafter{#1}\par
 \nobreak \vspace{20\p@}} }
%
\def\chapter{%
   \printchapternotes
   \if@openright\cleardoublepage\else\clearpage\fi
   % \thispagestyle{empty}%
   \global\@topnum\z@
   \@afterindenttrue
   % \let\\\relax
   \secdef\@chapter\@schapter}
%
%  Complication is added here to allow line breaks
%  in the chapter titles (via \\).
%
\def\@chapter[#1]#2{
  \ifnum \c@secnumdepth >\m@ne
  \refstepcounter{chapter}
  \typeout{<<\thechapter>>}
  {\def\\{ }  % allow \\ in title
   \addcontentsline{toc}{chapter}{\protect
     \numberline{\@chapapp\ \thechapter:}#1}}\else
  {\def\\{ }  % allow \\ in title
   \addcontentsline{toc}{chapter}{#1}}\fi
 \addtocontents{lof}{\protect\addvspace{5\p@}}
 \addtocontents{lot}{\protect\addvspace{5\p@}}
 \if@twocolumn
  \@topnewpage[\@makechapterhead{#2}]
  \else \@makechapterhead{#2}
  \@afterheading \fi}
\def\@schapter#1{\if@twocolumn \@topnewpage[\@makeschapterhead{#1}]
  \else \@makeschapterhead{#1}
  \@afterheading\fi}
%
%  Section headings
%
\renewcommand\section{%
  \@startsection {section}{1}{\z@}%
       {-3.5ex \@plus -1ex \@minus -.2ex}%
       {2.3ex \@plus.2ex}%
       {\def\baselinestretch{1.0}\reset@font\normalsize\bfseries\slshape}}
\renewcommand\subsection{%
  \@startsection{subsection}{2}{\z@}%
       {-3.25ex\@plus -1ex \@minus -.2ex}%
       {1.5ex \@plus .2ex}%
       {\reset@font\normalsize\mdseries\itshape}}
\renewcommand\subsubsection{%
  \@startsection{subsubsection}{3}{\z@}%
       {-3.25ex\@plus -1ex \@minus -.2ex}%
       {1.5ex \@plus .2ex}%
       {\reset@font\normalsize\mdseries\itshape}}

% part
\renewcommand\l@part[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \vskip 1.0em \@plus\p@
    \setlength\@tempdima{75\p@}%
    \@dottedtocline{0}{\z@}{\@tempdima}{#1}{#2}%
  \fi}

%
%  Provide for `Chapter ' in the toc
%  (increase \@tempdima)
%
\renewcommand\l@chapter[2]{%
  \ifnum \c@tocdepth >\m@ne
    \addpenalty{-\@highpenalty}%
    \vskip 1.0em \@plus\p@
    \setlength\@tempdima{75\p@}%
    \@dottedtocline{0}{\z@}{\@tempdima}{#1}{#2}%
  \fi}

%
% extra space between toc entries
%
\def\@dottedtocline#1#2#3#4#5{%
  \ifnum #1>\c@tocdepth \else
    \vskip -\baselineskip % \@plus.2\p@%
    \vskip 1.2\baselineskip
    {\leftskip #2\relax \rightskip \@tocrmarg \parfillskip -\rightskip
     \parindent #2\relax\@afterindenttrue
     \interlinepenalty\@M
     \leavevmode
     \@tempdima #3\relax
     \advance\leftskip \@tempdima \null\nobreak\hskip -\leftskip
     {#4}\nobreak
     \leaders\hbox{$\m@th
        \mkern \@dotsep mu\hbox{.}\mkern \@dotsep
        mu$}\hfill
     \nobreak
     \hb@xt@\@pnumwidth{\hfil\normalfont \normalcolor #5}%
     \par}%
  \fi}

%
% ------ Special captions ---------------------
%
% \caption[]{text} produces normal caption and numbering
% \caption(-){(continued)} produces `(continued)' caption and
%        same-as-last caption number
% \caption(x)[]{text} produces lettered caption.  1.1a, 1.1b, ...
%        If (x) is (a) or (A) then caption number is incremented,
%        else it is same numbered.

\def\thecaptionletter{}
\newif\ifcaptiontotoc\captiontotoctrue

\def\caption{\@ifnextchar({\@specialcaption}{\@normalcaption}}

\def\@normalcaption{\refstepcounter\@captype \@dblarg{\@caption\@captype}}
\def\@specialcaption(#1){%
  \def\thecaptionletter{#1}%
  \captiontotocfalse
  \if#1-\def\thecaptionletter{}\fi
  \if#1a\refstepcounter\@captype\captiontotoctrue\fi
  \if#1A\refstepcounter\@captype\captiontotoctrue\fi
  \@dblarg{\@caption\@captype}}

\long\def\@caption#1[#2]#3{\par
  \ifcaptiontotoc
    \addcontentsline{\csname
    ext@#1\endcsname}{#1}{\protect\numberline{\csname
    the#1\endcsname}{\ignorespaces #2}}%
  \fi
  \begingroup
    \@parboxrestore
    \def\baselinestretch{1.0}
    \normalsize  % UW grad school doesn't allow \footnotesize
    \@makecaption{\csname fnum@#1\endcsname
        \thecaptionletter}{\ignorespaces #3}\par
  \endgroup}

\def\@listI{\leftmargin\leftmargini \parsep 7\p@ plus 3\p@ minus 1\p@\topsep
 12\p@ plus 5\p@ minus 6\p@\itemsep 7\p@ plus 3\p@ minus 1\p@}


%
%  ----  Facing pages and double-page figures and tables
%
%  \begin{fullpage} ... \end{fullpage}
%  \begin{leftfullpage} ... \end{leftfullpage}
%  \begin{xtrafullpage} ... \end{xtrafullpage}

\newif\if@LP \@LPfalse
\newif\if@XP \@XPfalse

\newbox\@@wholepage
\def\fullpage{\setbox\@@wholepage=\vbox\bgroup}
\def\endfullpage{\egroup\dp\@@wholepage\z@
   \vbox to\textheight{\vss\unvbox\@@wholepage\vss}}
\def\leftfullpage{\setbox\@@wholepage=\vbox\bgroup}
\def\endleftfullpage{\egroup\dp\@@wholepage\z@
   \vbox to\textheight{\vss\unvbox\@@wholepage\vss}\global\@LPtrue}

\if@twoside
   \typeout{Formatting for twoside printing.}
   \let\xtrafullpage\fullpage
   \let\endxtrafullpage\endfullpage
\else
   \def\xtrafullpage{\setbox\@@wholepage=\vbox\bgroup}
   \def\endxtrafullpage{\egroup\dp\@@wholepage\z@
      \vbox to\textheight{\vss\unvbox\@@wholepage\vss}\global\@XPtrue}
\fi

\let\oldend@float\end@float
\def\end@float{%
  \if@LP\global\@namedef{LP:\expandafter\string\@currbox}{L}%
  \else \global\@namedef{LP:\expandafter\string\@currbox}{z}%
  \fi
  \if@XP\global\@namedef{XP:\expandafter\string\@currbox}{X}%
  \else \global\@namedef{XP:\expandafter\string\@currbox}{z}%
  \fi
  \global\@LPfalse
  \global\@XPfalse
  \oldend@float
}


\if@twoside

% reject a left-side float that appears on an odd page
 \let\old@xtryfc\@xtryfc
 \def\@xtryfc #1{%
   \expandafter\if\csname LP:\string#1\endcsname L%
      % \typeout{facing page in xtryfc}%
      \ifodd\count0\global\@colht\z@
          \typeout{I moved a leftpage float from page \the\count0.}%
      \fi\fi
    \old@xtryfc #1}

\else

\def\unstep@page{\addtocounter{page}{-1}}

% flip a facing page caption
 \let\@oldwtryfc\@wtryfc
 \def\@wtryfc #1{%
  \expandafter\if\csname LP:\string#1\endcsname L\gdef\LP@page{}%
      \typeout{Encountered a facing page.}%
   \fi
  \expandafter\if\csname XP:\string#1\endcsname X\gdef\XP@page{}%
      \typeout{Encountered an extra page.}%
   \fi
   \@oldwtryfc #1}

 \let\old@outputpage\@outputpage
 \def\@outputpage{%
   \begingroup
   \@ifundefined{LP@page}
     {\let\@themargin\oddsidemargin \let\@thehead\@oddhead}
     {\let\@themargin\evensidemargin \let\@thehead\@evenhead
       \typeout{Printing a left-hand one-side page.}%
       \global\let\LP@page\relax
      }
   \@ifundefined{XP@page}
     {}
     {\let\@thehead\@empty \let\@thefoot\@empty
       \typeout{Printing an extra page.}%
       \global\let\XP@page\relax
       \aftergroup\unstep@page
      }
   \old@outputpage\endgroup
 }
\fi

%
%  ----  Preliminary pages  ---------------------------
%
\def\prelimpages{ % sets page numbering for the preliminary pages
   \pagestyle{empty} % will be {plain} at start of toc
   \pagenumbering{roman}
   \setcounter{page}{1}
   \footskip 30\p@ % allowance for the roman page numbers
    \advance\textheight by-\footskip
   }
%
%      (The following macros are used once and discarded)
%
%  Title page
%
%  (Defaults are for dissertation.  See \MasterThesis below.)
%
\def\Title#1{\gdef\@Title{#1}}
\def\Author#1{\gdef\@Author{#1}}
\def\Year#1{\gdef\@Year{#1}}  \Year{\year}
\def\Degree#1{\gdef\@Degree{#1}} \Degree{Doctor of Philosophy}
\def\Program#1{\gdef\@Program{#1}} \Program{your program here}
%
\def\School#1{\gdef\@School{#1}} \School{University of Washington}
\def\GSchool#1{\gdef\@GSchool{#1}} \GSchool{Graduate School}
\def\Degreetext#1{\gdef\@Degreetext{#1}}
  \Degreetext{A dissertation\\ submitted in partial fulfillment of the\\requirements for the degree of}
\def\Programtext#1{\gdef\@Programtext{#1}}
       \Programtext{Program Authorized to Offer Degree: }

\def\textofCommittee#1{\gdef\@textofCommittee{#1}}
       \textofCommittee{Reading Committee: }
\def\textofDate#1{\gdef\@textofDate{#1}}  \textofDate{Date}

\def\textofChair#1{\gdef\@textofChair{#1}}
       \textofChair{Chair of the Supervisory Committee: }

\newcount\@Chair \@Chair0
\def\Chair#1#2#3{
  \global\@namedef{C:\expandafter\the\@Chair}{#1}
  \global\@namedef{T:\expandafter\the\@Chair}{#2}
  \global\@namedef{D:\expandafter\the\@Chair}{#3}
  \ifnum\@Chair>0\textofChair{Co-Chairs of the Supervisory Committee:}\fi
  \global\advance\@Chair by1}


\newcount\@Sign\@Sign0
\def\Signature#1{
  \global\@namedef{S:\expandafter\the\@Sign}{#1}
  \global\advance\@Sign by1}

\def\copyrightpage{                   % Prints the copyright page
    \vspace{7pc}
    \begin{center}
      \par\vskip\z@ plus4fill\relax
      \copyright Copyright \@Year
      \par
      \@Author
      \par\vskip\z@ plus2fill\relax
    \end{center}
  \let\copyrightpage\relax\relax}

\def\titlepage{                   % Prints the title page
    \cleardoublepage
    \vspace{7pc}
    \begin{center}
      {\uwsinglespace\Large
      \lineskip 3ex
      \@Title\par}
      \par\vskip\z@ plus4fill\relax
      \@Author
      \par\vskip\z@ plus4fill\relax
      {\uwsinglespace
      \@Degreetext\par}
      \par\vskip\z@ plus2fill\relax
      \@Degree
      \par\vskip\z@ plus2fill\relax
      \@School
      \par\vskip\z@ plus1fill\relax
      \@Year
      \par\vskip\z@ plus4fill\relax

      % signers
      \@textofCommittee \par
      \count1=0
      \@whilenum \count1<\@Chair \do
       {\vskip12\p@ \baselineskip12pt
        \csname C:\the\count1\endcsname, Chair
        \advance\count1 by1}
      \count1=0
      \@whilenum \count1<\@Sign \do
       {\vskip12\p@ \baselineskip12pt
        \csname S:\the\count1\endcsname
        \advance\count1 by1}

      \par\vskip\z@ plus4fill\relax
       {\uwsinglespace
      \@Programtext \par \@Program\par}
      \par\vskip\z@ plus1fill\relax
    \end{center}
     \vspace{2pc}\relax
  \let\titlepage\relax}


%
%   Abstract
%
%  normal parameters
\def\textofAbstract#1{\gdef\@textofAbstract{#1}}  \textofAbstract{Abstract}

\newsavebox\abs@savebox% (\abs@savebox compliments of blerner@cs.washington.edu)
\long\def\abstract#1{
   \cleardoublepage
   \begin{center}
      \@School
      \par\vskip1pc
      {\bf\@textofAbstract}%
      \par\vskip1pc
      {\uwsinglespace \@Title \par}
      \par\vskip1pc
      \@Author
      \par\vskip1pc
       {\uwsinglespace
      \@textofChair
      \par
      \count1=0
      \@whilenum \count1<\@Chair \do
       {% \vskip12\p@ \baselineskip12pt
        \csname T:\the\count1\endcsname\ \csname C:\the\count1\endcsname
        \par \csname D:\the\count1\endcsname\par\vskip6\p@
        \advance\count1 by1}
       \par}
      \par\vskip1pc
   \end{center}
%  if you need single sided abstract pages uncomment this section and the next
%   \if@twoside
%    \begingroup % have to set multiple abstract pages 1-sided
%    \def\@blankpage{\if\@@blankpage B
%            \setbox\abs@savebox\box255\shipout\vbox{}\setbox255\box\abs@savebox
%            \global\advance\count\z@ by1\fi
%            \global\def\@@blankpage{B}}
%    \def\@@blankpage{A}
%    \output=\expandafter{\expandafter\@blankpage\the\output}
%   \fi
   #1
   \vfill\clearpage
%   \if@twoside\endgroup\fi
   \let\abstract\relax}
%
%
%   Table of contents (right side page) (always page `i')
%
%
\def\textofToC#1{\gdef\@textofToC{#1}}  \textofToC{Table of Contents}
\def\tableofcontents{\cleardoublepage
   \chapter*{\@textofToC\@mkboth{}{}}
   \pagestyle{plain}
   \thispagestyle{plain}
   \setcounter{page}{1}
   \hbox to\textwidth{\hfill Page}
   {\let\footnotemark\relax  % in case one is in the title
    \uwsinglespace
   \@starttoc{toc}
    }
   }
%
%   List of figures
%

\def\textofLoF#1{\gdef\@textofLoF{#1}}  \textofLoF{List of Figures}
\def\listoffigures{\chapter*{\@textofLoF\@mkboth{}{}}
   \thispagestyle{plain}
   \addcontentsline{toc}{chapter}{\protect\@textofLoF}
   \hbox to\textwidth{Figure Number \hfill Page}
   {\let\footnotemark\relax  % in case one is in the title
    \uwsinglespace
   \@starttoc{lof}
    }
   }
%
%   List of tables
%
\def\textofLoT#1{\gdef\@textofLoT{#1}}  \textofLoT{List of Tables}
\def\listoftables{\chapter*{\@textofLoT\@mkboth{}{}}
   \thispagestyle{plain}
   \addcontentsline{toc}{chapter}{\protect\@textofLoT}
   \hbox to\textwidth{Table Number \hfill Page}
   {\let\footnotemark\relax  % in case one is in the title
    \uwsinglespace
   \@starttoc{lot}
    }
   }
%
%  Bibliography
%
\def\textofBIB#1{\gdef\@textofBIB{#1}}  \textofBIB{Bibliography}
\def\thebibliography#1{\chapter*{\@textofBIB\@mkboth{}{}}
 \addcontentsline{toc}{chapter}{\protect\@textofBIB}
 \list
 {[\arabic{enumi}]}{\settowidth\labelwidth{[#1]}\leftmargin\labelwidth
 \advance\leftmargin\labelsep
 \usecounter{enumi}}
 \def\newblock{\hskip .11em plus .33em minus .07em}
 \sloppy\clubpenalty4000\widowpenalty4000
 \uwsinglespace
 \sfcode`\.=1000\relax}

%
%   Acknowledgments
%
\def\textofAck#1{\gdef\@textofAck{#1}}  \textofAck{Acknowledgments}
\long\def\acknowledgments#1{\chapter*{\@textofAck\@mkboth{}{}}
   \thispagestyle{plain}
   #1\par
   \vfill
   \let\acknowledgments\relax}

%
%   Dedication
%
\def\textofDed#1{\gdef\@textofDed{#1}}  \textofDed{Dedication}
\long\def\dedication#1{\chapter*{\@textofDed\@mkboth{}{}}
   \thispagestyle{plain}
   #1\par
   \vfill
   \let\dedication\relax}

%
%   Vita
%
\def\textofVita#1{\gdef\@textofVita{#1}}  \textofVita{Vita}
\long\def\vita#1{\chapter*{\@textofVita\@mkboth{}{}}
   #1\par
   \vfill
   \let\vita\relax}

%
%   Gratis definition of a glossary environment
%
\renewenvironment{glossary}
  {\begin{list}{}{\setlength\itemindent{\parindent}
   \def\makelabel##1{\footnotesize\uppercase{##1:}\hfill}\uwsinglespace}}
  {\end{list}}

%
%  Colophon
%
% %  normal parameters, based on abstract
% \def\textofColophon#1{\gdef\@textofColophon{#1}}  \textofColophon{Colophon}
%
% \newsavebox\col@savebox
% \long\def\colophon#1{
%    \cleardoublepage
%    #1
%    \vfill\clearpage
%    \let\colophon\relax}
% %
\def\colophon{                   % Prints the colophon page
    \cleardoublepage
    \vspace{7pc}
     \vspace{2pc}\relax
  \let\colophon\relax}


% End of the thesis style

%% Stuff from https://github.com/suchow/Dissertate



\RequirePackage{color}
\RequirePackage[tiny, md, sc]{titlesec}
% \usepackage[hidelinks]{hyperref}
\setlength{\headheight}{15pt}
\pagestyle{plain}
\RequirePackage{titling}
\RequirePackage[palatino]{quotchap}

\RequirePackage{graphicx}
\RequirePackage{amssymb}
\RequirePackage{lettrine}

\RequirePackage{fancyhdr}

\usepackage[titletoc]{appendix}
\renewcommand{\setthesection}{\arabic{chapter}.A\arabic{section}}

\RequirePackage{setspace}
\RequirePackage{booktabs}
\RequirePackage[tight,nice]{units}
\RequirePackage{verbatim}
\setcounter{tocdepth}{1}

 \RequirePackage{url}
 \usepackage[titles]{tocloft}
\setlength{\cftchapnumwidth}{10em}
\setlength{\cftsubsecnumwidth}{10em}
 \renewcommand\cftpartnumwidth{10em}
 \renewcommand{\cftsecleader}{\cftdotfill{\cftdotsep}}
 \renewcommand{\cftchapfont}{\normalsize \scshape}
 \usepackage{ragged2e}


\RequirePackage{mathspec}
\setmathsfont(Digits,Latin,Greek)[Numbers={Proportional}]{EB Garamond}
\setmathrm{EB Garamond}


\defaultfontfeatures{Mapping=tex-text}
\newfontfamily{\smallcaps}[RawFeature={c2sc,scmp}]{EB Garamond}
\defaultfontfeatures{Ligatures=TeX}
%% \setmainfont[Numbers=OldStyle, Contextuals=Alternate, Ligatures={Common, Rare, Historical}]{EB Garamond}
\setmainfont[Numbers=OldStyle, Contextuals=Alternate, Ligatures={Common}]{EB Garamond}
\setsansfont[Scale=MatchLowercase, BoldFont={Lato Bold}]{Lato Regular}
\setmonofont[Scale=MatchLowercase]{Source Code Pro}



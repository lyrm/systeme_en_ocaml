
slides/main.pdf: slides/*.tex
	xelatex slides/main.tex
	mv main.pdf slides/

all: slides/main.pdf

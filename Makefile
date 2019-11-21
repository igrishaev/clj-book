
all: pdf-build pdf-open

pdf-build:
	pdflatex -shell-escape -halt-on-error main.tex

pdf-open:
	open main.pdf

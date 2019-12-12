
all: git-commit pdf-build pdf-open

git-commit:
	git rev-parse --short HEAD > .commit

pdf-build:
	pdflatex -shell-escape -halt-on-error main.tex

pdf-open:
	open main.pdf

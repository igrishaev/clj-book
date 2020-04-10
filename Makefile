
PWD = $(shell pwd)
PYG := /usr/local/lib/python2.7/site-packages/pygments

all: pyg-clear git-commit pdf-build pdf-open

.PHONY: index
index:
	cd makeindex && clojure -m makeindex.core ${PWD}/main.idx ${PWD}/main.ind

pyg-install:
	ln -s ${PWD}/print.py ${PYG}/styles/

pyg-clear:
	rm -rf _minted-main

git-commit:
	git rev-parse --short HEAD > .commit

pdf-build:
	pdflatex -shell-escape -halt-on-error main.tex

pdf-open:
	open main.pdf

stats:
	find . -name '*.tex' | xargs wc -cl

warnings:
	egrep -A 1 -B 1 -i 'overfull|underfull' main.log

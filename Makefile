
PWD = $(shell pwd)
PYG := /usr/local/lib/python2.7/site-packages/pygments

all: git-commit pdf-build1

build: clear git-commit pdf-build1 pdf-build2 index pdf-build3 pdf-open

.PHONY: index
index:
	cd makeindex && clojure -m makeindex.core ${PWD}/main.idx ${PWD}/main.ind

.PHONY: clear
clear:
	rm -f *.aux
	rm -f *.ilg
	rm -f *.idx
	rm -f *.ind
	rm -f *.log
	rm -f *.pdf
	rm -f *.toc
	rm -rf _minted-main

pyg-install:
	ln -s ${PWD}/print.py ${PYG}/styles/

git-commit:
	git rev-parse --short HEAD > .commit

pdf-build1 pdf-build2 pdf-build3:
	pdflatex -shell-escape -halt-on-error main.tex

pdf-open:
	open main.pdf

stats:
	find . -name '*.tex' | xargs wc -cl

.PHONY: full
full:
	egrep -A 1 -B 1 -i 'overfull|underfull' main.log

.PHONY: warn
warn:
	grep -A 1 -B 1 -i 'Warning' main.log

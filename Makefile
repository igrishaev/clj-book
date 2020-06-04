
PWD = $(shell pwd)
PYG := /usr/local/lib/python2.7/site-packages/pygments
DOC = main

# default draft build
.PHONY: draft
draft: pdf-build1

# release build
.PHONY: build
build: clear pdf-build1 index pdf-build2 pdf-build3 lines refs pdf-open

.PHONY: index
index:
	cd makeindex && clojure -m makeindex.core ${PWD}/${DOC}.idx ${PWD}/${DOC}.ind

.PHONY: clear
clear:
	rm -f *.aux
	rm -f *.ilg
	rm -f *.idx
	rm -f *.ind
	rm -f *.log
	rm -f ${DOC}.pdf
	rm -f *.toc
	rm -f *.pyg
	rm -rf _minted-${DOC}
	rm -f *.out

pyg-install:
	ln -s ${PWD}/print.py ${PYG}/styles/

pdf-build1 pdf-build2 pdf-build3:
	envsubst < ${DOC}.tex | pdflatex -shell-escape -halt-on-error -jobname=${DOC}

pdf-open:
	open ${DOC}.pdf

stats:
	find . -name '*.tex' | xargs wc -ml

.PHONY: lines
lines:
	! grep -A 0 -B 0 -i 'in paragraph at lines' ${DOC}.log

.PHONY: warn
warn:
	! grep -A 0 -B 0 -i 'Warning' ${DOC}.log

.PHONY: refs
refs:
	! grep -A 0 -B 0 -i 'LaTeX Warning: Reference' ${DOC}.log

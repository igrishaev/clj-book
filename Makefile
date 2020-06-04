
PWD = $(shell pwd)
PYG := /usr/local/lib/python2.7/site-packages/pygments
DOC = main

# default draft build
.PHONY: draft
draft: config pdf-build1

# release build
.PHONY: build
build: clear config pdf-build1 index pdf-build2 pdf-build3 lines refs pdf-open

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
	rm -f config.tex

pyg-install:
	ln -s ${PWD}/print.py ${PYG}/styles/

pdf-build1 pdf-build2 pdf-build3:
	pdflatex -shell-escape -halt-on-error ${DOC}.tex

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

.PHONY: config
config:
	source ./ENV && envsubst < config.tpl.tex > config.tex


PWD = $(shell pwd)

# default draft build
.PHONY: draft
draft: pdf-build1

# release build
.PHONY: build
build: clear pdf-build1 index pdf-build2 pdf-build3 refs lines tag-job pdf-open

.PHONY: tag-job
tag-job:
	cp ${JOB}.pdf ${JOB}_${COMMIT_HASH}_${COMMIT_TS}.pdf

.PHONY: index
index:
	cd makeindex && clojure -m makeindex.core ${PWD}/${JOB}.idx ${PWD}/${JOB}.ind

.PHONY: clear
clear:
	rm -f *.aux
	rm -f *.ilg
	rm -f *.idx
	rm -f *.ind
	rm -f *.log
	rm -f ${JOB}.pdf
	rm -f *.toc
	rm -f *.pyg
	rm -rf _minted-*
	rm -f *.out

pyg-print-install:
	cd ./pyg_print && python setup.py install

pdf-build1 pdf-build2 pdf-build3:
	envsubst < main.tex | pdflatex -shell-escape -halt-on-error -jobname=${JOB}

pdf-open:
	open ${JOB}.pdf

stats:
	find . -name '*.tex' | xargs wc -ml

.PHONY: lines
lines:
	! grep -A 0 -B 0 -i 'in paragraph at lines' ${JOB}.log

.PHONY: warn
warn:
	! grep -A 0 -B 0 -i 'Warning' ${JOB}.log

.PHONY: refs
refs:
	! grep -A 0 -B 0 -i 'LaTeX Warning: Reference' ${JOB}.log

IMAGE := clj-book

.PHONY: docker-build
docker-build:
	docker build -t ${IMAGE}:ubuntu -f Dockerfile.ubuntu .
	docker build -t ${IMAGE}:build .

.PHONY: docker-run
docker-run:
	docker run -it --rm -v $(CURDIR)/book:/book -w /book ${IMAGE}:build pdflatex --shell-escape test.tex

.PHONY: docker-build-draft
docker-build-draft:
	docker run -it --rm -v $(CURDIR)/:/book -w /book ${IMAGE}:build make draft

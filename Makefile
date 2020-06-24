
PWD = $(shell pwd)

COMMIT_HASH = $(shell git log -1 --format='%h')
COMMIT_TS = $(shell git log -1 --format='%at')

# default draft build
.PHONY: draft
draft: pdf-build1

# release build
.PHONY: build
build: clear pdf-build1 index pdf-build2 pdf-build3 refs lines tag-job

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
	COMMIT_HASH=${COMMIT_HASH} \
	COMMIT_TS=${COMMIT_TS} \
	envsubst < main.tex | pdflatex -shell-escape -halt-on-error -jobname=${JOB}

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
	docker run -it --rm \
	-e COMMIT_HASH=${COMMIT_HASH} \
	-e COMMIT_TS=${COMMIT_TS} \
	--env-file=ENV \
	--env-file=ENV_PRINT \
	-v $(CURDIR)/:/book \
	-w /book \
	${IMAGE}:build \
	make draft

.PHONY: docker-build-kindle
docker-build-kindle:
	docker run -it --rm \
	-e COMMIT_HASH=${COMMIT_HASH} \
	-e COMMIT_TS=${COMMIT_TS} \
	--env-file=ENV \
	--env-file=ENV_KINDLE \
	-v $(CURDIR)/:/book \
	-w /book \
	${IMAGE}:build \
	make build

.PHONY: docker-build-clean
docker-build-clean:
	docker run -it --rm -v $(CURDIR)/:/book -w /book ${IMAGE}:build make build

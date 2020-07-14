
PWD = $(shell pwd)

COMMIT_HASH = $(shell git log -1 --format='%h')
COMMIT_TS = $(shell git log -1 --format='%at')

# default draft build
.PHONY: draft
draft: pdf-build1


.PHONY: add-cover
add-cover:
ifdef COVER
	cp ${JOB}.pdf ${JOB}-1.pdf
	pdftk A=${JOB}-1.pdf B=${COVER} cat B A output ${JOB}.pdf
	rm ${JOB}-1.pdf
endif


.PHONY: pre-build
pre-build: clear pdf-build1 index pdf-build2 pdf-build3 add-cover refs

# release build
.PHONY: build
build:  pre-build lines tag-job

.PHONY: mobile-build
mobile-build: pre-build tag-job

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

.PHONY: docker-build-prepare
docker-build-prepare:
	make pyg-print-install
	./install-fonts.sh
	cd ./makeindex && clojure -Stree

IMAGE := clj-book

.PHONY: docker-build
docker-build-images:
	docker build -t ${IMAGE}:ubuntu -f Dockerfile.ubuntu .
	docker build -t ${IMAGE}:build .

DOCKER_BUILD_PRE = \
	docker run -it --rm \
	-e COMMIT_HASH=${COMMIT_HASH} \
	-e COMMIT_TS=${COMMIT_TS} \
	--env-file=ENV

DOCKER_BUILD_POST = -v $(CURDIR)/:/book -w /book ${IMAGE}:build
DOCKER_BUILD_POST_BUILD = ${DOCKER_BUILD_POST} make build
DOCKER_BUILD_POST_MOBILE_BUILD = ${DOCKER_BUILD_POST} make mobile-build

.PHONY: docker-build-draft
docker-build-print-draft:
	${DOCKER_BUILD_PRE}	\
	--env-file=ENV_PRINT \
	${DOCKER_BUILD_POST} make draft

.PHONY: docker-build-ridero
docker-build-ridero:
	${DOCKER_BUILD_PRE}	\
	--env-file=ENV_PRINT \
	--env-file=ENV_RIDERO \
	${DOCKER_BUILD_POST_BUILD}

.PHONY: docker-build-print
docker-build-print:
	${DOCKER_BUILD_PRE}	\
	--env-file=ENV_PRINT \
	${DOCKER_BUILD_POST_BUILD}

.PHONY: docker-build-tablet
docker-build-tablet:
	${DOCKER_BUILD_PRE}	\
	--env-file=ENV_TABLET \
	${DOCKER_BUILD_POST_BUILD}

.PHONY: docker-build-kindle
docker-build-kindle:
	${DOCKER_BUILD_PRE}	\
	--env-file=ENV_KINDLE \
	${DOCKER_BUILD_POST_MOBILE_BUILD}

.PHONY: docker-build-phone
docker-build-phone:
	${DOCKER_BUILD_PRE}	\
	--env-file=ENV_PHONE \
	${DOCKER_BUILD_POST_MOBILE_BUILD}

.PHONY: docker-build-gumroad
docker-build-gumroad: docker-build-print docker-build-tablet docker-build-phone docker-build-kindle

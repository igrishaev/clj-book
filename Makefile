
PWD = $(shell pwd)

COMMIT_HASH = $(shell git log -1 --format='%h')
COMMIT_TS = $(shell git log -1 --format='%at')


#
# Checks the log for underfull/overfull warnings.
# For narrow displays, only check overfull.
#
check-lines:
ifdef NARROW
	! grep -i 'Overfull' ${JOB}.log
else
	! grep -i 'in paragraph at lines' ${JOB}.log
endif


draft: \
	pdf-build1


build: \
	clear-files pdf-build1 make-index pdf-build2 pdf-build3 \
	check-refs check-lines


## Build an index file with Clojure.
make-index:
	cd makeindex && \
	clojure -m makeindex.core ${PWD}/${JOB}.idx ${PWD}/${JOB}.ind


# Drop unused files.
clear-files:
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

clear-pdf:
	rm -f *.pdf

#
# A common LaTeX build command with three aliases
#
pdf-build1 pdf-build2 pdf-build3:
	COMMIT_HASH=${COMMIT_HASH} \
	COMMIT_TS=${COMMIT_TS} \
	envsubst < main.tex | pdflatex -shell-escape -halt-on-error -jobname=${JOB}


#
# Check if there are any missing references inside the doc.
#
check-refs:
	! grep -i 'LaTeX Warning: Reference' ${JOB}.log


IMG = clj-book
IMG_SYS = ${IMG}:ubuntu
IMG_RUN = ${IMG}:build


docker-build-ubuntu:
	docker build --no-cache -t ${IMG_SYS} -f Dockerfile.ubuntu .


docker-build-image:
	docker build --no-cache -t ${IMG_RUN} .


docker-build-images: docker-build-ubuntu docker-build-image


DOCKER_RUN = \
	docker run -it --rm \
	-v $(CURDIR)/:/book \
	-w /book \
	-e COMMIT_HASH=${COMMIT_HASH} \
	-e COMMIT_TS=${COMMIT_TS} \
	--env-file=ENV

DOCKER_DRAFT = ${DOCKER_RUN} --env-file=ENV_DRAFT

MAKE_BUILD = ${IMG_RUN} make build
MAKE_DRAFT = ${IMG_RUN} make draft


#
# Print
#

docker-build-print:
	${DOCKER_RUN} --env-file=ENV_PRINT ${MAKE_BUILD}


docker-build-print-draft:
	${DOCKER_DRAFT} --env-file=ENV_PRINT ${MAKE_DRAFT}


#
# Ridero
#

docker-build-ridero:
	${DOCKER_RUN} --env-file=ENV_RIDERO ${MAKE_BUILD}

docker-build-ridero-draft:
	${DOCKER_DRAFT} --env-file=ENV_RIDERO ${MAKE_DRAFT}


#
# Ridero large
#

docker-build-ridero-large:
	${DOCKER_RUN} --env-file=ENV_RIDERO_LARGE ${MAKE_BUILD}

docker-build-ridero-large-draft:
	${DOCKER_DRAFT} --env-file=ENV_RIDERO_LARGE ${MAKE_DRAFT}


#
# Kindle
#

docker-build-kindle:
	${DOCKER_RUN} --env-file=ENV_KINDLE ${MAKE_BUILD}

docker-build-kindle-draft:
	${DOCKER_DRAFT} --env-file=ENV_KINDLE ${MAKE_DRAFT}


#
# Phone
#

docker-build-phone:
	${DOCKER_RUN} --env-file=ENV_PHONE ${MAKE_BUILD}

docker-build-phone-draft:
	${DOCKER_DRAFT} --env-file=ENV_PHONE ${MAKE_DRAFT}


#
# Tablet
#

docker-build-tablet:
	${DOCKER_RUN} --env-file=ENV_TABLET ${MAKE_BUILD}

docker-build-tablet-draft:
	${DOCKER_DRAFT} --env-file=ENV_TABLET ${MAKE_DRAFT}


#
# Gumroad bundle
#

docker-build-gumroad: \
	docker-build-print \
	docker-build-tablet \
	docker-build-phone \
	docker-build-kindle


#
# ALL bundle
#

docker-build-all: \
	docker-build-ridero-large \
	docker-build-ridero \
	docker-build-gumroad


#
# Local debug
#

show-stats:
	find . -name '*.tex' | xargs wc -ml


check-urls:
	./check-urls.sh


lines-kindle:
	! grep -i 'Overfull' clojure_kindle.log


lines-phone:
	! grep -i 'Overfull' clojure_phone.log


lines-ridero-large:
	! grep -i 'in paragraph at lines' clojure_ridero_large.log

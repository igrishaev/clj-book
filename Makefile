
PWD = $(shell pwd)

COMMIT_HASH = $(shell git log -1 --format='%h')
COMMIT_TS = $(shell git log -1 --format='%at')


#
# Adds a cover to the final PDF file
#
add-cover:
ifdef COVER
	mv ${JOB}.pdf ${JOB}.tmp.pdf
	pdftk A=${JOB}.tmp.pdf B=${COVER} cat B A output ${JOB}.pdf
	rm ${JOB}.tmp.pdf
endif


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
	pdf-build1 make-index


build: \
	clear-files pdf-build1 make-index pdf-build2 pdf-build3 \
	add-cover tag-job check-refs check-lines


#
# Make a copy of a PDF file with its commit hash
# and timestamp being included in the name.
#
tag-job:
	cp ${JOB}.pdf ${JOB}_${COMMIT_HASH}_${COMMIT_TS}.pdf


## Build an index file with Clojure.
make-index:
	cd makeindex && bb --classpath src \
		--main makeindex.core \
		${PWD}/${JOB}.idx ${PWD}/${JOB}.ind


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


docker-build-images:
	docker build -t ${IMG_SYS} -f Dockerfile.ubuntu .
	docker build -t ${IMG_RUN} .


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


docker-build-gumroad: \
	docker-build-print \
	docker-build-tablet \
	docker-build-phone \
	docker-build-kindle


#
# Image build duties
#

pyg-print-install:
	cd ./pyg_print && python setup.py install


docker-build-prepare:
	make pyg-print-install
	./install-fonts.sh


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

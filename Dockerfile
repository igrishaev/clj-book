# Book-related stuff

FROM clj-book:ubuntu

RUN mkdir /workdir
WORKDIR /workdir

COPY ./pyg_print ./pyg_print
COPY ./makeindex ./makeindex
COPY ./install-fonts.sh ./
COPY ./Makefile ./
RUN make docker-build-prepare

WORKDIR /
RUN rm -rf /workdir

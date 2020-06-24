# Book-related stuff

FROM clj-book:ubuntu



RUN mkdir /workdir
WORKDIR /workdir

COPY pyg_print ./pyg_print
COPY Makefile ./
RUN make pyg-print-install
COPY ./install-fonts.sh ./
RUN ./install-fonts.sh

WORKDIR /
RUN rm -rf /workdir

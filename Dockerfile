# Book-related stuff

FROM clj-book:ubuntu

RUN mkdir /workdir
WORKDIR /workdir

COPY ./pyg_print ./pyg_print
COPY ./install-fonts.sh ./

RUN cd ./pyg_print && python setup.py install
RUN ./install-fonts.sh

WORKDIR /
RUN rm -rf /workdir

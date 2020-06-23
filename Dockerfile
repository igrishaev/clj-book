FROM ubuntu:18.04

ENV TZ=Europe/Moscow

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y \
    texlive-latex-extra \
    make \
    gettext \
    python \
    python-setuptools \
    python-pygments \
    texlive-lang-cyrillic \
    texlive-fonts-extra

RUN mkdir /workdir
WORKDIR /workdir

COPY pyg_print ./pyg_print
COPY Makefile ./

RUN make pyg-print-install

WORKDIR /
RUN rm -rf /workdir

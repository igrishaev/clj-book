FROM ubuntu:18.04
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install -y texlive-latex-extra make gettext python python-setuptools python-pygments texlive-lang-cyrillic texlive-fonts-extra

RUN mkdir /cljbook
WORKDIR /cljbook
COPY . ./
RUN make pyg-print-install
CMD cd book && pdflatex --shell-escape test.tex

FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y\
   curl \
   git \
   bash \
   sudo \
   zsh \
   wget \
   locales \
   powerline \
   language-pack-en

RUN update-locale

RUN useradd -m m.herhold && echo "m.herhold:test" | chpasswd && adduser m.herhold sudo
WORKDIR /home/m.herhold

USER m.herhold
COPY ../backup/restore.sh .
COPY ../backup/main.py .
COPY 2021_10_08_myBackup.tar.gz bitbucket/myProjects/python/myBackup/2021_10_08_myBackup.tar.gz

CMD ["python3","main.py","restore" ]

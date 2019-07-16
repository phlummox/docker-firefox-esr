
FROM debian:bullseye
MAINTAINER phlummox <phlummox2@gmail.com>

RUN printf '###### Debian Main Repos\n\
deb http://ftp.au.debian.org/debian/ testing main contrib non-free\n#\
deb-src http://ftp.au.debian.org/debian/ testing main contrib non-free\n\
\n\
deb http://ftp.au.debian.org/debian/ testing-updates main contrib non-free\n#\
deb-src http://ftp.au.debian.org/debian/ testing-updates main contrib non-free\n\
\n'\
> /etc/apt/sources.list


RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
      aptitude    \
      apt-transport-https     \
      bash                    \
      ca-certificates         \
      curl                    \
      dbus-x11                \
      dirmngr                 \
      firefox-esr             \
      gnupg-agent             \
      gpg                     \
      locales                 \
      tzdata                  \
      wget && \
  rm -rf /var/lib/apt/lists/*

# gosu, because sudo and su hardly ever do
# just what you want
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

## timezone, locales
RUN \
  echo "Australia/Perth" | tee /etc/timezone && \
  sed -i -e 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
  locale-gen

ENV \
  LANG=en_AU.UTF-8               \
  LANGUAGE=en_AU.UTF-8           \
  LC_ALL=en_AU.UTF-8             \
  LC_ADDRESS=en_AU.UTF-8         \
  LC_IDENTIFICATION=en_AU.UTF-8  \
  LC_MEASUREMENT=en_AU.UTF-8     \
  LC_MONETARY=en_AU.UTF-8        \
  LC_NAME=en_AU.UTF-8            \
  LC_NUMERIC=en_AU.UTF-8         \
  LC_PAPER=en_AU.UTF-8           \
  LC_TELEPHONE=en_AU.UTF-8       \
  LC_TIME=en_AU.UTF-8



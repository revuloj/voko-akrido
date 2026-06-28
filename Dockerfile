#### staĝo 1: certigu, ke vi antaŭe kompilis voko-grundo aŭ ŝargis de Github kiel pakaĵo
ARG VERSION=latest
FROM ghcr.io/revuloj/voko-grundo/voko-grundo:${VERSION} as grundo

#xxx staĝo 2: kreu procezujon surbaze de Swi-Prolog
# kun la swipl-debian-procezujo ni spertis cimon (stak-eraro kun http 503)
# ĝi devus esti korektita en estontaj eldonoj 10.2.x, sed ni trovis, ke
# ubuntu+swi-prolog-nox ankaŭ ŝparas 100MB das procezuja grandeco
# FROM swipl:stable

#### staĝo 2: kreu procezujon surbaze de Ubuntuo + Swi-Prolog
FROM ubuntu:noble

# Kreu kaj lanĉu per:
#   docker build -t voko-akrido .
#   docker run -p8081:8081 voko-akrido

RUN apt-get update && apt-get install -y --no-install-recommends \
    lynx xsltproc unzip curl ca-certificates openssh-client rsync \
# en Ubunto ni devas aldone instali kaj agordi UTF-8      
    swi-prolog-nox locales \
	&& rm -rf /var/lib/apt/lists/* \
# agordi lokaĵaron por UTF-8      
  && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

RUN useradd -ms /bin/bash -u 1088 akrido
WORKDIR /home/akrido

# utf-8-lokaĵaro por krei la vortaron
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

ADD . ./

COPY --from=grundo build/ /home/akrido/voko/

RUN  ln -s voko/xsl xsl && ln -s voko/dtd dtd && ln -s voko/owl owl \
  && mkdir xml && mkdir txt && mkdir tmp \
  && bin/xml_download.sh && bin/revo_radikoj.sh \
  && rm xml/* && chown akrido.akrido xml txt tmp \
# Pro pli da kontrolo ni mane plenigis .ssh/known_hosts per 
# ssh-keyscan ${AKRIDO_HOST} > .ssh/known_hosts && ssh-keyscan 85.214.67.151 >> .ssh/known_hosts 
# ŝajne ambaŭ IP kaj servilo-nomo estas bezonataj tie...
# Oni povus tion ankaŭ aŭtomate fari en Dockerfile RUN...
  && chown -R akrido.akrido .ssh && chmod 700 .ssh && chmod 400 .ssh/* 


#USER root

# Vi povas uzi la procezujon (Docker container) laŭ pluraj eblecoj:
#
# 1) Kiel analizilo por Vortaro-artikoloj:
#    metu la artikolojn kiel teksto sub ~revo/txt (vd. malsupre)
#    analizu la tekstojn (analizu_revo*.sh)
# 
#  - Por krei la tekstojn en ~revo/txt necesas Perl + xsltproc + lynx:
#    [$VOKO/bin/aktualigu_per_rss.pl;] $VOKO/bin/xml2txt.pl
#
# 2) Kiel analizo-servo, tiel ekz. uzata de Cetonio - la redaktilo por
#    kontroli unupan artikolon (run-anasrv-revo.sh)
#    ekz.: docker run -it voko/akrido /home/revo/prolog/run-anasrv-revo.sh
#    
#    http://localhost:8091/analizo?teksto=cxevalo

USER akrido:users
WORKDIR /home/akrido/pro

# Ubuntu: ŝaltu UTF8-lokaĵaron por la retservo
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

CMD ["swipl",\
    "-s","analizo-servo.pl","-g","daemon","-t","halt(1)",\
    "--","--workers=10","--port=8081","--no-fork"]

#CMD ["swipl",\
#    "-s","pro/analizo-servo.pl","-g","daemon","-t","halt(1)",\
#    "-p","agordo=etc","--","--workers=10","--port=8081","--no-fork"]

#
# 3) Por krei vortaron per revo_radikoj.sh.
#    Necesas la XML-tekstoj en ~revo/xml - vi povas munti de ekstere
#    kaj voko.rdf pro la vort-klasoj

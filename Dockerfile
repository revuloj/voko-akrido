FROM swipl:stable

# Kreu kaj lanĉu per:
#   docker build -t voko-akrido .
#   docker run -p8081:8081 voko-akrido

# FARENDA:
#
# Kiel aktualigi la rezultopaĝojn post analizo?
# ĉu per rettranssendo (scp, rsync, git...?)
#

RUN apt-get update && apt-get install -y --no-install-recommends \
    lynx xsltproc unzip curl ca-certificates openssh-client rsync \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash -u 1088 akrido
WORKDIR /home/akrido

ADD . ./

RUN curl -LO https://github.com/revuloj/voko-grundo/archive/master.zip \
  && unzip master.zip voko-grundo-master/xsl/* voko-grundo-master/dtd/* voko-grundo-master/owl/* \
  && rm master.zip && ln -s voko-grundo-master/xsl xsl \
  && ln -s voko-grundo-master/dtd dtd && ln -s voko-grundo-master/owl owl \
# Pro pli da kontrolo ni mane plenigis .ssh/known_hosts per 
# ssh-keyscan ${AKRIDO_HOST} > .ssh/known_hosts && ssh-keyscan 85.214.67.151 >> .ssh/known_hosts 
# ŝajne ambaŭ IP kaj servilo-nomo estas bezonataj tie...
# Oni povus tion ankaŭ aŭtomate fari en Dockerfile RUN...
  && chown -R akrido.akrido .ssh && chmod 700 .ssh && chmod 400 .ssh/*

RUN  mkdir xml && mkdir txt && mkdir tmp \
    && bin/xml_download.sh && bin/revo_radikoj.sh \
    && rm xml/* && chown akrido.akrido xml txt tmp

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

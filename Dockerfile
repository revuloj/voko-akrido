FROM swipl:stable

# Kreu kaj lanĉu per:
#   docker build -t voko-akrido .
#   docker run -p8081:8081 voko-akrido

# FARENDA:
#
# Ĉar la skripto por prepari Revo-artikol-tekstojn funkcias per Perl
# (vd. sub bin/analizu_revo_* + elfiltru_rovojn.perl)
# verŝajne estus bone dismeti ambaŭ funkcojn al diversaj kestoj.
# Eble oni povas uzi du-fazan-kestigon, sed tiel fariĝus la
# tekstoj nur unufoje - oni ja volas regule aktualigi la
# artikolojn kaj la vortaron... do verŝajne pli bone
# havi unu aktualigan kaj unu kontrolan parton
# Necesas elpensi kiel la kontrola parto ricevas la rezultojn
# de la aktualiga - ekz. per komuna dosierujo aŭ
# per rettranssendo (scp, rsync, git...?)
#
# Principe oni povus ankaŭ reverki la transforman Perlo-skripton
# en Prologo aŭ Bash kaj uzi unu keston por ĉiuj tri taskoj ekz. lanĉante
# apartan instancon por ĉiu tasko.

RUN apt-get update && apt-get install -y --no-install-recommends \
    lynx xsltproc unzip curl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash -u 1088 akrido
WORKDIR /home/akrido

ADD . ./

RUN curl -LO https://github.com/revuloj/voko-grundo/archive/master.zip \
  && unzip master.zip voko-grundo-master/xsl/* voko-grundo-master/dtd/* voko-grundo-master/owl/* \
  && rm master.zip && ln -s voko-grundo-master/xsl xsl \
  && ln -s voko-grundo-master/dtd dtd && ln -s voko-grundo-master/owl owl

RUN  mkdir xml && mkdir txt && mkdir tmp \
    && bin/xml_download.sh && bin/revo_radikoj.sh \
    && rm xml/* && chown akrido.akrido xml txt tmp

#USER root

# Vi povas uzi la keston (Docker container) laŭ pluraj eblecoj:
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

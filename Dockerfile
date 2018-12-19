FROM swipl:stable

# FARENDA:
#
# Ĉar la skripto por prepari tekstojn funkcias per Perl
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
# en Prologo kaj uzi unu keston por ĉiuj tri taskoj ekz. lanĉante
# apartan instancon por ĉiu tasko.

RUN apt-get update && apt-get install -y --no-install-recommends \
    lynx xsltproc unzip curl \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash -u 1088 akrido
USER akrido:users
WORKDIR /home/akrido

ADD . ./

RUN curl -LO https://github.com/revuloj/voko-iloj/archive/master.zip \
  && unzip master.zip voko-iloj-master/xsl/ voko-iloj-master/dtd/ voko-iloj-master/owl/ \
  && ln -s voko-iloj-master/xsl xsl && ln -s voko-iloj-master/dtd dtd && ln -s voko-iloj-master/owl owl

RUN  mkdir xml && mkdir txt && mkdir tmp \
    && bash download_and_xml2txt.sh \
    && bash revo_radikoj.sh

USER root

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

CMD ["swipl",\
    "-s","prolog/analizo-servo.pl",\
    "-g","daemon","-t","halt",\
    "-p","agordo=etc","--",\
    "--workers=10","--user=akrido","--port=8081","--no-fork"]

#
# 3) Por krei vortaron per revo_radikoj.sh.
#    Necesas la XML-tekstoj en ~revo/xml - vi povas munti de ekstere
#    kaj voko.rdf pro la vort-klasoj
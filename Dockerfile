FROM swipl:stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    lynx xsltproc \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash -u 1088 akrido
USER akrido:users
WORKDIR /home/akrido

RUN  mkdir xml && mkdir txt
ADD . prolog/

USER root

# Vi povas uzi la konteneron laŭ pluraj eblecoj:
#
# 1) Kiel analizilo por Vortaro-artikoloj:
#    metu la artikolojn kiel teksto sub ~revo/txt (vd. malsupre)
#    analizu la tekstojn (analizu_revo*.sh)
# 
#  - Por krei la tekstojn en ~revo/txt necesas xsltproc + lynx:
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
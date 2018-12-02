FROM swipl:stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    lynx xsltproc \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash -u 1001 revo
USER revo:users

RUN ls /home/ && mkdir /home/revo/xml && mkdir /home/revo/txt
ADD . /home/revo/prolog/

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
    "-s","/home/revo/prolog/analizo-servo.pl",\
    "-g","http_unix_daemon:http_daemon","-g","halt","-t","'halt(1)'",\
    "-p","agordo=/home/revo/etc",\
    "--user=revo","--port=8081","--no-fork"]

#
# 3) Por krei vortaron per revo_radikoj.sh.
#    Necesas la XML-tekstoj en ~revo/xml - vi pvoas munti de ekstere
#    kaj voko.rdf pro la vort-klasoj
# voko-akrido

Vortanalizilo, kiu uzas gramatikon. Uzata por kontroli Revo-artikolojn.

Tio estas vortanalizilo por Esperantaj vortoj uzanta gramatikon por limigi misanalizojn kaj eviti troan tolerecon. Eble kelkaj vortoj tial ne analiziĝas, sed la celo estas trovi erarajn vortojn, eĉ se estas kelkaj
malĝustaj plendoj.

Okazas nun provoj restrukturi la redaktilon de Reta Vortaro kiel servetoj (`docker`-procezujoj), 
do aldoniĝis `Dockerfile`. Restas sufiĉe da laboro por alĝustigi la detalojn, sed oni jam
povas konstrui la procezujon.

Reta vortaro troviĝas tie: http://retavortaro.de

## Pri la nomo

La nomo "akrido" elektiĝis pro ioma aliteracio kun analizo kaj pro la besteta inklino ĉion dishaki kaj vori... :-)

##  Kiel uzi la analizilon

Prepare vi bezonas eble aktualan vortaron. Ĝi estas farita el stabila baza vortaro kaj la XML-tekstoj de Revo-artikoloj. El la artikoloj nur la kapvortoj (radikoj) estas konsiderataj ne derivitaj vortoj - por tio ni uzas la gramatikon. Sed la algoritmo provas diveni vortspecon ks. el la indikoj en la vortara artikolo.

Por krei aktualan vortaron vi ŝargas la XML-tekstojn de Revo (`bin/xml_download.sh`) kiu metas ilin loke en dosierujon xml/ kaj poste vokas la skripton `bin/revo_radikoj.sh`. Se vi uzas `docker build`... tio estas jam parto de la aŭtomata procedo.

### Komandlinio

Por analizi unuopajn vortojn aŭ tekst-dosierojn vi povas uzi la komandlinion:
```
    $ cd pro
    $ swipl analizilo.pl
    ?- vortanalizo(malsanulejo,A,S).
    A = 'mal·sanᶠ·ul·ej·o',
    S = subst

    ?- vortanalizo(poŝtelefonanto,A,S).
    A = 'poŝᶠ-telefon¹·ant·o',
    S = best
```
  Do kiel vi vidas malsanulejo estas derivaĵo per afiksoj el la fundamenta radiko "san". Dum poŝtelefonanto estas kunmetita vorto el fundamenta "poŝ" kaj "telefon", trovebla en la unua oficiala aldono. Gramatike la analizilo ne distingas homojn de aliaj bestoj.

  Por sencimigi vi povas voki antaŭe:
```
  ?- debug(analizo).
  ?- debug(gramatiko).
```
  La lastan vi foje devas voki dufoje, verŝajne pro la meta-transformado la unuan fojon la sencimiga temo `gramatiko` ne estas trovata.


### Aŭtomata kontrolo de Revo-artikolo

Ni precipe uzas la analizilon por trovi erarojn en la Revo-artikoloj. Por tio servas skripto `bin/xml2txt.pl`,
  kiu unue transformas la XML-fontojn al HTML kaj poste helpe de teksta retumilo `lynx` al simpla teksto. Poste ni analizos tiujn tekstojn per la skriptoj `bin/analizu_revo_*`. Tio jam estas kunmetita en la skripto ./akrido kaj aŭtomate okazas ĉiunokte en Github per la tasko
  `.github/workflows/nightly-analysis.yml`

### Serva interfaco (REST/JSON)

Ni ofertas ankaŭ servan interfacon, kiu estas uzata de la redaktilo por fone sendi la tekston de artikolo 
  kaj rericevi la erarojn kaj kontrolendajn vortojn. 

### Retpaĝo

 Fine, ni ellaboris retinterfacon uzebla de homo por enigi tekston por analizado. Se vi havas `docker` vi povas
 uzi la simplan retpaĝon loke en via koputilo:
 ```
 docker build -t voko-akrido .
 docker run -p8081:8081 voko-akrido
```

Poste iru al `http://localhost:8081`

Alternative vi povas instali SWI-Prologon kaj voki
  ```
    $ cd pro
    $ swipl analizo-servo.pl
    ?- server(8081).
  ```

### Instalado kiel konstanta servo en Linukso

Por tio servas la dosiero akrido.service, kiun vi povas uzi kun `systemd`-bazita sistemo. Krome vi devas zorgi, ke la vortaro regule rekreiĝu el Reta Vortaro. Por tio vi povas instali `cron`-taskon, kiu vokas:
  ```
  bin/xml_download.sh && bin/revo_radikoj.sh
  ```
Poste necesas relanĉi la servon (`systemctl restart akrido.service`). Tion kompreneble vi ankaŭ povas difini kiel `cron`-taskon, ekz-e unu- aŭ du horojn post la aktualigo.

## Iom pri la historio

Ĉirkaŭ la jaro 1996, detalojn mi ne memoras, estis diskuto kun Simono Pejno, kiel realigi vortanalizilon por
ekhavi iom pli inteligentan ortografian kontrolilon, kiu scias ne nur pri finaĵoj, sed ankaŭ ekz-e pri afiksoj.
Parto de lia baza vortaro kaj kelkaj ideoj fluis en unuan simplan vortanalizilon, per kiu mi lernis la belan programlingvon Prologo. La rezultanta programo tamen tiutempe ne estis tre utila al mi pro limigita kapacito
de tiamaj komputiloj kaj malfacileco de Prologo tiutempe interfaci kun aliaj aplikaĵoj - solaj eblecoj ŝajnis aŭ legi tekston koditan laŭ Prologo el dosiero aŭ legi dosieron signon post signo unue analizante ĝian sintakson kaj ekstrakti la informojn.

En 2012 mi remalkovris Prologon, lige al mia programarĥitekta laboro, kiel lingvo por lerte labori kun informmodeloj kaj trovis, ke la lingvo en la realigo de `SWI-Prolog` multe evoluis, precipe pri subteno de HTTP, XML, JSON, RDF ktp. kiujn oni bezonas por interfaci kun aliaj aplikaĵoj. En 2014 mi komencis reverki la vortanalizilon. Kiel 2a ŝtupo de la analizo mi aldonis rekombinan paŝon, kiu atentas, al kiuj vortspecoj sufikso povas aplikiĝi, kaj kiuspeca estas la rezulto.
Krome mi distingis la diversajn vortformadajn metodojn: derivado, kunderivado, kunmetado k.a. (vd ĉe la gramatika parto en `pro/gra/`). Poste por plia efikeco mi kombinis la bazan disanalizon kaj pli inteligentan rekombinon en
kombinita analizo per gramatiko, kiu uzas sian propran gramatik-lingvon, kiu per la meta-lingvaj rimedoj de 
Prologo, en la komenco de la programo estas transformata al ordinaraj predikatoj, kiuj realigas la aplikadon de la
analizo.

Krome aldoniĝis skripto, kiu eltiras la vortojn kaj radikojn el Reta Vortaro komplementante la bazan vortaron.
La rezulta aplikaĵo ekuziĝis por kontroli artikolojn en Reta Vortaro je vortoj, kiuj ne estas analizeblaj aŭ
dubindaj, tiel trovante kaj erarojn kaj mankantajn en Revo radikojn. Fine de 2020 aldoniĝis ankoraŭ markado de oficialeco ĉe la uzataj radikoj kaj vortelementoj, kaj ankaŭ retpaĝo por trakribri iun ajn tekston aŭ retpaĝon je nekonataj al Revo vortoj.



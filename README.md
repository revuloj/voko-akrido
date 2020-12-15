# voko-akrido
Vortanalizilo, kiu uzas gramatikon. Uzata por kontroli Revo-artikolojn.

Tio estas vortanalizilo por Esperantaj vortoj uzanta gramatikon por limigi misanalizojn kaj eviti troan tolerecon. Eble kelkaj vortojn tial ne analiziĝas, sed la celo estas trovi erarajn vortojn, eĉ se estas kelkaj
malĝustaj plendoj.

Okazas nun provoj restrukturi la redaktilon de Reta Vortaro kiel servetoj (`docker`-procezujoj), 
do aldoniĝis `Dockerfile`. Restas sufiĉe da laboro por alĝustigi la detalojn, sed oni jam
povas konstrui la procezujon.

Reta vortaro troviĝas tie: http://retavortaro.de

## Pri la nomo
La nomo "akrido" elektiĝis pro ioma aliteracio kun analizo kaj pro la besteta inklino ĉion dishaki kaj vori... :-)

##  Kiel uzi la analizilon

Prepare vi bezonas eble aktualan vortaron. Ĝi estas farita el stabila baza vortaro kaj la XML-tekstoj de Revo-artikoloj. El la artikoloj nur la kapvortoj (radikoj) estas konsiderataj ne derivitaj vortoj - por tio ni uzas la gramatikon. Sed la algoritmo provas diveni vortspecon ks. el la indikoj en la artikolo.

Por krei aktualan vortaron vi ŝargas la XML-tekstojn de Revo (`xml_download.sh`) kaj metas ilin loke en dosierujon xml/ kaj poste vokas la skripton `revo_radikoj.sh`. Se vi uzas `docker build`... tio estas jam parto de la aŭtomata procedo.

### Komandlinio

Por analizi unuopajn vortojn aŭ tekst-dosierojn vi povas uzi la komandlinion:
```
    cd pro
    swipl analizilo.pl
    ?- vortanalizo(malsanulejo,A,S).
    A = 'mal·san^*·ul·ej·o',
    S = subst

    ?- vortanalizo(poŝtelefonanto,A,S).
    A = 'poŝ^*-telefon^1·ant·o',
    S = best
```
  Do kiel vi vidas malsanulejo estas derivaĵo per afiksoj el la fundamenta radiko "san". Dum poŝtelefonanto estas kunmetita vorto el fundamenta "poŝ" kaj "telefon", trovebla en la unua oficiala aldono. Gramatike la analizilo ne distingas homojn de aliaj bestoj.

### Aŭtomata kontrolo de Revo-artikolo
Ni precipe uzas la analizilon por trovi erarojn en la Revo-artikoloj. Por tio servas skripto `xml2txt.pl`,
  kiu unue transformas la XML-fontojn al HTML kaj poste helpe de teksta retumilo `lynx` al simpla teksto. Poste ni analizos tiujn tekstojn per la skriptoj `analizu_revo_*`.

### Serva interfaco (REST/JSON)
Ni ofertas ankaŭ servan interfacon, kiu estas uzata de la redaktilo por fone sendi la tekston de artikolo 
  kaj rericevi la erarojn kaj kontrolendajn vortojn. 

### Retpaĝo
 Fine, ni laboras pri retinterfaco uzebla de homo por enigi tekston por analizado.



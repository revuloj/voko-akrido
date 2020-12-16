:- encoding(utf8).

%! c(?EnFin,?Speco).
%
% literoj, kiuj povas aperi ene de vorto, ekz. libr/o-vendejo. 

c(o,subst).
c('o-',subst). % ekz. dissendo-listo
c(a,adj).
c('a-',adj). % ekz. verda-bruna
% c(e,adv). % en kuntiradoj, ekz. lace~peli, multe~kosta
c('e-',adv). % ekz. dece-konvene

%! ls(?LigStreko).
%! os(?Oblikvo).
%
% specialaj signoj, kiuj povas aperi ene de vortoj

ls('-').
os('/').

%! f(?Fino,?Speco).
%
% finaĵoj de radikoj
% @tbd prefere ordigu laŭ ofteco

f(ojn,subst).
f(oj,subst).
f(on,subst).
f(o,subst).
f('''',subst).
f(ajn,adj).
f(aj,adj).
f(an,adj).
f(a,adj).
f(as,verb).
f(is,verb).
f(os,verb).
f(us,verb).
f(i,verb).
f(u,verb).
f(en,adv).
f(e,adv).

%! s(?Sufikso,?AlSpeco,?DeSpeco).
%
% Sufiksoj
% @arg Sufikso sufikso, ekz. ul
% @arg AlSpeco rezulto de derivado, ekz. best
% @arg DeSpeco radikspeco, al kiu ĝi estas aplikebla, ekz. adj

s(ant,best,verb).
s(int,best,verb).
s(ont,best,verb).
s(at,best,tr).
s(it,best,tr).
s(ot,best,tr).
s('aĉ',_,_).
s(ad,subst,verb). % substantivigo
s(ad,_,verb). % ripetadi
s('aĵ',subst,adj).
s('aĵ',subst,verb).
s('aĵ',subst,subst).
s(an,best,subst).
s(ar,subst,subst).
s(ebl,adj,tr).
s(ec,subst,adj).
s(eg,_,_).
s(ej,subst,verb). % lernejo
s(ej,subst,subst). % vinejo
s(ej,subst,adj). % densejo, malsekejo
s(em,adj,verb). % kurema, purigema
s(em,adj,adj). % dolĉema, purema
s(end,adj,tr).
s(er,subst,subst).
s(estr,best,subst).
s(et,_,_).
s(id,best,best).
s(ig,tr,subst).
s(ig,tr,ntr).
s(ig,tr,adj).
s(ig,tr,nombr).
s('iĝ',ntr,subst).
s('iĝ',ntr,tr).
s('iĝ',ntr,adj).
s('iĝ',ntr,nombr).
s(il,subst,verb).
s(in,_,best).
s(ind,adj,tr).
s(ing,subst,subst).
s(ism,subst,_).
s(ist,best,_).
s(obl,subst,nombr).
s(on,subst,nombr).
s(op,subst,nombr).
s(uj,subst,subst).
s(ul,best,adj).
s(ul,best,subst). % X-hava ulo: mamulo, vertebrulo
s(ul,best,verb). % X-anta ulo: drinkulo, rampulo
s(um,_,_).
s(um,tr,_). % plenumi, brakumi, krucumi, lavumi ktp.

%! ns(?NomSufikso,?Speco).
%
% Nomsufiksoj, do 'nj' kaj 'ĉj'

ns(nj,pers).
ns(ĉj,pers).

%! sn(?NombroSufikso,?AlSpeco,?DeSpeco).
%
% Nombrosufiksoj: ilion kaj iliard.
% Ili estas apartigita de la aliaj sufiksoj, ĉar iom longaj kaj do malbonigus la
% efikecon de sufiksanalizado (ties longeco: 2..4)
sn(ilion,nombr,nombr). % sufiksoj por grandaj nombroj triilino - 1000^2*3 , okiliono - 1000^2*8) 
sn(iliard,nombr,nombr). % triiliardo - 1000 * 1000^2*3, okiliardo - 1000 * 1000^2*8


%! p(?Prefikso,?DeSpeco).
%
% Prefiksoj
% @arg Prefikso prefikso, ekz. bo
% @arg DeSpeco radikspeco, al kiu ĝi estas aplikebla, ekz. parc
%     (ordinaraj prefiskoj ne shanghas la vortspecon)
% puraj prefiksoj,
% prepozicioj kiel prefiksoj,
% adverboj kiel prefiksoj

p(bo,parc).
p('ĉef',subst).
p(dis,verb).
p(ek,verb).
p(eks,subst).
p(fi,subst).
p(ge,best).
p(mal,_).
p(mis,verb).
p(pra,subst).
p('pseŭdo',_).
p(re,verb).

% prepozicioj kiel prefiksoj
% pri transitivigaj, prefikse uzataj prepozicioj vd. malsupre

p(de,verb).
p(ekster,subst). % eksterlando
p(kun,verb).
p(sub,subst).
p(super,subst).

% adverboj kiel prefiksoj

p(ĉi,adj).
p(ĉiam,adj). % ekz. ĉiamverda
p(pli,adj).
%p(plu,verb).
%p(for,verb).
p(ne,adj).
p(ne,subst).
p(tiel,adj). %???

p(nun,subst).
p(mem,verb).
% p(mem,adj). vd. kunderivado mem+star/a
p('kvazaŭ',_). % simile al pseŭdo
p(tro,adj). % troabundeco


%! p(?Prefikso,?AlSpeco,?DeSpeco)
%
% Prefikse uzataj prepozicioj kaj adverboj. 
% * prepozicioj uzataj prefikse kun verboj,
% * adverboj uzataj prefikse kun verboj
%
% @tbd forigu prepoziciojn kaj pronomojn uzataj en kunderivado el la faktoj

% PLIBONIGU:
% dependas parte de la verbo, ĉu tia derivado
% estas transitiva aŭ ne(?)
p(al,tr,verb). % ekz. aliri, alveni
p('antaŭ',tr,verb). % antaŭvidi
p(pri,tr,verb). % ekz. priskribi
p(apud,tr,verb). % apudmeti
p('ĉe',tr,verb). % ĉeesti
p('ĉirkaŭ',tr,verb). % ĉirkaŭflugi
%% p(de,_,verb). % deveni (ntr), deteni(tr) -> vidu supre sub prefiksoj, char konservas (ne)transitivecon
p(el,tr,verb). % eliri
p(en,tr,verb). % enhavi
p(ĝis,tr,verb). % ĝisvivi
p(inter,tr,verb). % interrompi
p('kontraŭ',tr,verb). % kontraŭstari
p(krom,tr,verb). % krompagi
%% p(kun,_,verb). % kunludi (ntr), kunporti (tr) -> vidu supre sub prefiksoj, char konservas (ne)transitivecon
p('laŭ',tr,verb). % laŭiri
p(per,tr,verb). % perforti, perlabori
p(por,tr,verb). % porpeti
p(post,tr,verb). % postpagi
p(preter,tr,verb). % preteriri
p(pri,tr,verb). % priparoli
p(pro,tr,verb). % propeti
p(sub,tr,verb). % subteni
p(super,tr,verb). % superflugi
p(sur,tr,verb). % surmeti
p(tra,tr,verb). % trakuri
p(trans,tr,verb). % transpagi 

% adverboj uzataj prefikse kun verboj

p(mem,adj,verb).
p(plu,tr,verb).
p(for,tr,verb).

/**************
 * la sekvaj fakte ne estas prefiksoj,
 * sed uzataj en kunderivado (ekz. sen-dom-a, sed ne
 * sen-dom-o; internacia, internacieco, sed ne internacio
 * ...)  do eble forigu tie ĉi....
 * prepozicioj kaj pronomoj... 
**************/
p('ambaŭ',adj,subst). % per ambaŭ manoj -> ambaŭmane
p('ambaŭ',adj,verb). % tranĉi ambaŭ -> ambaŭtranĉe

p(en,adj,subst).
p(ekster,adj,subst).
p(inter,adj,subst).
p('antaŭ',adj,subst).
p(apud,adj,subst).
p('ĉe',adj,subst).
p('ĉirkaŭ',adj,subst).

p(dum,adj,subst).
p(dum,adv,verb).

p('kontraŭ',adj,subst).

p('laŭ',adj,adv).
p('laŭ',adj,adj).
p('laŭ',adj,subst).

p(pri,adj,subst).

p(per,adv,subst).
p(sen,adj,_).
%p(sen,adj,subst).

p(sub,adj,subst). 
% chu super/sub estas kunderivado au prefikso au ambau: komparu super/bela, super+rigarda
p(super,adj,adj).
p(super,adj,adv).
%p(super,_,subst).
p(sur,adj,subst). 

p(trans,adj,subst).

p('ĉiu',adj,subst). % de ĉiu jaro -> ĉiujara
p('tiu',adj,subst). % de tiu jaro -> tiujara
p('kiu',adj,subst). % de kiu jaro -> kiujara
p('neniu',adj,subst). % de neniu jaro -> neniujara

p('ĉia',adj,subst). % de ĉia speco -> ĉiaspeca
p('tia',adj,subst). % de tia speco -> tiaspeca
p('kia',adj,subst). % de kia speco -> kiaspeca
p('nenia',adj,subst). % de nenia speco -> neniaspeca


%! u(?Pron,?Speco).
%
% j-pronomoj, ekz-e kiu/j 

u(kiu,pron).
u(tiu,pron).
u(iu,pron).
u(neniu,pron).
u('ĉiu',pron).
u(kia,adj).
u(tia,adj).
u(ia,adj).
u(nenia,adj).
u('ĉia',adj).


%! fu(?Fino,?Speco).
%
% finaĵoj de j-pronomoj, do j,n,jn

fu(jn,_).
fu(j,_).
fu(n,_).


%! i(?Pron,?Speco).
%
% n-pronomoj, ekz-e mi/n.
% la personaj pronomoj, estas uzeblaj ankaŭ adjektive; kie, tio...

i(mi,perspron).
i(ci,perspron).
i(li,perspron).
i('ŝi',perspron).
i('ĝi',perspron).
i('ri',perspron). % neoficiala sekneŭtrala pronomo
i(oni,perspron).
i(ni,perspron).
i(vi,perspron).
i(ili,perspron).
i(si,perspron).
i('ĉio',pron).
i(kio,pron).
i(tio,pron).
i(io,pron).
i(nenio,pron).
i('ĉie',adv).
i(kie,adv).
i(nenie,adv).
i(ie,adv).
i(tie,adv).

%! fi(?Fino,?Speco).
%
% finaĵo de n-pronomo, do 'n'

fi(n,_).



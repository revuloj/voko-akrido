/************ literoj, kiuj povas 
 * esti ene de vorto 
************/
c(o,subst).
c(a,adj).
c('-',_).

/********** finajxoj de radikoj, prefere ordigu la
 * vortaron law la ofteco de la vortoj 
***********/

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


/************** sufiksoj
 * (2)=rezulto de derivado,
 * (3)=radikspeco, al kiu gxi estas aplikebla
**************/
s(ant,best,verb).
s(int,best,verb).
s(ont,best,verb).
s(at,best,tr).
s(it,best,tr).
s(ot,best,tr).
s('aĉ',_,_).
s(ad,subst,verb).
s('aĵ',subst,adj).
s('aĵ',subst,verb).
s('aĵ',subst,subst).
s(an,best,subst).
s(ar,subst,subst).
s(ebl,adj,tr).
s(ec,subst,adj).
s(eg,_,_).
s(ej,subst,verb).
s(ej,subst,subst).
s(em,adj,verb).
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

/************ prefiksoj 
 (2) vortspeco, al kiu ghi estas aplikebla,
     (prefiskoj ne shanghas la vortspecon)
************/
p(bo,parc).
p('ĉef',subst).
p(dis,verb).
p(ek,verb).
p(eks,subst).
p(ge,best).
p(mal,_).
p(mis,verb).
p(pra,subst).
p('pseŭdo',_).
p(re,verb).

/*************** 
 * prepozicioj kiel prefiksoj
****************/

% MANKO:
% ofte ili transitivigas verbon,
% oni devus montri aŭ per tria argumento "Al"
% aŭ uzi apartan predikaton, ekz. pp(X,verb) -> tr

% transitivigaj (?): al, apud, ĉe, el, en, super, sub, preter
% ne transitivigaj (?): de, kun...? demeti/deteni (tr -> tr), deveni (ntr), desalti (ntr -> tr)
%                     kuniri/kunsidi (ntr), kuntiri (tr->tr)

p(al,verb).
p('antaŭ',verb).
%p('antaŭ',adv). % chu prefikso au kunderivado?
p(apud,verb).
p('ĉe',verb).
p('ĉirkaŭ',verb).
p(de,verb).
p(ekster,verb).
p(el,verb).
p(en,verb).
p('ĝis',verb).
p(inter,verb).
p('kontraŭ',verb).
p(krom,verb).
p(kun,verb).
p('laŭ',verb).
p(post,verb).
p(preter,verb).
% p(pri,verb).
p(sub,verb).
p(sub,subst). 
p(super,verb).
p(super,subst).
p(sur,verb).
p(tra,verb).
p(trans,verb).

/*************
 * adverboj kiel prefiksoj
**************/

p(ĉi,adj).
p(ĉiam,adj). % ekz. ĉiamverda
p(pli,adj).
p(plu,verb).
p(for,verb).
p(ne,adj).
p(ne,subst).
p(tiel,adj). %???

p(nun,subst).
p(mem,verb).
p(mem,adj).
p('kvazaŭ',_). % simile al pseŭdo
p(tro,adj). % troabundeco

/**************
 * la sekvaj fakte ne estas prefiksoj,
 * sed uzataj en kunderivado (ekz. sen-dom-a, sed ne
 * sen-dom-o; internacia, internacieco, sed ne internacio
 * ...)  
 * prepozicioj kaj pronomoj...
**************/

p(sen,adj,_).
p(pri,adj,subst).
p('laŭ',adj,adv).
p(sen,adj,subst).
p('laŭ',adj,adj).
p('laŭ',adj,subst).

% chu super/sub estas kunderivado au prefikso au ambau: komparu super/bela, super+rigarda
p(super,adj,adj).
p(super,adj,adv).
%p(super,_,subst). 

p('kontraŭ',adj,subst).
p(en,adj,subst).
p(ekster,adj,subst).
p(inter,adj,subst).
p('antaŭ',adj,subst).
p(apud,adj,subst).
p('ĉe',adj,subst).
p('ĉirkaŭ',adj,subst).

p(per,adv,subst).
p(pri,tr,verb). % ekz. priskribi

p(dum,adj,subst).
p(dum,adv,verb).

p(trans,adj,subst).

p('ambaŭ',adj,subst). % per ambaŭ manoj -> ambaŭmane
p('ambaŭ',adj,verb). % tranĉi ambaŭ -> ambaŭtranĉe

p('ĉiu',adj,subst). % de ĉiu jaro -> ĉiujara
p('tiu',adj,subst). % de tiu jaro -> tiujara
p('kiu',adj,subst). % de kiu jaro -> kiujara
p('neniu',adj,subst). % de neniu jaro -> neniujara

p('ĉia',adj,subst). % de ĉia speco -> ĉiaspeca
p('tia',adj,subst). % de tia speco -> tiaspeca
p('kia',adj,subst). % de kia speco -> kiaspeca
p('nenia',adj,subst). % de nenia speco -> neniaspeca

% MANKO: necesas reguloj por posedaj pronomoj:
% miaflanke
% viavice

/**************
 *  j-pronomoj 
***************/
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

/**************
 *  finajxoj de j-pronomoj 
**************/
fu(jn,_).
fu(j,_).
fu(n,_).

/**************
 *  n-pronomoj, la personaj pronomoj ekz. ankaux kiel adj. rad. 
**************/
i(mi,perspron).
i(ci,perspron).
i(li,perspron).
i('ŝi',perspron).
i('ĝi',perspron).
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

/****************
 *  finajxo de n-pronomoj 
*****************/
fi(n,_).



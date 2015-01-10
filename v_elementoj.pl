/************ literoj, kiuj povas 
 * esti ene de vorto 
************/
c(o,subst) --> "o".
c(a,adj) --> "a".

/********** finajxoj de radikoj, prefere ordigu la
 * vortaron law la ofteco de la vortoj 
***********/

f(ojn,subst) --> "ojn".
f(oj,subst) --> "oj".
f(on,subst) --> "on".
f(o,subst) --> "o".
f('''',subst) --> "'".
f(ajn,adj) --> "ajn".
f(aj,adj) --> "aj".
f(an,adj) --> "an".
f(a,adj) --> "a".
f(as,verb) --> "as".
f(is,verb) --> "is".
f(os,verb) --> "os".
f(us,verb) --> "us".
f(i,verb) --> "i".
f(u,verb) --> "u".
f(en,adv) --> "en".
f(e,adv) --> "e".


/************** sufiksoj
 * (2)=rezulto de derivado,
 * (3)=radikspeco, al kiu gxi estas aplikebla
**************/
s(ant,best,verb) --> "ant".
s(int,best,verb) --> "int".
s(ont,best,verb) --> "ont".
s(at,best,tr) --> "at".
s(it,best,tr) --> "it".
s(ot,best,tr) --> "ot".
s('aĉ',_,_) --> "aĉ".
s(ad,subst,verb) --> "ad".
s('aĵ',subst,adj) --> "aĵ".
s('aĵ',subst,verb) --> "aĵ".
s('aĵ',subst,subst) --> "aĵ".
s(an,best,subst) --> "an".
s(ar,subst,subst) --> "ar".
s(ebl,adj,tr) --> "ebl".
s(ec,subst,adj) --> "ec".
s(eg,_,_) --> "eg".
s(ej,subst,verb) --> "ej".
s(ej,subst,subst) --> "ej".
s(em,adj,verb) --> "em".
s(end,adj,tr) --> "end".
s(er,subst,subst) --> "er".
s(estr,best,subst) --> "estr".
s(et,_,_) --> "et".
s(id,best,best) --> "id".
s(ig,tr,subst) --> "ig".
s(ig,tr,ntr) --> "ig".
s(ig,tr,adj) --> "ig".
s(ig,tr,nombr) --> "ig".
s('iĝ',ntr,subst) --> "iĝ".
s('iĝ',ntr,tr) --> "iĝ".
s('iĝ',ntr,adj) --> "iĝ".
s('iĝ',ntr,nombr) --> "iĝ".
s(il,subst,verb) --> "il".
s(in,_,best) --> "in".
s(ind,adj,tr) --> "ind".
s(ing,subst,subst) --> "ing".
s(ism,subst,_) --> "ism".
s(ist,best,_) --> "ist".
s(obl,subst,nombr) --> "obl".
s(on,subst,nombr) --> "on".
s(op,subst,nombr) --> "op".
s(uj,subst,subst) --> "uj".
s(ul,best,adj) --> "ul".
s(um,_,_) --> "um".

/************ prefiksoj 
 (2) vortspeco, al kiu ghi estas aplikebla,
     (prefiskoj ne shanghas la vortspecon)
************/
p(bo,parc) --> "bo".
p(dis,verb) --> "dis".
p(ek,verb) --> "ek".
p(eks,subst) --> "eks".
p(ge,best) --> "ge".
p(mal,_) --> "mal".
p(mis,verb) --> "mis".
p(pra,subst) --> "pra".
p('pseŭdo',_) --> "pseŭdo".
p(re,verb) --> "re".

/*************** 
 * prepozicioj kiel prefiksoj
****************/
p(al,verb) --> "al".
p('antaŭ',verb) --> "antaŭ".
p(apud,verb) --> "apud".
p('ĉe',verb) --> "ĉe".
p('ĉirkaŭ',verb) --> "ĉirkaŭ".
p(de,verb) --> "de".
p(ekster,verb) --> "ekster".
p(el,verb) --> "el".
p(en,verb) --> "en".
p('ĝis',verb) --> "ĝis".
p(inter,verb) --> "inter".
p('kontraŭ',verb) --> "kontraŭ".
p(krom,verb) --> "krom".
p(kun,verb) --> "kun".
p('laŭ',verb) --> "laŭ".
p(post,verb) --> "post".
p(preter,verb) --> "preter".
% p(pri,verb) --> "".
p(sub,verb) --> "sub".
p(super,verb) --> "super".
p(sur,verb) --> "sur".
p(tra,verb) --> "tra".
p(trans,verb) --> "trans".

/*************
 * adverboj kiel prefiksoj
**************/
p(pli,adj) --> "pli".
p(for,verb) --> "for".
p(ne,adj) --> "ne".
p(ne,subst) --> "ne".
p(tiel,adj) --> "tiel". %???

/**************
 * la sekvaj fakte ne estas prefiksoj,
 * sed uzataj en kunderivado (ekz. sen-dom-a, sed ne
 * sen-dom-o; internacia, internacieco, sed ne internacio
 * ...)  
**************/

p(sen,adj,_) --> "sen".
p(pri,adj,subst) --> "pri".
p('laŭ',adj,adv) --> "laŭ".
p(sen,adj,subst) --> "sen".
p('laŭ',adj,adj) --> "laŭ".
p(super,adj,adj) --> "super".
p(super,adj,adv) --> "super".
p('kontraŭ',adj,subst) --> "kontraŭ".
p(en,adj,subst) --> "en".
p(ekster,adj,subst) --> "ekster".
p(inter,adj,subst) --> "inter".
p('antaŭ',adj,subst) --> "antaŭ".
p(apud,adj,subst) --> "apud".
p('ĉe',adj,subst) --> "ĉe".
p('ĉirkaŭ',adj,subst) --> "ĉirkaŭ".

p(pri,tr,verb) --> "pri".

/**************
 *  j-pronomoj 
***************/
u(kiu,pron) --> "kiu".
u(tiu,pron) --> "tiu".
u(iu,pron) --> "iu".
u(neniu,pron) --> "neniu".
u('ĉiu',pron) --> "ĉiu".
u(kia,adj) --> "kia".
u(tia,adj) --> "tia".
u(ia,adj) --> "ia".
u(nenia,adj) --> "nenia".
u('ĉia',adj) --> "ĉia".

/**************
 *  finajxoj de j-pronomoj 
**************/
fu(jn,_) --> "jn".
fu(j,_) --> "j".
fu(n,_) --> "n".

/**************
 *  n-pronomoj, la personaj pronomoj ekz. ankaux kiel adj. rad. 
**************/
i(mi,perspron) --> "mi".
i(ci,perspron) --> "ci".
i(li,perspron) --> "li".
i('ŝi',perspron) --> "ŝi".
i('ĝi',perspron) --> "ĝi".
i(oni,perspron) --> "oni".
i(ni,perspron) --> "ni".
i(vi,perspron) --> "vi".
i(ili,perspron) --> "ili".
i(si,perspron) --> "si".
i('ĉio',pron) --> "ĉio".
i(kio,pron) --> "kio".
i(tio,pron) --> "tio".
i(io,pron) --> "io".
i(nenio,pron) --> "nenio".
i('ĉie',adv) --> "ĉie".
i(kie,adv) --> "kie".
i(nenie,adv) --> "nenie".
i(ie,adv) --> "ie".
i(tie,adv) --> "tie".

/****************
 *  finajxo de n-pronomoj 
*****************/
fi(n,_) --> "n".



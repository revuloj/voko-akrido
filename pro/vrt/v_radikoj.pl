/*************
 *  radikoj 
*************/

% "normalajn radikojn" legu el Revo-radikoj

% tiuj ne rekoniĝas kiel homo/besto el Revo-artiokoloj,
% manke de klaso besta aŭ parenca...
r('bov',best,*). % okaze aldonu lst-ref en bov/o
r('doktor',best,*).
r('edz',best,*).
r('fianĉ',best,*).
r('kamel',best,*). % okaze aldonu lst-ref en kamel/o
r('knab',best,*).
r('mastr',best,*).
r('parenc',parc,*). % permesu bo/parenc/
r('princ',best,*).
r('reĝ',best,*).
r('sinjor',best,*).
r('Sinjor',best,*).

% ni ordigis la vortaro tiel, ke ofc='' venas post aliaj!
% r('est',ntr,*). % pro konfuzeblo kun nefundamenta est/o (= estono).
% r('kri',ntr,*). % konfuzeblo kun kri/o (indiano)
% r('kri',tr,*). % konfuzeblo kun kri/o (indiano
% r('bel',adj,*). % konfuzeblo kun bel/o (mezuro)
% r('pi',adj,*). % kopnfuzeblo kun pi/o (greka litero)

/*****************
  personaj pronomoj kiel rad. 
*****************/

r('mi',adj,*).
r('ci',adj,*).
r('li',adj,*).
r('ŝi',adj,*).
r('ĝi',adj,*).
r('ri',adj,''). % neoficiala
r('oni',adj,*).
r('ni',adj,*).
r('vi',adj,*).
r('ili',adj,*).
r('si',adj,*).

/**********
 * aliaj pronomoj/tabelvortoj kiel radikoj
**********/

r('tia',adj,*). % tiaulo

r('kial',subst,*). % kialo
r('tial',subst,*). % tialo

r('iam',adv,*). % iame
r('ĉiam',adv,*). % ĉiame
r('kiam',adv,*). % kiame
r('tiam',adv,*). % tiame

r('ĉie',adj,*).

r('iel',adv,*). % iele
r('ĉiel',adv,*). % ĉiele
r('kiel',adv,*). % kiele
r('tiel',adv,*). % tiele

r('ĉies',adj,*). % ĉiesulino

r('iom',adv,*). % iomete
r('kiom',adv,*). % kiome
r('tiom',adv,*). % tiome
r('ĉiom',adv,*). % ĉiome

r('tie',adj,*).

/**************
 * nombroj kiel radiko 
**************/
r('nul',nombr,*).
r('unu',nombr,*).
r('du',nombr,*).
r('tri',nombr,*).
r('kvar',nombr,*).
r('kvin',nombr,*).
r('ses',nombr,*).
r('sep',nombr,*).
r('ok',nombr,*).
r('naŭ',nombr,*).
r('dek',nombr,*).
r('cent',nombr,*).
r('mil',nombr,*).

/*****************
 * kelkaj prepozicioj kaj prim. adv, 
   kiuj estas uzeblaj radike 
******************/

r('ajn',adj,*).
r('ambaŭ',adj,*).
r('anstataŭ',adv,*).
r('anstataŭ',tr,*).
r('antaŭ',adv,*).
r('al',adv,*).
r('antaŭ',adv,*).
r('antaŭ',tr,*).
r('apud',adv,*).
r('baldaŭ',adj,*).
r('ĉirkaŭ',adv,*).
r('ĉirkaŭ',tr,*).
r('dum',adv,*).
r('ekster',adv,*).
r('el',adv,*).
r('en',adv,*).
r('ĝis',adv,*).
r('inter',adv,*).
r('jam',adv,*).
r('jen',adv,*).
r('jes',tr,*).
r('kontraŭ',adv,*).
r('kontraŭ',tr,*).
r('krom',adv,*).
r('kun',adv,*).
r('laŭ',adv,*).
r('ne',tr,*).
r('nun',adv,*).
r('nur',adv,*).
r('plej',adj,*).
r('post',adv,*).
r('preskaŭ',adj,*).
r('preter',adv,*).
r('per',tr,*).
r('pli',adv,*).
r('plu',adv,*).
r('pri',adv,*).
r('sub',adv,*).
r('super',adv,*).
r('super',tr,*).
r('sur',adv,*).
r('trans',adv,*).
r('tra',adv,*).
r('tro',adv,*).
r('ĵus',adj,*).
r('for',adj,*).
r('hodiaŭ',adj,*).
r('hieraŭ',adj,*).
r('morgaŭ',adj,*).
r('plus',subst,'8').

/**********
 * afiksoj kaj interjekcioj kiel radikoj
**********/

r('aĉ',adj,'1').
r('adiaŭ',subst,*).
r('aĵ',subst,*).
r('aĥ',ntr,'').
r('an',best,*).
r('ar',subst,*).
r('ĉef',subst,*).
r('dis',adv,*).
r('ebl',adv,*).
r('ec',subst,*).
r('eg',adj,*).
r('ej',subst,*).
r('ek',intj,*).
r('eks',adj,*).
r('em',adj,*).
r('er',subst,*).
r('estr',best,*).
r('et',adj,*).
r('fi',intj,*).
r('fi',adv,*).
r('id',best,*).
r('ig',tr,*).
r('iĝ',ntr,*).
r('il',subst,*).
r('in',best,*).
r('ind',adj,*).
r('ing',subst,*).
r('mal',subst,*).
r('mis',adj,'1929').
r('obl',subst,*).
r('pra',adj,*).
r('re',adv,*).
r('uj',subst,*).
r('ul',best,*).
r('um',ntr,*).

/**********
 * konjunkcioj kiel radikoj
**********/

r('kvazaŭ',adj,*).



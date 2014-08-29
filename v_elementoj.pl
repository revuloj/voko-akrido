/************ literoj, kiuj povas 
 * esti ene de vorto 
************/
c('o','subst').
c('a','adj').

/********** finajxoj de radikoj, prefere ordigu la
 * vortaron law la ofteco de la vortoj 
***********/

f('ojn','subst').
f('oj','subst').
f('on','subst').
f('o','subst').
f('''','subst').
f('ajn','adj').
f('aj','adj').
f('an','adj').
f('a','adj').
f('as','verb').
f('is','verb').
f('os','verb').
f('us','verb').
f('i','verb').
f('u','verb').
f('en','adv').
f('e','adv').


/************** sufiksoj
 * (2)=rezulto de derivado,
 * (3)=radikspeco, al kiu gxi estas aplikebla
**************/
s('ant','best','verb').
s('int','best','verb').
s('ont','best','verb').
s('at','best','tr').
s('it','best','tr').
s('ot','best','tr').
s('acx',_,_).
s('ad','subst','verb').
s('ajx','subst','adj').
s('ajx','subst','verb').
s('ajx','subst','subst').
s('an','best','subst').
s('ar','subst','subst').
s('ebl','adj','tr').
s('ec','subst','adj').
s('eg',_,_).
s('ej','subst','verb').
s('ej','subst','subst').
s('em','adj','verb').
s('end','adj','tr').
s('er','subst','subst').
s('estr','best','subst').
s('et',_,_).
s('id','best','best').
s('ig','tr','subst').
s('ig','tr','ntr').
s('ig','tr','adj').
s('igx','ntr','subst').
s('igx','ntr','tr').
s('igx','ntr','adj').
s('il','subst','verb').
s('in',_,'best').
s('ind','adj','tr').
s('ing','subst','subst').
s('ism','subst',_).
s('ist','best',_).
s('obl','subst','nombr').
s('on','subst','nombr').
s('op','subst','nombr').
s('uj','subst','subst').
s('ul','best','adj').
s('um',_,_).

/************ prefiksoj 
 (2) vortspeco, al kiu ghi estas aplikebla,
     (prefiskoj ne shanghas la vortspecon)
************/
p('bo','parc').
p('dis','verb').
p('ek','verb').
p('eks','subst').
p('ge','best').
p('mal',_).
p('mis','verb').
p('pra','subst').
p('psewdo',_).
p('re','verb').

/*************** 
 * prepozicioj kiel prefiksoj
****************/
p('al','verb').
p('antaw','verb').
p('apud','verb').
p('cxe','verb').
p('cxirkaw','verb').
p('de','verb').
p('ekster','verb').
p('el','verb').
p('en','verb').
p('gxis','verb').
p('inter','verb').
p('kontraw','verb').
p('krom','verb').
p('kun','verb').
p('law','verb').
p('post','verb').
p('preter','verb').
% p('pri','verb').
p('sub','verb').
p('super','verb').
p('sur','verb').
p('tra','verb').
p('trans','verb').

/*************
 * adverboj kiel prefiksoj
**************/
p('pli','adj').
p('for','verb').
p('ne','adj').
p('ne','subst').
p('tiel','adj'). %???

/**************
 * la sekvaj fakte ne estas prefiksoj,
 * sed uzataj en kunderivado (ekz. sen-dom-a, sed ne
 * sen-dom-o; internacia, internacieco, sed ne internacio
 * ...)  
**************/

p('sen','adj',_).
p('pri','adj','subst').
p('law','adj','adv').
p('sen','adj','subst').
p('law','adj','adj').
p('super','adj','adj').
p('super','adj','adv').
p('kontraw','adj','subst').
p('en','adj','subst').
p('ekster','adj','subst').
p('inter','adj','subst').
p('antaw','adj','subst').
p('apud','adj','subst').
p('cxe','adj','subst').
p('cxirkaw','adj','subst').

p('pri','tr','verb').

/**************
 *  j-pronomoj 
***************/
u('kiu','pron').
u('tiu','pron').
u('iu','pron').
u('neniu','pron').
u('cxiu','pron').
u('kia','adj').
u('tia','adj').
u('ia','adj').
u('nenia','adj').
u('cxia','adj').

/**************
 *  finajxoj de j-pronomoj 
**************/
fu('jn',_).
fu('j',_).
fu('n',_).

/**************
 *  n-pronomoj, la personaj pronomoj ekz. ankaux kiel adj. rad. 
**************/
i('mi','perspron').
i('ci','perspron').
i('li','perspron').
i('sxi','perspron').
i('gxi','perspron').
i('oni','perspron').
i('ni','perspron').
i('vi','perspron').
i('ili','perspron').
i('si','perspron').
i('cxio','pron').
i('kio','pron').
i('tio','pron').
i('io','pron').
i('nenio','pron').
i('cxie','adv').
i('kie','adv').
i('nenie','adv').
i('ie','adv').
i('tie','adv').

/****************
 *  finajxo de n-pronomoj 
*****************/
fi('n',_).



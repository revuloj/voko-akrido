/************ 
 * esceptaj vortoj ne sekvantaj tute la normalajn derivadregulojn
************/
:- ensure_loaded(gramatiko2).
:- op( 1120, xfx, user:(<-) ). % disigas regulo-kapon, de esceptesprimo
:- op( 500, yfx, user:(~) ). % signas disigindajn vortojn

:- multifile rv_sen_fin/5, vorto/5.
:- discontiguous rv_sen_fin/5, vorto/5.

:- encoding(utf8).

rv_sen_fin(e,subst) <- post/e/ul.
%rad(e,adj) <= si/a.
rv_sen_fin(e,adj) <- mult/e+kost.
rv_sen_fin(e,adj) <- mult/e+kolor.
rv_sen_fin(e,adj) <- mult/e+sci.
rv_sen_fin(e,adj) <- mult/e+frukt.
rv_sen_fin(e,tr) <- art/e~far. % (art(e)+far)/ita, farita per arto
rv_sen_fin(e,tr) <- prunt/e~don.
rv_sen_fin(e,tr) <- prunt/e~pren.
rv_sen_fin(e,subst) <- bel~art.

vorto(e,pron) <- unu/j.
vorto(e,prep) <- ek-de. % = "eke de"
vorto(e,prep) <- dis-de. % = "de dise de"
rv_sen_fin(e,adv) <- ĉi-supr.
vorto(e,adv) <- antaŭ/hieraŭ.
vorto(e,adv) <- post/morgaŭ.



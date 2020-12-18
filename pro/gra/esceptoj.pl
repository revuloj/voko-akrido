/************ 
 * 1. esceptaj vortoj ne sekvantaj tute la normalajn derivadregulojn (prunt/e~don/i)
 * 2. vortoj, kiujn la analizilo pro la ordo de la analizo ne ĝuste
 *    analizas en la unua provo, ekz- nask-iĝ-tag/o anst. nask/iĝ-tag/o
************/
%:- ensure_loaded(gramatiko).

:- op( 1120, xfx, user:(<-) ). % disigas regulo-kapon, de esceptesprimo
:- op( 500, yfx, user:(~) ). % signas disigindajn vortojn

:- multifile rv_sen_fin/5, vorto/5.
:- discontiguous rv_sen_fin/5, vorto/5.

:- encoding(utf8).

% PLIBONIGU: la malsupraj vortoj estas kunmetitaj de fundamentaj vortelementoj
% sed ni ne povas indiki tion momente, ni devus subteni trian argumenton en 
% rule_ref (rv_sen_fin)...

% 'e' = escepto
rv_sen_fin(e,adj) <- 'daŭr'/i~pov. % 

rv_sen_fin(e,tr) <- diskut. % por eviti misanalizon dis/kut
rv_sen_fin(e,ntr) <- glu-mark. % por eviti misanalizon glum-ark

rv_sen_fin(e,subst) <- grup/et. % por eviti analizon grupet/

rv_sen_fin(e,subst) <- jar/dek. % por eviti analizon jard-ek/

rv_sen_fin(e,ntr) <- membr/'iĝ'. % por eviti misanalizon mem/briĝ
rv_sen_fin(e,subst) <- membr/ec. % por eviti misanalizon mem/brec

rv_sen_fin(e,subst) <- nask/'iĝ'. % por faciligi rekoni kunmetitajn kiel naskiĝtago

rv_sen_fin(e,adv) <- plej~part.
rv_sen_fin(e,adj) <- respond/ec.

rv_sen_fin(e,subst) <- post/e/ul.
rv_sen_fin(e,adj) <- postul/em. % por eviti misanalizon post/ulem
rv_sen_fin(e,adj) <- postul/at. % por eviti misanalizon postulat/

%rad(e,adj) <= si/a.
rv_sen_fin(e,adj) <- mult/e+kost.
rv_sen_fin(e,adj) <- mult/e+kolor.
rv_sen_fin(e,adj) <- mult/e+sci.
rv_sen_fin(e,adj) <- mult/e+frukt.
rv_sen_fin(e,tr) <- art/e~far. % (art(e)+far)/ita, farita per arto
rv_sen_fin(e,tr) <- prunt/e~don.
rv_sen_fin(e,tr) <- prunt/e~pren.
rv_sen_fin(e,subst) <- bel~art.

rv_sen_fin(e,adj) <- fin/it. % ne analizu fi/nit

vorto(e,pron) <- unu/j.
vorto(e,prep) <- ek-de. % = "eke de"
vorto(e,prep) <- dis-de. % = "de dise de"
rv_sen_fin(e,adv) <- ĉi-supr.
vorto(e,adv) <- antaŭ/hieraŭ.
vorto(e,adv) <- post/morgaŭ.



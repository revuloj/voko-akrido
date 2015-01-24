:- multifile r/4, v/4.
:- dynamic fv//2.

:-consult('vrt/v_esceptoj.pl').
:-consult('vrt/v_mallongigoj.pl').
:-consult('vrt/v_elementoj.pl').
:-consult('vrt/v_vortoj.pl').

term_expansion(fv(Vrt,Spc),(fv(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(r(Vrt,Spc),(r(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).

:-consult('vrt/v_fremdvortoj.pl').

% vicordo gravas, vortelementoj kiel radikoj
% rekoniĝu nur post la pli longaj "normalaj" radikoj
:-consult('vrt/v_revo_radikoj.pl').
:-consult('vrt/v_radikoj.pl').


% ĝeneralaj transformoj de vorspeco 
r(Rad,tr) --> r(Rad,subst). % kauzo -> kauzi
r(Rad,subst) --> r(Rad,nombr). % tri -> trio
r(Rad,adj) --> r(Rad,adv). % super -> super/a -> superulo
%r(Rad,adv) --> r(Rad,adj). % alt/a -> alt/e -> altkreska

shargu_chiujn(Dosiero,Pred,Ar) :-
  functor(F,Pred,Ar),
  retractall(F),
  vortlisto_al_dcg(Dosiero),
  compile_predicates([Pred/Ar]).

shargu_aldone(Dosiero,_,_) :-
  %functor(F,Pred,Ar),
  vortlisto_al_dcg(Dosiero).

shargu_aldone_lastajn(Dosiero,Pred,Ar) :-
  %functor(F,Pred,Ar),
  vortlisto_al_dcg(Dosiero),
  compile_predicates([Pred/Ar]).

% dinamike krei DCG regulojn de vortlisto

vortlisto_al_dcg(Infile) :-
%    retractall(verda(_,_)),
    setup_call_cleanup(
      open(Infile,read,In),
      vortlisto_al_dcg_(In),
      close(In)		 
    ).

vortlisto_al_dcg_(In) :-
  (
    repeat,
    read_term(In,Fakto,[]),
    ( Fakto == end_of_file -> !
      ;
      % debugging:
      format('~w~n',[Fakto]),
      fakto_dcg(Fakto),

      fail % read next term
    )
  ).

fakto_dcg(Fakto) :-
    Fakto=..[_,Vrt|_],
    atom_codes(Vrt,Str),
%    Head =.. [Pred,Vrt|Args],
    dcg_translate_rule(Fakto --> Str, Dcg),
    assertz(Dcg).

/********************* sercxo en la vortaro ******************

% sercxas radikon en la vortaro
% ekz. arb -> [arb, subst]

rad(Sercxajxo,[Sercxajxo,Speco]) :-
	r(Sercxajxo,Speco).

% sercxas konvenan sufikson en la vortaro
% ekz. arbar -> arb + [ar,subst,subst]

suf(Sercxajxo,Resto,[Sufikso,AlSpeco,DeSpeco]) :-
	s(Sufikso,AlSpeco,DeSpeco),
	atom_concat(Resto,Sufikso,Sercxajxo).

% sercxas konvenan finajxon en la vortaro
% ekz. arbon -> arb + [on, subst]

fin(Sercxajxo,Resto,[Finajxo,Speco]) :-
	f(Finajxo,Speco),
	atom_concat(Resto,Finajxo,Sercxajxo).

% sercxas konvenan prefikson en la vortaro
% ekz. maljuna -> juna + [mal,_]

pre(Sercxajxo,Resto,[Prefikso,DeSpeco]) :-
	p(Prefikso,DeSpeco),
	atom_concat(Prefikso,Resto,Sercxajxo).

% sercxas konvenan psewdoprefiskon por kunderivado
% ekz. internacia -> nacia + [inter,adj,subst]

pre2(Sercxajxo,Resto,[Prefikso,AlSpeco,DeSpeco]) :-
	p(Prefikso,AlSpeco,DeSpeco),
	atom_concat(Prefikso,Resto,Sercxajxo).

% sercxas konvenan j-pronomon (cxiu, kia,...) en la vortaro
% ekz. cxiujn -> jn + [cxiu,pron]

j_pro(Sercxajxo,Resto,[Pronomo,Speco]) :-
	u(Pronomo,Speco),
	atom_concat(Pronomo,Resto,Sercxajxo).

% sercxas konvenan n-pronomon (io, mi,...) en la vortaro
% ekz. min -> n + [mi,perspron]

n_pro(Sercxajxo,Resto,[Pronomo,Speco]) :-
	i(Pronomo,Speco),
	atom_concat(Pronomo,Resto,Sercxajxo).

% sercxas konvenan inter-literon (o, a) en la vortaro
% ekz. pago -> pag + [o,subst]

int(Sercxajxo,Resto,[Litero,Speco]) :-
	c(Litero,Speco),
	atom_concat(Resto,Litero,Sercxajxo).

************************************/

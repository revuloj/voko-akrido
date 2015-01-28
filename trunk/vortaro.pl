:- multifile r/4, v/4, mlg/1, nr/4, nr_/4.
%:- dynamic fv//2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transformreguloj por vortaraj faktoj al DCG-esprimoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

term_expansion(r(Vrt,Spc),(r(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(s(Vrt,Al,De),(s(Vrt,Al,De)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(c(Vrt,Spc),(c(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(p(Vrt,Spc),(p(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(p(Vrt,Al,De),(p(Vrt,Al,De)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(f(Vrt,Spc),(f(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(u(Vrt,Spc),(u(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(fu(Vrt,Spc),(fu(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(i(Vrt,Spc),(i(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(fi(Vrt,Spc),(fi(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(v(Vrt,Spc),(v(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(fv(Vrt,Spc),(fv(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(nr(Vrt,Spc),(nr(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).
term_expansion(nr_(Vrt,Spc),(nr_(Vrt,Spc)-->Str)) :- atom_codes(Vrt,Str).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vortaraj faktoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:-consult('vrt/v_esceptoj.pl').
:-consult('vrt/v_mallongigoj.pl').
:-consult('vrt/v_revo_mallongigoj.pl').
:-consult('vrt/v_elementoj.pl').
:-consult('vrt/v_vortoj.pl').
:-consult('vrt/v_fremdvortoj.pl').
:-consult('vrt/v_revo_nomoj.pl').
% vicordo gravas, vortelementoj kiel radikoj
% rekoniĝu nur post la pli longaj "normalaj" radikoj
:-consult('vrt/v_revo_radikoj.pl').
:-consult('vrt/v_radikoj.pl').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ĝeneralaj transformoj de vorspeco 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r(Rad,tr) --> r(Rad,subst). % kauzo -> kauzi
r(Rad,subst) --> r(Rad,nombr). % tri -> trio
r(Rad,adj) --> r(Rad,adv). % super -> super/a -> superulo
%r(Rad,adv) --> r(Rad,adj). % alt/a -> alt/e -> altkreska


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

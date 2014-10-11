:-consult('v_elementoj.pl').
:-consult('v_vortoj.pl').
:-consult('v_radikoj.pl').


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

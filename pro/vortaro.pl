:-module(vortaro,[
	    v/2, % vortoj
	    r/2, % radikoj
	    nr/2, % nomradikoj
	    nr_/2, % nomradikoj minuskligitaj
	    p/2, p/3, s/3, % prefiksoj kaj sufiksoj
	    ns/2, sn/3, % nomsufikso (nj, ĉj)kaj nombrosufikso (ilion, iliard)
        f/2, c/2, % finaĵoj
	    ls/1, os/1, % ligstreko, oblikvo
	    u/2, fu/2, % j-pronomo kaj finaĵo, ekz. kiu/j
	    i/2, fi/2, % n-pronomo kaj finaĵo, ekz. mi/n
	    mlg/1 % mallongigoj
	 ]).

:- multifile r/3, v/3, mlg/1, nr/3, nr_/3.

:- encoding(utf8).

%! v(?Vorto,?Speco).
%! r(?Radiko,?Speco).
%! nr(?Nomradiko,?Speco).
%! nr_(?NomRad_minuskla,?Speco).
%! p(?Prefikso,?AlSpeco).

:-consult('vrt/v_esceptoj2.pl').
:-consult('vrt/v_mallongigoj.pl').
:-consult('vrt/v_revo_mallongigoj.pl').
:-consult('vrt/v_elementoj.pl').
:-consult('vrt/v_vortoj.pl').
:-consult('vrt/v_fremdvortoj.pl').
:-consult('vrt/v_revo_nomoj.pl').
:-consult('vrt/v_revo_radikoj.pl').
:-consult('vrt/v_revo_vortoj.pl').
:-consult('vrt/v_radikoj.pl').

% provizore ignoru la oficialecon, poste ni devos prilabori la gramatikon por ebligi plian argumenton! 
v(V,S) :- v(V,S,_).
r(V,S) :- r(V,S,_).
nr(V,S) :- nr(V,S,_).
nr_(V,S) :- nr_(V,S,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ĝeneralaj transformoj de vorspeco ...

% shovis specshanghojn al la gramatiko...
% verbigo de substantivoj planado, muzikado, spicado, kau'zanta, kau'zata (nur por transitivaj)
% r(Rad,tr) :- r(Rad,subst). % kauzo -> kauzi, spico -> spici
% r(Rad,subst) :- r(Rad,nombr). % tri -> trio
% r(Rad,adj) :- r(Rad,adv). % super -> super/a -> superulo
% nomkomenco, por apliki nj, ĉj: Pa+ĉj -> Pa/ĉj


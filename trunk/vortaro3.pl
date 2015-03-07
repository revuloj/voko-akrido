
:- multifile r/2, v/2, mlg/1, nr/2, nr_/2.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ĝeneralaj transformoj de vorspeco 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% shovis specshanghojn al la gramatiko...
% verbigo de substantivoj planado, muzikado, spicado, kau'zanta, kau'zata (nur por transitivaj)
% r(Rad,tr) :- r(Rad,subst). % kauzo -> kauzi, spico -> spici
% r(Rad,subst) :- r(Rad,nombr). % tri -> trio
% r(Rad,adj) :- r(Rad,adv). % super -> super/a -> superulo

% nomkomenco, por apliki nj, ĉj: Pa+ĉj -> Pa/ĉj
nk(Nom,Spc) :- 
    sub(Spc,pers),
    (r(Nomo,Spc); nr(Nomo,Spc)),
    sub_atom('aeioujŭrlnm',_,1,_,Lit),
    sub_atom(Nomo,B,1,_,Lit),
    B_1 is B+1,
    sub_atom(Nomo,0,B_1,_,Nom).

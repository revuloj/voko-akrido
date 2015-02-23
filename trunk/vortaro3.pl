
:- multifile r/2, v/2, mlg/1, nr/2, nr_/2.

%:-consult('vrt/v_esceptoj.pl').
%:-consult('vrt/v_mallongigoj.pl').
%:-consult('vrt/v_revo_mallongigoj.pl').
:-consult('vrt/v_elementoj.pl').
:-consult('vrt/v_vortoj.pl').
%:-consult('vrt/v_fremdvortoj.pl').
:-consult('vrt/v_revo_nomoj.pl').
% vicordo gravas, vortelementoj kiel radikoj
% rekoniĝu nur post la pli longaj "normalaj" radikoj
:-consult('vrt/v_revo_radikoj.pl').
:-consult('vrt/v_revo_vortoj.pl').
:-consult('vrt/v_radikoj.pl').


% nomkomenco, por apliki nj, ĉj: Pa+ĉj -> Pa/ĉj
nk(Nom,Spc) :- 
    sub(Spc,pers),
    (r(Nomo,Spc); nr(Nomo,Spc)),
    sub_atom('aeioujŭrlnm',_,1,_,Lit),
    sub_atom(Nomo,B,1,_,Lit),
    B_1 is B+1,
    sub_atom(Nomo,0,B_1,_,Nom).

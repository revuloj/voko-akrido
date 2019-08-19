:- module(vortlisto_dcg,[
	      linio//2
	  ]).

:- ensure_loaded(library(dcg/basics)).

/****
enlegas vortliston konsistantan el linioj en la formo:

artikolo1: vorto1 vorto2 vorto3...
artikolo2: vorto12

****/

linio(Art,Vortoj) --> art(Art), whites, ":", whites, vortoj(Vortoj), whites. %, "\n".

art(Art) --> vorto(Art). % oni povus pli strikte kontroli nur minusklajn/latinaojn literojn kaj ciferojn

vortoj([V|Vortoj]) --> vorto(V), whites, sep, whites, vortoj(Vortoj).
vortoj([V]) --> vorto(V).

%vorto(V) --> string_without(V,";, \t")
vorto(V) --> literoj(V).

sep --> ("," ; ";").

apostrofo(C) --> [C], { C = 39 }.
oblikvo(47) --> "/". 
streketo(45) --> "-".

/****
spaco --> (" " ; "\n" ; "\r").
intersigno(S) --> [C], { memberchk(C, ",:"), char_code(S,C) }.
finsigno(S) --> [C], { memberchk(C, ".;!?"), char_code(S,C) }.
tekstofino --> \+ [_].

nelitero(L) --> [L], { \+ (code_type(L, alpha); L = 39) }.

neliteroj([N|Nj]) --> nelitero(N), neliteroj(Nj).
neliteroj([N]) --> nelitero(N).

****/

% literoj, literchenoj
litero(L) --> [L], { code_type(L, csym); L = 39; L=45; L=47 }.

literoj([L|Lj]) --> litero(L), literoj(Lj).
literoj([L,O|Lj]) --> litero(L), oblikvo(O), literoj(Lj). % ne permesu / enn la komenco
literoj([L,S|Lj]) --> litero(L), streketo(S), literoj(Lj). % ne permesu - en la komenco (?)
literoj([L]) --> litero(L).


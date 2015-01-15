:- ensure_loaded(library(http/dcg_basics)).

% PLIBONIGENDA: uzu disjunktajn literklasojn!

/****
enlegas tekston kiel vico de v(Vorto); n(Numbero); s(Neliteroj)
****/

minusklo(C) --> [C], { C>=97, C=<122 }. % 'a'...'z'
minusklo(C) --> [C], { memberchk(C,[265,285,309,349,293,365]) }. % 'ĉ'...'ŭ'

majusklo(C) --> [C], { C>=65, C=<90 }. %, M is C - 65 + 97 }. % 'A'...'Z' -> 'a'...'z'
majusklo(C) --> [C], { memberchk(C,[264,284,308,348,292,364])}. %, M is C+1 }. % 'Ĉ'...'Ŭ' -> 'ĉ'...'ŭ'

apostrofo(C) --> [C], { C = 39 }.
oblikvo --> "/". 
streketo --> "-".

spaco --> (" " ; "\n" ; "\r").
intersigno(S) --> [C], { memberchk(C, ",:"), char_code(S,C) }.
finsigno(S) --> [C], { memberchk(C, ".;!?"), char_code(S,C) }.
tekstofino --> \+ [_].

% literoj, literchenoj
litero(L) --> minusklo(L); majusklo(L); apostrofo(L).
nelitero(L) --> [L], { 
         between(1,46,L), L\=39;  % eksludu '/ , eksludi ankau streketon (45) kauzas problemo ekz en soldat.xml...
         between(58,64,L);
         between(91,96,L) ; 
         ( L>=123 , \+ memberchk(L,[264,265,284,285,308,309,348,349,292,293]) )
                     }.

%nelitero("") --> tekstofino.

minuskloj([M|V]) --> minusklo(M), minuskloj(V).
minuskloj(V) --> oblikvo, minuskloj(V). % ignoru oblikvojn
minuskloj(V) --> streketo, minuskloj(V). % ignoru streketojn

% tio permesas aprostrofon nur fine de vorto, chu permesi ankau ene?
minuskloj([A]) --> apostrofo(A).
minuskloj([M]) --> minusklo(M).

neliteroj([N|Nj]) --> nelitero(N), neliteroj(Nj).
neliteroj([N]) --> nelitero(N).

% vortoj ...
vorto(V) --> minuskloj(V).
vorto([M|V]) --> majusklo(M), minuskloj(V).


vortoj([V]) --> vorto(C), { atom_codes(V,C) }.
vortoj([V|Vj]) --> vorto(C), { atom_codes(V,C) }, spaco, vortoj(Vj).

fremdvorto(V) --> string_without(".;, \t\r\n!?[]{}",V).

/**
vortoj([V]) --> vorto(V).
vortoj([V|Vj]) --> vorto(V), spaco, vortoj(Vj).
**/

numero(N) --> digit(D1), digits(D), ".", { append([[D1],D,"."],N) }.
numero(N) --> digit(D1), digits(D), "a", { append([[D1],D,"a"],N) }.
numero(N) --> digit(D1), digits(D), "-a", { append([[D1],D,"-a"],N) }.
numero(N) --> digits(N).

% teksto kiel alternado de vortoj kaj intersignoj
/**
vteksto([v(V),s(N)|T]) --> vorto(C), { atom_codes(V,C) }, 
                     neliteroj(C1), { atom_codes(N,C1) }, vteksto(T).
vteksto([v(V)]) --> vorto(C), { atom_codes(V,C) }.
vteksto([]) --> [].
**/
vteksto([v(V),s(N)|T]) --> vorto(V), 
%                     { format('~s ',[V]) }, %for debugging
                     neliteroj(N), vteksto(T).

vteksto([n(V),s(N)|T]) --> numero(V),
                     neliteroj(N), vteksto(T).

vteksto([f(V),s(N)|T]) --> fremdvorto(V),
                     neliteroj(N), vteksto(T).

vteksto([v(V)]) --> vorto(V).
%    { format('~s ',[V]) }. %for debugging
vteksto([n(N)]) --> numero(N).

vteksto([]) --> [].

teksto(T) --> blanks, vteksto(T).
%%teksto([s(N)|T]) --> neliteroj(C), { atom_codes(N,C) }, vteksto(T).
teksto([s(N)|T]) --> neliteroj(N), vteksto(T).

% frazoj ...
frazeto([Vj,I]) --> vortoj(Vj), intersigno(I).

frazo([[Vj,S]]) --> vortoj(Vj), finsigno(S).
frazo([[Vj]]) --> vortoj(Vj), tekstofino.
frazo(F) --> frazeto(F1), spaco, frazo(F2), { append([F1],F2,F) }.

fraz_analizo(Frazo) :-
  set_prolog_flag(encoding,utf8),
  phrase(frazo(F),Frazo),
  format('~q~n',[F]).


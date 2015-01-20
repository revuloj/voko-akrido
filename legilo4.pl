:- ensure_loaded(library(http/dcg_basics)).

% PLIBONIGENDA: uzu disjunktajn literklasojn!

/****
enlegas tekston kiel vico de v(Vorto); n(Numbero); s(Neliteroj)
****/

minusklo(C) --> [C], { code_type(C, lower) }.
majusklo(C) --> [C], { code_type(C, upper) }.

apostrofo(C) --> [C], { C = 39 }.
oblikvo(47) --> "/". 
streketo(45) --> "-".

spaco --> (" " ; "\n" ; "\r").
intersigno(S) --> [C], { memberchk(C, ",:"), char_code(S,C) }.
finsigno(S) --> [C], { memberchk(C, ".;!?"), char_code(S,C) }.
tekstofino --> \+ [_].

% literoj, literchenoj
litero(L) --> [L], { code_type(L, alpha); L = 39 }.
nelitero(L) --> [L], { \+ (code_type(L, alpha); L = 39) }.

minuskloj([M|V]) --> minusklo(M), minuskloj(V).
minuskloj([O|V]) --> oblikvo(O), minuskloj(V). % ignoru oblikvojn
minuskloj([S|V]) --> streketo(S), minuskloj(V). % ignoru streketojn

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

%%% fremdvorto(V) --> string_without(".;, \t\r\n!?[]{}",V).

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

%%vteksto([f(V),s(N)|T]) --> fremdvorto(V),
%%                     neliteroj(N), vteksto(T).

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


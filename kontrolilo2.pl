
minusklo(C) --> [C], { C>=97, C=<122 }. % 'a'...'z'
minusklo(119) --> [365]. % ŭ -> w

minusklo_x("cx") --> [265].
minusklo_x("gx") --> [285].
minusklo_x("jx") --> [309].
minusklo_x("sx") --> [349].
minusklo_x("hx") --> [293].

majusklo(M) --> [C], { C>=65, C=<90, M is C - 65 + 97 }. % 'A'...'Z' -> 'a'...'z'
majusklo(119) --> [364]. % Ŭ -> w

majusklo_x("cx") --> [264].
majusklo_x("gx") --> [284].
majusklo_x("jx") --> [308].
majusklo_x("sx") --> [348].
majusklo_x("hx") --> [292].

apostrofo(C) --> [C], { C = 39 }.
spaco --> (" " ; "\n" ; "\r").
intersigno(S) --> [C], { memberchk(C, ",:"), char_code(S,C) }.
finsigno(S) --> [C], { memberchk(C, ".;!?"), char_code(S,C) }.


minuskloj([M|V]) --> minusklo(M), minuskloj(V).
minuskloj([M,X|V]) --> minusklo_x([M,X]), minuskloj(V).

% tio permesas aprostrofon nur fine de vorto, chu permesi ankau ene?
minuskloj([A]) --> apostrofo(A).
minuskloj([M]) --> minusklo(M).

vorto(V) --> minuskloj(V).
vorto([M|V]) --> majusklo(M), minuskloj(V).
vorto([M,X|V]) --> majusklo_x([M,X]), minuskloj(V).

vortoj([V]) --> vorto(C), { atom_codes(V,C) }.
vortoj([V|Vj]) --> vorto(C), { atom_codes(V,C) }, spaco, vortoj(Vj).

frazeto([Vj,I]) --> vortoj(Vj), intersigno(I).

frazo([[Vj,S]]) --> vortoj(Vj), finsigno(S).
frazo(F) --> frazeto(F1), spaco, frazo(F2), { append([F1],F2,F) }.

analizo(Frazo) :-
  set_prolog_flag(encoding,utf8),
  phrase(frazo(F),Frazo),
  format('~q~n',[F]).


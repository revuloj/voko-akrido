%encoding('utf8').

% cj, t.e. nombroj de 1 ghis 9

c1(10) --> "X".
c1(1) --> "I".

c5(5) --> "V".

% ciferoj
c(N) --> c1(N).
c(N) --> c5(N).

% tiuj rajtas lokigi maldekstre
%c(N) --> c1(N).

% malpermesu VV, LL, DD...!

% kombinoj de pli ol du cj...

nombro(N) --> c(N).
nombro(NN) --> c1(N), c1(N), { NN is N+N }.
nombro(NNN) --> c1(N), c1(N), c1(N), { NNN is N+N+N }.

nombro(MN) --> c1(M), c(N), { M<N, MN is N-M }.

nombro(NM) --> c(N), c(M), { N>M, NM is N+M }.
nombro(NMM) --> c(N), c1(M), c1(M), { N>M, NMM is N+M+M }.
nombro(NMMM) --> c(N), c1(M), c1(M), c1(M), { N>M, NMMM is N+M+M+M }.


% kunmetu ambau direktojn en unu predikato

nombro(Nombro,N) :-
  integer(N), phrase(nombro(N),Codes), atom_codes(Nombro,Codes),!;
  atom(Nombro), atom_codes(Nombro,Codes), phrase(nombro(N),Codes),!.

% nombri 

nombru(De,Ghis) :-
  between(De,Ghis,N),
  nombro(Nombro,N),
  write(Nombro),nl,fail.






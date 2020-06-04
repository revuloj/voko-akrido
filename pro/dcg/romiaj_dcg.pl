%encoding('utf8').

% ciferoj, t.e. nombroj de 1 ghis 9

cifero(10) --> "X".
cifero(5) --> "V".
cifero(1) --> "I".

% malpermesu VV, LL, DD...!

% kombinoj de pli ol du ciferoj...

nombro(N) --> cifero(N).
nombro(NN) --> cifero(N), cifero(N), { NN is N+N }.
nombro(NNN) --> cifero(N), cifero(N), cifero(N), { NNN is N+N+N }.
nombro(MN) --> cifero(M), cifero(N), { M<N, MN is N-M }.
nombro(NM) --> cifero(N), cifero(M), { N>M, NM is N+M }.
nombro(NMM) --> cifero(N), cifero(M), cifero(M), { N>M, NMM is N+M+M }.
nombro(NMMM) --> cifero(N), cifero(M), cifero(M), cifero(M), { N>M, NMMM is N+M+M+M }.


% kunmetu ambau direktojn en unu predikato

nombro(Nombro,N) :-
  integer(N), phrase(nombro(N),Codes), atom_codes(Nombro,Codes),!;
  atom(Nombro), atom_codes(Nombro,Codes), phrase(nombro(N),Codes),!.

% nombri 

nombru(De,Ghis) :-
  between(De,Ghis,N),
  nombro(Nombro,N),
  write(Nombro),nl,fail.






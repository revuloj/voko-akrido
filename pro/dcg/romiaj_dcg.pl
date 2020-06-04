%encoding('utf8').

% cj, t.e. nombroj de 1 ghis 9

c1(10) --> "X".
c1(1) --> "I".

c5(50) --> "L".
c5(5) --> "V".

% ciferoj
c(N) --> c1(N).
c(N) --> c5(N).

% kombinoj de pli ol du cj...

n(N) --> c(N).
n(NN) --> c1(N), c1(N), { NN is N+N }.
n(NNN) --> c1(N), c1(N), c1(N), { NNN is N+N+N }.

n(MN) --> c1(M), c(N), { M<N, MN is N-M }.

%n(NM) --> c(N), c(M), { N>M, NM is N+M }.
%n(NMM) --> c(N), c1(M), c1(M), { N>M, NMM is N+M+M }.
%n(NMMM) --> c(N), c1(M), c1(M), c1(M), { N>M, NMMM is N+M+M+M }.

nombro(N_)  --> n(N_).
nombro(N_M_) --> n(N_), n(M_), { N_>M_, N_M_ is N_+M_ }.
nombro(N_M_L_) --> n(N_), n(M_), n(L_), { N_>M_, M_>L_, N_M_L_ is N_+M_+L_ }.

% kunmetu ambau direktojn en unu predikato

nombro(Nombro,N) :-
  integer(N), phrase(nombro(N),Codes), atom_codes(Nombro,Codes),!;
  atom(Nombro), atom_codes(Nombro,Codes), phrase(nombro(N),Codes),!.

% nombri 

nombru(De,Ghis) :-
  between(De,Ghis,N),
  nombro(Nombro,N),
  write(Nombro),nl,fail.






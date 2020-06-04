%encoding('utf8').

% cj, t.e. nombroj de 1 ghis 9

c1(10) --> "X".
c1(1) --> "I".

c5(50) --> "L".
c5(5) --> "V".

% ciferoj
%c(N) --> c1(N).
%c(N) --> c5(N).

% II, III, XX, XXX ktp.
a(NN) --> c1(N), c1(N), { NN is N+N }.
a(NNN) --> c1(N), c1(N), c1(N), { NNN is N+N+N }.

% 4 (IV), 9 (IX), 40 (XL), 90 (XC), 400 (CD), 900 (CM)
s(MN) --> c1(M), c5(N), { N is M*5, MN is N-M }.
s(MN) --> c1(M), c1(N), { N is M*10, MN is N-M }.

n(N) --> c1(N).
n(N) --> c5(N).
n(N) --> a(N).
n(N) --> s(N).

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






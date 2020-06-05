%encoding('utf8').

% bazaj ciferoj

c1(1) --> "I".
c1(10) --> "X".
c1(100) --> "C".
c1(1000) --> "M".

c5(5) --> "V".
c5(50) --> "L".
c5(500) --> "D".

% ciferoj
%c(N) --> c1(N).
%c(N) --> c5(N).

% adicio: II, III, XX, XXX ktp.
a(NN) --> c1(N), c1(N), { NN is N+N }.
a(NNN) --> c1(N), c1(N), c1(N), { NNN is N+N+N }.
a(NM) --> c5(N), c1(M), { N is M*5, NM is N+M }. % ekz. VI
a(NMM) --> c5(N), c1(M), c1(M), { N is M*5, NMM is N+M+M }. % ekz. VII
a(NMMM) --> c5(N), c1(M), c1(M), c1(M), { N is M*5, NMMM is N+M+M+M }. % ekz. VIII

% subtraho: 4 (IV), 9 (IX), 40 (XL), 90 (XC), 400 (CD), 900 (CM)
s(MN) --> c1(M), c5(N), { N is M*5, MN is N-M }.
s(MN) --> c1(M), c1(N), { N is M*10, MN is N-M }.

n(N) --> c1(N).
n(N) --> c5(N).
n(N) --> a(N).
n(N) --> s(N).

%nombro(N_)  --> n(N_).
%nombro(N_M_) --> nombro(N_), ",", n(M_), { N_>M_, N_M_ is N_+M_ }.

%% decimala dismeto
%rn(D) --> n(D), { D =< 10 }.
%rn(D) --> n(D10), { D10 is div(D,10)*10, 0 is D mod 10 }.
%rn(D) --> n(D10), n(D1), { D10 is div(D,10)*10, D1 is D mod 10 }.
romia(Dec,Rom) :-
  number_chars(Dec,CList),
  ndec(CList,DList),
  rnl(DList,RList),
  append(RList,RL1),
  atom_codes(Rom,RL1).

ndec(CL,DL) :- ndec(CL,_,DL).
ndec([C],1,[D]):- atom_number(C,D),!.
ndec([C|CL],P10,[D|DL]) :-
  ndec(CL,P,DL),
  P10 is P*10,
  atom_number(C,N),
  D is P10 * N.

rnl([],[]).
rnl([D|DList],[R|RList]) :-
  D > 0,
  phrase(n(D),R),!,
  rnl(DList,RList).
rnl([D|DList],RList) :-
  D = 0,
  rnl(DList,RList).


% kunmetu ambau direktojn en unu predikato

%romia(Nombro,N) :-
%  integer(N), phrase(rn(N,Codes), atom_codes(Nombro,Codes),!;
%  atom(Nombro), atom_codes(Nombro,Codes), phrase(rn(N),Codes),!.

% nombri 

nombru(De,Ghis) :-
  between(De,Ghis,N),
  romia(N,Romia),
  write(Romia),nl,fail.






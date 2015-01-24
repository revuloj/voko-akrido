%encoding('utf8').

% ciferoj, t.e. nombroj de 1 ghis 9

nul --> "nul";"nulo".
dek --> "dek".
cent --> "cent".
mil --> "mil".
miliono --> "miliono";"milionoj".

cifero(1) --> "unu".
cifero(2) --> "du".
cifero(3) --> "tri".
cifero(4) --> "kvar".
cifero(5) --> "kvin".
cifero(6) --> "ses".
cifero(7) --> "sep".
cifero(8) --> "ok".
cifero(9) --> "na\u016d".

% unuoj

unuoj(0) --> "".
unuoj(N) --> cifero(N).

% dekoj, t.e. 10, 20 ... 90

dekoj(0) --> "".
dekoj(10) --> dek.

dekoj(N) -->
  cifero(C), dek,
  { N is C*10 }.

% centoj, t.e. 100, 200, ... 900

centoj(0) --> "".
centoj(100) --> cent.

centoj(N) -->
  cifero(C), cent,
  { N is C*100 }.

spaco --> " "; "".

% kunmetitaj nombroj ĝis 999

n3(0) --> nul.
n3(N) --> 
  centoj(C), spaco, dekoj(D), spaco, unuoj(U),
  { N is C+D+U }.

n3_(1) --> "".
n3_(N) --> n3(N).

% kunmetitaj nombroj ĝis 999 999

n6(1000) --> mil.
n6(N) --> n3(N).
n6(N) --> n3_(N1), spaco, mil, spaco, n3(N2), { N is N1 * 1000 + N2 }.

% kunmetitaj nombroj ĝis 999 999 999 999

kaj --> " kaj ";" ".
n6_(1) --> "".
n6_(N) --> n6(N).

n12(1000000) --> miliono.
n12(N) --> n6(N).
n12(N) --> n6_(N1), spaco, miliono, kaj, n6(N2), { N is N1 * 1000000 + N2 }.

% traduki nombroj ghis 10^12 - 1 al vortoj

cifero(Cifero,C) :-
  phrase(cifero(C),Codes),
  atom_codes(Cifero,Codes).

n12(Nombro,N) :-
  integer(N), N<10,!,
  cifero(Nombro,N).

n12(Nombro,N) :-
  integer(N), N<100,!,
  D is N div 10,
  U is N mod 10,
  (D>1, n12(Dekoj,D),!; Dekoj=''),
  n12(Unuoj,U),
  atomic_list_concat([Dekoj,'dek',' ',Unuoj],Nombro).

n12(Nombro,N) :-
  integer(N), N<1000,!,
  C is N div 100,
  D is N mod 100,
  (C>1, n12(Centoj,C),!; Centoj=''),
  n12(Dekoj,D),
  atomic_list_concat([Centoj,'cent',' ',Dekoj],Nombro).

n12(Nombro,N) :-
  integer(N), N<1000000,!,
  M is N div 1000,
  S is N mod 1000,
  (M>1, n12(Miloj,M),!; Miloj=''),
  n12(SubMiloj,S),
  atomic_list_concat([Miloj,'mil',SubMiloj],' ',Nombro).

n12(Nombro,N) :-
  integer(N), N<2000000,!,
  S is N mod 1000000,
  n12(SubMilionoj,S),
  atomic_list_concat(['unu miliono',SubMilionoj],' ',Nombro).

n12(Nombro,N) :-
  integer(N), N<1000000000,!,
  M is N div 1000000,
  S is N mod 1000000,
  n12(Milionoj,M),
  n12(SubMilionoj,S),
  atomic_list_concat([Milionoj,'milionoj',SubMilionoj],' ',Nombro).

n12(Nombro,N) :-
  integer(N), N<2000000000,!,
  S is N mod 1000000000,
  n12(SubMiliardoj,S),
  atomic_list_concat(['unu miliardo',SubMiliardoj],' ',Nombro).

n12(Nombro,N) :-
  integer(N), N<1000000000000,!,
  M is N div 1000000000,
  S is N mod 1000000000,
  n12(Miliardoj,M),
  n12(SubMiliardoj,S),
  atomic_list_concat([Miliardoj,'miliardoj',SubMiliardoj],' ',Nombro).

% kunmetu ambau direktojn en unu predikato

nombro(Nombro,N) :-
  integer(N), n12(Nombro,N);
  atom(Nombro), atom_codes(Nombro,Codes), phrase(n12(N),Codes),!.

% nombri lauvorte

nombru(De,Ghis) :-
  between(De,Ghis,N),
  n12(Nombro,N),
  write(Nombro),nl,fail.

% tio ankau funkcius, sed tre malrapida, do nur proksimume ghis 5-ciferaj nombroj 

%nombro(Nombro,N) :-
%  integer(N),
%  phrase(n12(N),List,[]),
%  atom_codes(Nombro,List),!.

% inventi nombrojn: phrase(n12(N),L,[]),atom_codes(X,L).






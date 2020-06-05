/* -*- Mode: Prolog -*- */

% 1..9
i(1) --> "I".
i(2) --> "II".
i(3) --> "III".

r1_9(N) --> i(N). % 1..3
r1_9(4) --> "IV". 
r1_9(5) --> "V".
r1_9(N) --> "V", i(Ni), { N is 5+Ni }. % 6..8
r1_9(9) --> "IX".

% 1..99
x(10) --> "X".
x(20) --> "XX".
x(30) --> "XXX".

r1_39(N) --> r1_9(N). % 1..9
r1_39(N) --> x(N).    % 10, 20, 30
r1_39(N) --> x(Nx), r1_9(N_), { N is Nx+N_ }.

r1_99(N)  --> r1_39(N). % 1..39
r1_99(40) --> "XL".
r1_99(N)  --> "XL", r1_9(N_),  { N is 40+N_ }. % 41..49
r1_99(50) --> "L".
r1_99(N)  --> "L",  r1_39(N_), { N is 50+N_ }. % 51..89
r1_99(90) --> "XC".
r1_99(N)  --> "XC", r1_9(N_),  { N is 90+N_ }. % 91..99

% 1..999
c(100) --> "C".
c(200) --> "CC".
c(300) --> "CCC".

r1_399(N) --> r1_99(N).
r1_399(N) --> c(N).
r1_399(N) --> c(Nc), r1_99(N_), { N is Nc+N_ }.

r1_999(N)   --> r1_399(N).
r1_999(400) --> "CD".
r1_999(N)   --> "CD", r1_99(N_),  { N is 400+N_ }. % 401..499
r1_999(500) --> "D".
r1_999(N)   --> "D",  r1_399(N_), { N is 500+N_ }. % 501..899
r1_999(900) --> "CM".
r1_999(N)   --> "CM", r1_99(N_),  { N is 900+N_ }. % 901..999

% 1..3999
m(1000) --> "M".
m(2000) --> "MM".
m(3000) --> "MMM".

r1_3999(N) --> r1_999(N).
r1_3999(N) --> m(N).
r1_3999(N) --> m(Nm), r1_999(N_), { N is Nm+N_}.

romia(Dec,Rom) :-
  number(Dec),
  phrase(r1_3999(Dec),RC),
  atom_codes(Rom,RC).

romia(Dec,Rom) :-
  atomic(Rom),
  atom_codes(Rom,RC),
  phrase(r1_3999(Dec),RC).

nombru(De,Ghis) :-
  between(De,Ghis,N),
  romia(N,Romia),
  write(Romia),nl,fail.

renombru(De,Ghis) :-
  between(De,Ghis,N),
  romia(N,Romia),
  write(Romia),
  write(' --> '),
  romia(N1,Romia),
  write(N1),
  nl,fail.






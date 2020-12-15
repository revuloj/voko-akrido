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

r1_39(NN) --> r1_9(NN). % 1..9
r1_39(NN) --> x(NN).    % 10, 20, 30
r1_39(NN) --> x(Nx), r1_9(N), { NN is Nx+N }.

r1_99(NN) --> r1_39(NN). % 1..39
r1_99(40) --> "XL".
r1_99(NN) --> "XL", r1_9(N),   { NN is 40+N }.  % 41..49
r1_99(50) --> "L".
r1_99(NN) --> "L",  r1_39(N_), { NN is 50+N_ }. % 51..89
r1_99(90) --> "XC".
r1_99(NN) --> "XC", r1_9(N),   { NN is 90+N }.  % 91..99

% 1..999
c(100) --> "C".
c(200) --> "CC".
c(300) --> "CCC".

r1_399(NNN) --> r1_99(NNN).
r1_399(NNN) --> c(NNN).
r1_399(NNN) --> c(Nc), r1_99(NN), { NNN is Nc+NN }.

r1_999(NNN) --> r1_399(NNN).
r1_999(400) --> "CD".
r1_999(NNN) --> "CD", r1_99(NN),   { NNN is 400+NN }.  % 401..499
r1_999(500) --> "D".
r1_999(NNN) --> "D",  r1_399(NN_), { NNN is 500+NN_ }. % 501..899
r1_999(900) --> "CM".
r1_999(NNN) --> "CM", r1_99(NN),   { NNN is 900+NN }.  % 901..999

% 1..3999
m(1000) --> "M".
m(2000) --> "MM".
m(3000) --> "MMM".

r1_3999(NNNN) --> r1_999(NNNN).
r1_3999(NNNN) --> m(NNNN).
r1_3999(NNNN) --> m(Nm), r1_999(NNN), { NNNN is Nm+NNN }.

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


/* alia pli simpla propono funkcias per limigoj (contraints), sed
% permesus ankaŭ malbonajn kiel IIXX = 1+9+10 = 20 ...,
% eble oni povus plie striktigi, maksimume tri el I, X, C, M estas permesitaj
% kaj cetere ĉiu dekstra devas esti pli malgranda ol maldekstra,
% sed ankoraŭ eblus IXV = 9+5 = 14 anst. XIV = 10 + 4:
% roman(N0) --> "I", { 1 #=< N0, N0 #=< 3, N1 #= N0-1}, roman(N1).

:- use_module(library(clpfd)).

dcg(Arabic) -->
    { Arabic in 1..3999 },
    roman(Arabic),
    !.

roman(Total) -->
    { Rest #>= 0 },
    { Total #= Value + Rest },
    digit(Value),
    roman(Rest).
roman(0) --> "".

digit(1000) --> "M".
digit(900) --> "CM".
digit(500) --> "D".
digit(400) --> "CD".
digit(100) --> "C".
digit(90) --> "XC".
digit(50) --> "L".
digit(40) --> "XL".
digit(10) --> "X".
digit(9) --> "IX".
digit(5) --> "V".
digit(4) --> "IV".
digit(1) --> "I".

% ?- phrase(dcg(N),`CCXCVIII`).
% ?- phrase(dcg(1298), Rs).
*/



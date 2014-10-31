:-consult('vortaro.pl').
%%:-consult('derivado.pl').
:-consult('vortana.pl').
:-consult('frazana.pl').
:-consult('legilo.pl').

/********** analizi unuopajn vortoj aw tutajn tekstojn ***************/

% analizas unuopan vorton
analizu_vorton(N) :-
	not(N = ''), atom_codes(N,C), % KOREKTU: la legilo ne atomigu la vortojn, sed uzu string/listoj(?)
	(
	    vortanalizo(C,V,S), format('~w (~w)~n',[V,S]);
	    vortpartoj(C,P), format('~w - malstrikte!~n',[P]);
	    format('~w - NE analizebla!~n',[N])
	),!.


% analizas tutan tekstodosieron
analizu_tekston(Txt) :-
        phrase_from_file(teksto(T),Txt,[encoding(utf8)]),
        forall(member(M,T),
          (
             M = v(V) *->  (analizu_vorton(V);true) ; true
      %       M = s(S) *->  write(S)
          )
        ),!.


/********************* analizaj funkcioj por frazoj ******************/

analizu_elementon(v(Vorto),Analizita) :-
  vortanalizo(Vorto,Dismeto,Speco),
  functor(Analizita,Speco,1), 
  term_variables(Analizita,[Dismeto]).

%analizu_elementon(s(Signoj),[]) :-
%  Rezulto=Signoj.
%analizu_elementon(s(_),[]).
analizu_elementon(s(Signoj),s(Atom)) :-
  atom_codes(Atom,Signoj).

povorta_analizo(Signoj,Vortoj) :-
%	vortigu(Signoj,Frazo),!,
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj).


s_filter(s(_)).

frazanalizo(Signoj,Rezulto) :-
%	vortigu(Signoj,Frazo),!,
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj),
        %%% KOREKTU: necesas adapti "frazo" tiel, ke ĝi akzeptas la alternadon de analizita vorto kaj signoj en la listo...
        %%% alternative eble uzu dcg "frazo", char ghi kunigas chion ghis signo (komo ktp.) en unu listo...
        exclude(s_filter,Vortoj,NurVortoj),!,
        phrase(f_frazeto(Rezulto),NurVortoj). 
	%frazo(Vortoj,Rezulto),
	%eligu_strukturon(Rezulto).

% tio funkciis nur, ĉar "vortigu" permesas
% ĉesi jam antaŭ la fino de la frazo
% eble tio estis iom neeleganta maniero -> aldonu en la dcg gramatiko de legilo
% varianton, kiu permesas ignori reston...?

parta_frazanalizo(Signoj,Rezulto) :-
%	vortigu(Signoj,Frazo),
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj),
        %%% KOREKTU: necesas adapti "frazo" tiel, ke ĝi akzeptas la alternadon de analizita vorto kaj signoj en la listo...
	frazo(Vortoj,Rezulto),!,
	eligu_strukturon(Rezulto).


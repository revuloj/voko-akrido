:-consult('vortaro.pl').
:-consult('derivado.pl').
:-consult('vortana.pl').
:-consult('frazana.pl').
:-consult('legilo.pl').

/********** analizi unuopajn vortoj aw tutajn tekstojn ***************/

% analizas unuopan vorton
analizu_vorton(N) :-
	not(N = ''),
	(
	    vortanalizo_strikta(N,[V,S]), format('~w (~w)~n',[V,S]);
	    vortanalizo_malstrikta(N,[V,S]), format('~w (~w) - malstrikte!~n',[V,S]);
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

analizu_elementon(v(Vorto),Rezulto) :-
  vortanalizo(Vorto,Rezulto).

analizu_elementon(s(Signoj),[]) :-
  Rezulto=Signoj.

povorta_analizo(Signoj,Vortoj) :-
%	vortigu(Signoj,Frazo),!,
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj).

frazanalizo(Signoj,Rezulto) :-
%	vortigu(Signoj,Frazo),!,
        phrase(teksto(Frazo),Signoj),
	maplist(analizu_elementon,Frazo,Vortoj),
        %%% KOREKTU: necesas adapti "frazo" tiel, ke ĝi akzeptas la alternadon de analizita vorto kaj signoj en la listo...
        %%% alternative eble uzu dcg "frazo", char ghi kunigas chion ghis signo (komo ktp.) en unu listo...
	frazo(Vortoj,Rezulto),
	eligu_strukturon(Rezulto).

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

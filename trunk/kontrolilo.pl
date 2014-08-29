:-consult('vortaro.pl').
:-consult('derivado.pl').
:-consult('vortana.pl').
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

% analizas unuopan vorton kaj redonas gxin se analizebla
% aw enkrampigas gxin, se ne analizebla
kontrolu_vorton(N) :-
	not(N = ''),
	(
	    vortanalizo_strikta(N,_), write(N);
	    vortanalizo_malstrikta(N,Y), write(Y);
	    format('[_~w_]',N)
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

% kontrolas tutan tekstodosieron
kontrolu_tekston(Txt) :-
        phrase_from_file(teksto(T),Txt,[encoding(utf8)]),
        forall(member(M,T),
          (
             M = v(V) *->  (kontrolu_vorton(V);true) ; 
             M = s(S) *->  write(S)
          )
        ),!.





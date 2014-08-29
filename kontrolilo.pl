:-consult('vortaro.pl').
:-consult('derivado.pl').
:-consult('vortana.pl').

/**************** helpfunkcioj por legi el dosiero *************/

% cxu litero?
is_letter(C,C1) :-
	C >= 97, C =< 122, C1=C.         % 'a'...'z'
is_letter(C,C1) :-
	C >= 65, C =< 90, C1 is C-65+97. % 'A'...'Z' -> 'a'...'z'
is_letter(39,39).                  % apostrofo

% cxu alia signo?
is_sign(C) :-
	memberchk(C,",.- "), put(C).

% legi vorton el dosiero
legu_vorton1(F,[C|R]) :-
	get0(F,C1), 
	is_letter(C1,C), !,
	legu_vorton1(F,R).
legu_vorton1(_,[]).

legu_vorton2(F,[C|R]) :-
	get0(F,C1),
	(
         is_letter(C1,C) *-> 
           legu_vorton2(F,R);
	   fail
	),!.
legu_vorton2(_,[]).

/********** analizi unuopajn vortoj aw tutajn tekstojn ***************/

% analizas unuopan vorton
analizu_vorton(N) :-
	not(N = ''),
	(
	    vortanalizo_strikta(N,Y), writeq(Y);
	    vortanalizo_malstrikta(N,Y), write('malstrikte: '), writeq(Y);
	    write(' ne analizebla: '),writeq(N)
	),nl,!.

% analizas unuopan vorton kaj redonas gxin se analizebla
% aw enkrampigas gxin, se ne analizebla
kontrolu_vorton(N) :-
	not(N = ''),
	(
	    vortanalizo_strikta(N,_), write(N), write(' ');
	    vortanalizo_malstrikta(N,Y), write(Y), write(' ');
	    write('['),write(N),write('] ')
	),!.

% analizas tutan tekstodosieron
analizu_tekston(Txt) :-
%	legu,
	open(Txt,read,F),!,
	repeat,
  	legu_vorton1(F,X), name(N,X),
	(analizu_vorton(N);true),
	at_end_of_stream(F),!,close(F).

% kontrolas tutan tekstodosieron
kontrolu_tekston(Txt) :-
%	legu,
	open(Txt,read,F),!,
	repeat,
  	legu_vorton2(F,X), name(N,X),
	(kontrolu_vorton(N);true),
	at_end_of_stream(F),!,close(F).





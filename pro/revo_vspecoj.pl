/* -*- Mode: Prolog -*- */

:- use_module(library(sgml)).
:- use_module(library(xpath)).
:- use_module(library(semweb/rdf_db)).

:- use_module('../vortana2/analizilo.pl').


:- dynamic fak_difino/4, kls_difino/4.

fak_dif('work/fak_difino.csv').
kls_dif('work/kls_difino.csv').
dif_vspec('work/dif_vspec.csv').

/** <module> Kreilo de Revo-vortaro

  Kreas liston de Revo-difinoj klasigitaj laŭ fako kaj laŭ kategorio (vortklaso: urboj, muzikiloj ktp.)

  Por eltrovi vortspecojn kiel besto aŭ persono per referenco al Voko-klasoj
  necesas enlegi ilin el dosiero $VOKO/owl/voko.rdf antaŭ la traserĉado de la XML-artikoloj.

  La procedo antaŭsupozas, ke Voko-klasoj troviĝas en /home/revo/voko/owl,
  Revo-artikoloj en /home/revo/revo/xml kaj la rezulta vortaro iros al ./

  @author Wolfram Diestel
  @license GPL
  @year 2018
 */





% %%%%%%%%%
% bazaj predikatoj por traserĉi artikolojn pri markoj, klasoj, fakoj, difinoj kaj skribi ilin
% %%%%%%%%

legu_difinojn :-
    fak_dif(FakDos),
    retractall(fak_difino(_,_,_,_)),
    csv_read_file(FakDos, [_|Rows1], [functor(fak_difino), arity(4), separator(0';)]),
    maplist(assert, Rows1),
    kls_dif(KlsDos),
    retractall(kls_difino(_,_,_,_)),
    csv_read_file(KlsDos, [_|Rows2], [functor(kls_difino), arity(4), separator(0';)]),
    maplist(assert, Rows2).

vspec_difinoj :-
    retractall(ana(_)),
    forall(
      fak_difino(_,Dif,_,_),
      ( % write('.'),
	once((
          vspec_difino(Dif,Spc),
	  assertz(ana(Spc))
	;
	throw(ana_err(Dif))
	     ))
      )
	).

skribu :-
    dif_vspec(File),
    open(File,write,Out),
    format(Out,'vorto;vspec~n',[]),
    with_output_to(Out,
      forall(
        ana(Paroj),
        (Paroj \= [] -> skribu(Paroj); true)
 	  )
    ),
    close(Out).


skribu([]) :- format('.;FIN~n').
skribu([V-S|Paroj]) :-
    format('~w;~w~n',[V,S]),
    skribu(Paroj).


% redonas vortojn el difino kiel paroj Vorto-Speco
vspec_difino(Difino,Specoj) :-
    atom_codes(Difino,Kodoj),
    preparu_tekston(Kodoj,Teksto),
    vspec_listo(Teksto,Specoj), !.

vspec_listo([],[]).
vspec_listo([s(_)|Vj],Sj) :- vspec_listo(Vj,Sj). % ignoru specojn , interpunkcion, ciferojn
vspec_listo([v([_])|Vj],Sj) :- vspec_listo(Vj,Sj). % ignoru unu-literajn vortojn
vspec_listo([n([])|Vj],Sj) :- !, vspec_listo(Vj,Sj). % transprenu nombron sen analizo, teksto-gramatiko momente ne kreas n(N)...
vspec_listo([n(N)|Vj],[N-nombr|Sj]) :- vspec_listo(Vj,Sj). % transprenu nombron sen analizo, teksto-gramatiko momente ne kreas n(N)...

vspec_listo([v(V)|Vj],[Va-S|Sj]) :-
    atom_codes(Va,V),
    once((
	kls_difino(S,_,_,Va)
        ;
        vortanalizo(V,_A,S,_U),!
	)),
    vspec_listo(Vj,Sj).

vspec_listo([v(V)|Vj],[Va-S|Sj]) :-
    vortanalizo(V,_A,S,_U),!,
    atom_codes(Va,V),
    vspec_listo(Vj,Sj).

vspec_listo([v(V)|Vj],[Va-nek|Sj]) :-
    atom_codes(Va,V),
    format('ne povis analizi ''~w''~n',[Va]),
    vspec_listo(Vj,Sj).

:- module(gramatiko,[
	      analyze/3, % analizado de vorto
	      reduce/2 % forigi krampojn kaj spacojn el analizita esprimo
	  ]).
 
:- use_module(vorto_gra).

%:- dynamic min_max_len/3, gra_debug/1.
%:- multifile '&'/1, gra_debug/1.
%:- dynamic vorto_gra:vorto/5.

/********************************************************************/



% helpofunkcioj por uzi la gramatikon

analyze(Vrt,Ana,Spc) :-
  atom(Vrt),
  vorto(_,Spc,Vrt,Ana,0).

analyze(Vrt,Ana,Spc) :-
  is_list(Vrt),
  atom_codes(Atom,Vrt),
  vorto(_,Spc,Atom,Ana,0).

analyze_perf(Vrt,Ana,Spc) :-
  statistics(process_cputime,C1),
  statistics(inferences,I1),
  analyze(Vrt,Ana,Spc),
  statistics(process_cputime,C2),
  statistics(inferences,I2),
  I is I2-I1,
  C is C2-C1,
  format('inferences: ~w, cpu: ~w~n',[I,C]).

% forigas krampojn kaj spacojn el la rezulto-termo
reduce(Term,Flat) :-
  format(codes(A),'~w',[Term]),
  vorto_gra:reduce_(A,F,"() "),
  atom_codes(Flat,F).





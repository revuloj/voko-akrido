:- module(gramatiko,[
	      analyze/3, % analizado de vorto
        analyze_pt/4,
	      %reduce/2, % forigi krampojn kaj spacojn el analizita esprimo
        ana_html/2,
        ana_txt/2 
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

analyze_pt(Vrt,Ana,Spc,Pt) :-
  analyze(Vrt,Ana,Spc),
  vorto_gra:poentoj(Ana,Pt).

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
% kaj anstatŭigas / per mezpunkto (\u00b7)
% la predikatoj por vorto_gra:reduce estas en regul_trf.pl
/***
reduce(Term,Flat) :-
  format(codes(A),'~w',[Term]),
  vorto_gra:reduce_(A,F,"() "), % difinta en regul_trf.pl
  atom_codes(Flat,F).
***/

ana_html(Ana,[element(span,[class=Classes],Content)]) :-
  vorto_gra:ana_html_(Ana,Content,ClsLst),!, % vd. en regul_trf
  atomic_list_concat(ClsLst,' ',Classes).

ana_txt(Ana,Txt) :-
  vorto_gra:ana_txt_(Ana,Lst),!, % vd. en regul_trf
  atomic_list_concat(Lst,Txt).



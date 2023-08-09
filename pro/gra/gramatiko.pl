:- module(gramatiko,[
	      analyze/3, % analizado de vorto, solvo psot solvo redonota
        analyze/4, % analizado de 1 ĝis pluraj solvoj kaj redono de la malplej punata (poentoj)
	      %reduce/2, % forigi krampojn kaj spacojn el analizita esprimo
        ana_html/2,
        ana_txt/2 
	  ]).
 
:- use_module(vorto_gra).

%:- dynamic min_max_len/3, gra_debug/1.
%:- multifile '&'/1, gra_debug/1.
%:- dynamic vorto_gra:vorto/5.

analyze_max_infer(1000000). % 1 mio: maksimume tiom da rezonpaŝoj (inferences) daŭru analizo
% analyze_max_infer(10000000). % 10 mio: maksimume tiom da rezonpaŝoj (inferences) daŭru analizo

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
  analyze_max_infer(MaxI),
  call_with_inference_limit(
    analyze(Vrt,Ana,Spc),
    MaxI,
    EI),
  once((
    EI = inference_limit_exceeded, fail
    ;
    nonvar(Ana), vorto_gra:poentoj(Ana,Pt)
  )).

analyze(Vorto,Ana,Spc,Pt) :- 
  aggregate(min(P,A-S),
    limit(4, distinct(( % distinct() altigas la ŝancon ke ni trovos la plej bonan solvon, 
                        % aparte ĉe iom longaj vortoj kiel "laktobovino", "ordotenanta",
                        % sed postulas ja kompense pli da kalkultempo!
        analyze_pt(Vorto,A,S,P),
        debug(analizo,'~dp: ~w~n',[P,A]),
        (P=<4,! ; P>4) % se poentoj estas pli ol kvar serĉu alternativajn analizeblojn
    ))),
    min(Pt,Ana-Spc)).

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

ana_html(Ana,[element(span,ClsAttr,Content)]) :-
  vorto_gra:ana_html_(Ana,Content,ClsLst),!, % vd. en regul_trf
  once((
    setof(C,(member(C,ClsLst),C\=''),CL),
    atomic_list_concat(CL,' ',Classes),
    ClsAttr = [class=Classes]
    ; 
    ClsAttr = []
  )).

ana_txt(Ana,Txt) :-
  vorto_gra:ana_txt_(Ana,Lst),!, % vd. en regul_trf
  atomic_list_concat(Lst,Txt).



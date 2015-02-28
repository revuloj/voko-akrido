% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo

:- dynamic min_max_len/3, '&'/1.
:- multifile gra_debug/1.

%%% traduki regulesprimojn al normalaj Prologo-faktoj....
% 
term_expansion( RuleHead <= RuleBody , RuleTranslated ) :-
   rule_head(RuleHead,Vrt,Rez,Depth,PredHead),!,
   once(rule_body(RuleHead,RuleBody,Vrt,Rez,Depth,PredBody)),
   RuleTranslated = (PredHead :- PredBody),
 format('  ~w~n',[RuleTranslated]).


rule_head(RuleHead,Vrt,Rez,Depth,PredHead) :-
   RuleHead =..  [RuleName|RuleArgs],
 format('# ~w:~n',[RuleName]),
   append(RuleArgs,[Vrt,Rez,Depth],Args),
   PredHead =.. [RuleName|Args].

rule_body(RuleHead,RuleExp ~> PostCond,Vrt,Rez,Depth,PredBody) :-
  rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,FirstPart),
  PredBody =.. [',',FirstPart,PostCond].

rule_body(RuleHead,RuleExp,Vrt,Rez,Depth,PredBody) :-
  rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredBody).

rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredExp) :-
  RuleHead =.. [_,RuleScheme|_],
  RuleExp =.. [Op|Refs],
  memberchk(Op,['+','/','~','-','*']),!,
  Refs = [R1,R2],
  Rezulto =.. [Op,Rez1,Rez2], 

  rule_ref(R1,V1,Rez1,D1,RRef1),
  rule_ref(R2,Rest,Rez2,D1,RRef2),
  splitter(RuleScheme,R1,R2,Vrt,V1,Rest,Splitter),

  PredExp =  (
   debug(Depth,provas,RuleScheme,Vrt), 
%     atom_concat(V1,Rest,Vrt), 
%     V1 \= '', Rest \= '',
     Splitter,
     D1 is Depth +1,
     RRef2,
     RRef1,
     Rez=Rezulto,
   debug(Depth,rezulto,RuleScheme,Rez) 
    ).
%  term_variables(PredExp, [A,B,C,D,E,F]).

rule_exp(_,RuleExp,Vrt,Rez,Depth,PredExp) :-
  rule_ref(RuleExp,Vrt,Rez,Depth,PredExp).

rule_ref(&RuleRef,Vrt,Rez,Depth,RuleCall) :- !,
  RuleRef =.. [RuleName|RuleArgs],
  append([RuleArgs,[Vrt,Rez,Depth]],Args),
  RuleCall =.. [RuleName|Args].

rule_ref(DictSearch,Vrt,Vrt,_,DictSearch) :-
  DictSearch =.. [_,Vrt|_].

splitter(RuleScheme,RuleRef1,RuleRef2,Vrt,V1,Rest,Splitter) :-
    get_rule_min_max(RuleRef1,Min1,Max1),
    get_rule_min_max(RuleRef2,Min2,Max2),
%    !,
    	
     (RuleScheme == pD ->
        % prefikso pli mallonga ol la resto...
        Splitter = (
          between(Min1,Max1,L1),
          sub_atom(Vrt,0,L1,L2,V1),
          between(Min2,Max2,L2),
          sub_atom(Vrt,L1,L2,0,Rest)
        )
     ;
       % sufiksoj kaj finaĵoj normale estas mallongaj...
       Splitter = (
         between(Min2,Max2,L2),
         sub_atom(Vrt,L1,L2,0,Rest), 
         between(Min1,Max1,L1),
         sub_atom(Vrt,0,L1,L2,V1)
     )).


/********************************************************************/

gra_debug(false). % default

debug(Depth,Msg,Scheme,Rezulto) :-
  gra_debug(true)
  ->
    sub_atom('------------------------------------------------------------------------------------------',0,Depth,_,Indent),
    format('~w ~w ~w ~w~n',[Indent,Msg,Scheme,Rezulto])
  ; true.

% helpofunkcioj pro uzi la gramatikon

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
  reduce_(A,F),
  atom_codes(Flat,F).

reduce_([],[]).
reduce_([L|Ls],[F|Fs]) :-
  memberchk(L,"() ") 
   -> reduce_(Ls,[F|Fs])
   ; F=L, reduce_(Ls,Fs).

get_rule_min_max(&RuleRef,Min,Max) :-
  RuleRef =.. [_,RuleId|_],
  (nonvar(RuleId), min_max_len(RuleId,Mn,Mx) -> 
     Min is max(1,min(Mn,99)),
     Max is min(Mx,99),
     debug(0,rmin,RuleId,Min),
     debug(0,rmax,RuleId,Max)
  ; 
     Min is 1, 
     Max is 99). 

get_rule_min_max(Search,Min,Max) :- 
    Search =.. [Pred|Args],
    length(Args,Arity),
%    atom_length(Vrt,Len),
    get_min_max(Pred/Arity,Mn,Mx),
    Min is max(1,min(Mn,99)),
    Max is min(Mx,99),
    debug(0,smin,Pred,Min),
    debug(0,smax,Pred,Max).

get_min_max(Pred/Arity,Min,Max) :-
  min_max_len(Pred/Arity,Min,Max) -> true
  ; % min/max still not known -> calculate it
    functor(Func,Pred,Arity),
    Func =.. [_,Vrt|_],
    findall(L,
	    (call(Func),atom_length(Vrt,L)),
            Lens),
    max_list(Lens,Max),
    min_list(Lens,Min),
    assert(min_max_len(Pred/Arity,Min,Max)).

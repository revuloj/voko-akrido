:- op( 1000, xfx, user:(<=) ).
:- op( 200, fx, user:(&) ).

%%% traduki regulesprimojn al normalaj Prologo-faktoj....

term_expansion(
    ( RuleH1 <= RuleH2 :- RuleBody ),
    ( RuleHeadTranslated :- RuleBodyTranslated )
  ) :-
        RuleH1 =.. [RuleName|Args1],
format('# ~w:~n',[RuleName]),
	RuleH2 =.. [Op|Refs],
	memberchk(Op,['+','/','~','-']),!,
format('1a:  ~k ~k~n',[Op,Refs]),
	RuleHeadTranslated =.. [RuleName,Op,Refs|Args1],
format('1b:  ~k~n',[RuleHeadTranslated]),
        RuleBodyTranslated = RuleBody.

term_expansion(
    ( RuleH1 <= RuleH2 ),
    ( RuleHeadTranslated )
  ) :-
        RuleH1 =.. [RuleName|Args1],
format('# ~w:~n',[RuleName]),
	RuleH2 =.. [Op|Refs],
        memberchk(Op,['+','/','~','-']),!,
format('2:  ~k ~k~n',[Op,Refs]),
	RuleHeadTranslated =.. [RuleName,Op,Refs|Args1].

term_expansion(
    ( RuleH1 <= RuleH2 ),
    ( RuleHeadTranslated )
  ) :-
        RuleH1 =.. [RuleName|Args1],
format('# ~w:~n',[RuleName]),
format('3:  ~k~n',[RuleH2]),
	RuleHeadTranslated =.. [RuleName,RuleH2|Args1].

% voku ekz: 
% apply_rule(&vorto(Spc),'eniri',Rezulto).
  
apply_rule(&RuleRef,Vrt,Rez) :-
  RuleRef =.. [RuleName,Spc], 
  current_predicate(RuleName/2), % !, cut problematic because of rule body...
  RuleScheme =.. [RuleName,SubRule,Spc], 
  call(RuleScheme),
  apply_rule(SubRule,Vrt,Rez).

% regulo por duparta "vorto"
apply_rule(&RuleRef,Vrt,Rez) :-
  RuleRef =.. [RuleName,Spc], 
  current_predicate(RuleName/3), % !, cut problematic because of rule body...
  RuleScheme =.. [RuleName,Op,Partoj,Spc], 
  call(RuleScheme),
  apply_prt_rules(Partoj,Vrt,Rezultoj),
  Rez =.. [Op|Rezultoj].

% bazaj reguloj referencantaj al vortaro
apply_rule(DictSearch,Ero,Ero) :-
  DictSearch =.. [Pred,Ero|_], Pred \= '&',
  % Pred \= regulo, % se estus jam konata, ke temas pri sercho sufichus call(Sercho)...
  call(DictSearch).


apply_prt_rules([],'',[]).

apply_prt_rules([Prt|Partoj],Vrt,[Rez|Rezultoj]) :-
    atom_concat(V1,Rest,Vrt),
    % pli efike eble estus havi minimuman kaj maksimuman longecon
    % kaj uzi between + sub_atom...
    atom_length(V1,L1), L1>0, 
    %atom_length(Rest,L2), L2>0,
    apply_rule(Prt,V1,Rez),
    apply_prt_rules(Partoj,Rest,Rezultoj).
    




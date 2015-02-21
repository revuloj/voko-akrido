% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo

%%% traduki regulesprimojn al normalaj Prologo-faktoj....
% 
term_expansion( RuleHead <= RuleBody , RuleTranslated ) :-
   RuleHead =.. [RuleName|RuleArgs],
 format('# ~w:~n',[RuleName]),
   rule_expansion(RuleBody,RuleTerm,RuleCond),
   RuleTranslated =.. [RuleName,RuleTerm,RuleArgs,RuleCond],
 format('  ~w~n',[RuleTranslated]).

% regulo kun postkondiĉo
% regulo: rnomo(Args) <= Exp ~> PK
% prologo: rnomo(H,RuleTerm,Args,PK)
rule_expansion(RuleExp ~> PostCond,RuleTerm,[PostCond]) :-
  rule_expression(RuleExp,RuleTerm),!.

% send postkondiĉo
rule_expansion(RuleExp,RuleTerm,[]) :-
  rule_expression(RuleExp,RuleTerm).

% regulesprimo kun du termoj, ekz. p(..) / r(..) aŭ p(..) + &kdrv(...)
rule_expression(RuleExp,[Op|Refs]) :-
    RuleExp =.. [Op|Refs],
    memberchk(Op,['+','/','~','-','*']),!.

% simpla regulesprimo kun nur unu termo, ekz. r(..) aŭ &kdrv(...)
rule_expression(RuleExp,RuleExp).


debug(Depth,Msg,Scheme,Rezulto) :-
  sub_atom('------------------------------------------------------------------------------------------',0,Depth,_,Indent),
  format('~w ~w ~w ~w~n',[Indent,Msg,Scheme,Rezulto]).

% voku ekz: 
% apply_rule(&vorto(Spc),'eniri',Rezulto).
  
apply_rule(RuleRef,Vrt,Rez) :- apply_rule(RuleRef,Vrt,Rez,0).

% regulo unuparta
apply_rule(&RuleRef,Vrt,Rez,Depth) :-
  % retrovu regulon laŭ la referenco
  RuleRef =.. [RuleName|Args], 
  %current_predicate(RuleName/2), 
  RuleScheme =.. [RuleName,SubRule,Args,Post], 
  call(RuleScheme), \+ is_list(SubRule),
  % apliku la regulesprimon al la vorto
%  debug(Depth,provas,RuleScheme,Vrt),
  D1 is Depth+1,
  apply_rule(SubRule,Vrt,Rez,D1),
  (Post = [Cond] *-> Cond; true),
  debug(Depth,rezulto,RuleScheme,Rez).

% regulo duparta 
apply_rule(&RuleRef,Vrt,Rez,Depth) :-
  % retrovu regulon laŭ la referenco
  RuleRef =.. [RuleName|Args], 
  %current_predicate(RuleName/3), 
  RuleScheme =.. [RuleName,SubRules,Args,Post], 
  call(RuleScheme), SubRules = [Op|Partoj],
  % apliku la regulesprimojn al la vorto
%  debug(Depth,provas,RuleScheme,Vrt),
  D1 is Depth+1,
  apply_prt_rules(Partoj,Vrt,Rezultoj,D1),
  (Post = [Cond] *-> Cond; true),
  Rez =.. [Op|Rezultoj],
  debug(Depth,rezulto,RuleScheme,Rez).

% bazaj reguloj referencantaj al vortaro
apply_rule(DictSearch,Ero,Ero,_) :-
  DictSearch =.. [Pred,Ero|_], Pred \= '&',
  % Pred \= regulo, % se estus jam konata, ke temas pri sercho sufichus call(Sercho)...
  call(DictSearch).


apply_prt_rules([],'',[],_).

apply_prt_rules([Prt|Partoj],Vrt,[Rez|Rezultoj],Depth) :-
    atom_concat(V1,Rest,Vrt), V1 \='',
    % evitu senfinajn ciklojn che maldekstre rikuraj reguloj
    % (Partoj \= [] -> Rest \= ''; true),
    (Rest = '' -> Partoj = []; true),
    % pli efike eble estus havi minimuman kaj maksimuman longecon
    % kaj uzi between + sub_atom...?
    apply_rule(Prt,V1,Rez,Depth),
    apply_prt_rules(Partoj,Rest,Rezultoj,Depth).
    




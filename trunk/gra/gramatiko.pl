% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo

:- dynamic min_max_len/3, '&'/1.
:- multifile gra_debug/1.

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
  apply_rule(&vorto(_,Spc),Vrt,Ana,0).

analyze(Vrt,Ana,Spc) :-
  is_list(Vrt),
  atom_codes(Atom,Vrt),
  apply_rule(&vorto(_,Spc),Atom,Ana,0).

% forigas krampojn kaj spacojn el la rezulo-termo
reduce(Term,Flat) :-
  format(codes(A),'~w',[Term]),
  reduce_(A,F),
  atom_codes(Flat,F).

reduce_([],[]).
reduce_([L|Ls],[F|Fs]) :-
  memberchk(L,"() ") 
   -> reduce_(Ls,[F|Fs])
   ; F=L, reduce_(Ls,Fs).

% voku ekz: 
% apply_rule(&vorto(RuleId,Spc),'eniri',Rezulto).

apply_rule(RuleRef,Vrt,Rez) :- apply_rule(RuleRef,Vrt,Rez,0).

% regulo unuparta
apply_rule(&RuleRef,Vrt,Rez,Depth) :-
  % retrovu regulon laŭ la referenco
  RuleRef =.. [RuleName|Args], 
  %current_predicate(RuleName/2), 
  RuleScheme =.. [RuleName,SubRule,Args,Post], 
  call(RuleScheme), \+ is_list(SubRule),
  % pli efike, estus, se la regulo nun mem deprenus
  % vort-parton el la tuta lau la indikoj min_max...
  % per simpla check nur shparighas la aplikado de la regulo...
  check_length(Args,Vrt),
  % apliku la regulesprimon al la vorto
%  debug(Depth,provas,RuleScheme,Vrt),
  D1 is Depth+1,
  apply_rule(SubRule,Vrt,Rez,D1),
  % apliku postkondiĉon
  (Post = [Cond] *-> Cond; true),
  debug(Depth,rezulto,RuleScheme,Rez).

% regulo duparta 
apply_rule(&RuleRef,Vrt,Rez,Depth) :-
  % retrovu regulon laŭ la referenco
  RuleRef =.. [RuleName|Args], 
  %current_predicate(RuleName/3), 
  RuleScheme =.. [RuleName,SubRules,Args,Post], 
  call(RuleScheme), SubRules = [Op|Partoj],
  % pli efike, estus, se la regulo nun mem deprenus
  % vort-parton el la tuta lau la indikoj min_max...
  % per simpla check nur shparighas la aplikado de la regulo...
  check_length(Args,Vrt),
  % apliku la regulesprimojn al la vorto
%  debug(Depth,provas,RuleScheme,Vrt),
  D1 is Depth+1,
  apply_prt_rules(Partoj,Vrt,Rezultoj,D1),
  % apliku postkondiĉon
  (Post = [Cond] *-> Cond; true),
  Rez =.. [Op|Rezultoj],
  debug(Depth,rezulto,RuleScheme,Rez).

% bazaj reguloj referencantaj al vortaro
apply_rule(DictSearch,Ero,Ero,_) :-
  DictSearch =.. [Pred,Ero|_], Pred \= '&',
% pli malrapide tamen, verŝajne valorus
% limigi la longecon nur che pli supraj regulaplikoj
% kaj nencesus ankau interrompi, kiam
% longeco forlasas la [min,max] intervalon
%  check_length(DictSearch),
  call(DictSearch).


apply_prt_rules([],'',[],_).

apply_prt_rules([Prt|Partoj],Vrt,[Rez|Rezultoj],Depth) :-
%% ne funkcias, char konkrete regulo ankorau ne elektighis...
%% oni povus nur kalkuli min, max surbaze de chiuj reguloj kun sama rule_ref
%% sed tio estas malpli efika
/**
    once(get_rule_min_max(Prt,Vrt,Min,Max)),
    between(Min,Max,L),
    sub_atom(Vrt,0,L,_,V1),
    (L = Max -> Partoj = []; true),
**/
    atom_concat(V1,Rest,Vrt), V1 \='',
    % evitu senfinajn ciklojn che maldekstre rikuraj reguloj
    % (Partoj \= [] -> Rest \= ''; true),
    (Rest = '' -> Partoj = []; true),
    % pli efike eble estus havi minimuman kaj maksimuman longecon
    % kaj uzi between + sub_atom...?
    apply_rule(Prt,V1,Rez,Depth),

    atom_concat(V1,Rest,Vrt),
    apply_prt_rules(Partoj,Rest,Rezultoj,Depth).

check_length([RuleId|_],Vrt) :-
  % kontrolu la longecon de Vrt
  min_max_len(RuleId,Min,Max) 
    -> atom_length(Vrt,Len), between(Min,Max,Len)
    ; true.

check_length(DictSearch) :-
  % analizetu la serchon
  DictSearch =.. [Pred,Vrt|Rest],
  length(Rest,A), Arity is A+1,
  atom_length(Vrt,Len),
  % kontrolu la longecon de Vrt
  get_min_max(Pred/Arity,Min,Max),
  between(Min,Max,Len).

get_rule_min_max(&RuleRef,Vrt,Min,Max) :-
  RuleRef =.. [_,RuleId|_],
  atom_length(Vrt,Len),
  (nonvar(RuleId), min_max_len(RuleId,Mn,Mx) ->
     Min is max(1,min(Mn,Len)),
     Max is min(Mx,Len),
     debug(0,rmin,RuleId,Min),
     debug(0,rmax,RuleId,Max)
  ; 
     Min is 1, 
     Max is Len). 

get_rule_min_max(Search,Vrt,Min,Max) :- 
    Search =.. [Pred|Args],
    length(Args,Arity),
    atom_length(Vrt,Len),
    get_min_max(Pred/Arity,Mn,Mx),
    Min is max(1,min(Mn,Len)),
    Max is min(Mx,Len),
    debug(0,smin,RuleId,Min),
    debug(0,smax,RuleId,Max).

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

    




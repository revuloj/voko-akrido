% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo

:- dynamic min_max_len/3, '&'/1.
:- multifile gra_debug/1.

/*********
:- consult('../vrt/v_revo_nomoj.pl').

sub(X,X).
% sub(X,Z) :- sub(X,Y), sub(Y,Z).
sub(best,subst).
sub(pers,best).
sub(pers,subst).

sub(parc,pers).
sub(parc,best).
sub(parc,subst).

sub(ntr,verb).
sub(tr,verb).
sub(perspron,pron).

subspc(S1,S2) :-
  sub(S1,S2), !.

ns(nj,pers).
ns(ĉj,pers).
nr('Petr',pers).
r(patr,parc).
v(mi,perspron).

nk(Nom,Spc) :- 
    sub(Spc,pers),
    (r(Nomo,Spc); nr(Nomo,Spc)),
    sub_atom('aeioujŭrlnm',_,1,_,Lit),
    sub_atom(Nomo,B,1,_,Lit),
    B_1 is B+1,
    sub_atom(Nomo,0,B_1,_,Nom).

****/

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

  get_rule_min_max(R1,Min1,Max1),
  get_rule_min_max(R2,Min2,Max2),

  PredExp =  (
   debug(Depth,provas,RuleScheme,Vrt), 
%     atom_concat(V1,Rest,Vrt), 
%     V1 \= '', Rest \= '',


%     between(Min1,Max1,L1),
%     sub_atom(Vrt,0,L1,L2,V1),
%     between(Min2,Max2,L2),
%     sub_atom(Vrt,L1,L2,0,Rest), 

     % sufiksoj kaj finaĵoj normale
     % estas mallongaj...	      
     between(Min2,Max2,L2),
     sub_atom(Vrt,L1,L2,0,Rest), 
     between(Min1,Max1,L1),
     sub_atom(Vrt,0,L1,L2,V1),
 
     D1 is Depth +1,
     RRef1,
     RRef2,
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


/**
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
**/

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

/* -*- Mode: Prolog -*- */
% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1120, xfx, user:(<-) ). % disigas regulo-kapon, de esceptesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo
%:- op( 500, yfx, user:(~) ). % signas disigindajn vortojn

:- dynamic min_max_len/3, gra_debug/1.
:- multifile '&'/1, gra_debug/1.
:- dynamic vorto_gra:vorto/5.

/**
   transformas la regulojn de la gramatiko (vorto_gra) al interpretebla Prologo-lingvo.
   Uziĝas term_expansion por tiu transformado.
*/

gra_debug(false). % default

debug(Depth,Msg,Scheme,Rezulto) :-
  gra_debug(true)
  ->
    sub_atom('------------------------------------------------------------------------------------------',0,Depth,_,Indent),
    format('~w ~w ~w ~w~n',[Indent,Msg,Scheme,Rezulto])
  ; true.

reduce_full(Term,Flat) :-
  format(codes(A),'~w',[Term]),
  reduce_(A,F,"/*+~-() "),
  atom_codes(Flat,F).

reduce_([],[],_).

reduce_([L|Ls],F,DelLetters) :-
  string_code(_,DelLetters,L),!, % memberchk(L,DelLetters),!, 
  reduce_(Ls,F,DelLetters).

reduce_([0'-,0'(,0'-,0'),0'-|Ls],[8212|F],DelLetters) :- !, % / -> |
  reduce_(Ls,F,DelLetters).

reduce_([0'/,0'(,0'/,0'),0'/|Ls],[124|F],DelLetters) :- !, % / -> |
  reduce_(Ls,F,DelLetters).

reduce_([0'/|Ls],[183|F],DelLetters) :- !, % / -> middot (\u00b7)
  reduce_(Ls,F,DelLetters).

reduce_([L|Ls],[L|Fs],DelLetters) :-
  % \+ memberchk(L,"() "), 
  reduce_(Ls,Fs,DelLetters).

%%% traduki regulesprimojn al normalaj Prologo-faktoj....
%% la maldekstra parto (kapo) tradukiĝas per rule_head
%% la dekstra parto (korpo) per rule_body

term_expansion( RuleHead <= RuleBody , RuleTranslated ) :-
  format('%# ~k ...',[RuleHead]),
   rule_head(RuleHead,Vrt,Rez,Depth,PredHead),!,
   once((
     rule_body(RuleHead,RuleBody,Vrt,Rez,Depth,PredBody)
     ;  
       format(atom(Exc),'transformeraro: ~w~n',[RuleHead]), 
       throw(Exc)
   )),
   RuleTranslated = (PredHead :- PredBody),
  format('bone!~n').
% format('  ~w~n',[RuleTranslated]).

% esceptoj: <- 
% rv_sen_fin(e,subst) <- post/e/ul.
% transformu al: rv_sen_fin(e,subst,posteul,'post/e/ul',_).
%? au alterantive: rv_sen_fin(e,subst,Vrt,Rez,_Depth) :- Vrt = posteul, Rez = post/e/ul.

term_expansion( RuleHead <- RuleBody , RuleTranslated ) :-
  format('%# ~k ...',[RuleHead]),
   reduce_full(RuleBody,Flat),
   RuleHead =..  [RuleName|RuleArgs],
   append(RuleArgs,[Flat,RuleBody,_Depth],Args),
   RuleTranslated =.. [RuleName|Args],
   format('bone!~n').
% format('  ~w~n',[RuleTranslated]).


rule_head(RuleHead,Vrt,Rez,Depth,PredHead) :-
   RuleHead =..  [RuleName|RuleArgs],
%   RuleArgs = [RuleScheme|_],
% format('# ~w(~w,_)~n',[RuleName,RuleScheme]),
   append(RuleArgs,[Vrt,Rez,Depth],Args),
   PredHead =.. [RuleName|Args].

rule_body(RuleHead,RuleExp ~> PostCond,Vrt,Rez,Depth,PredBody) :-
  rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,FirstPart),
  PredBody =.. [',',FirstPart,PostCond].

rule_body(RuleHead,RuleExp,Vrt,Rez,Depth,PredBody) :-
  rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredBody).


% transformu regulo-esprimon (rule expression) al Prologo
rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredExp) :-
  RuleHead =.. [_,RuleScheme|_],
  RuleExp =.. [Op|Refs],
  memberchk(Op,['+','/','~','-','*']),!,
  Refs = [R1,R2],
%%%%  Rezulto =.. [Op,Rez1,Rez2], 
  Rez =.. [Op,Rez1,Rez2], 

  % kreu la Prologo-kodon por la regul-aplikoj kaj
  % la vortdismeto (Splitter)
  rule_ref(R1,V1,Rez1,D1,RRef1),
  rule_ref(R2,Rest,Rez2,D1,RRef2),
  splitter(RuleScheme,R1,R2,Vrt,V1,Rest,Splitter),

  % se la regul-skemo trovita en la kapo
  % temas pri apliko de prefikso aŭ antaŭvorto,
  % komencu per maldekstra parto (ĉar tiu parto estas verŝajne pli mallonga)
  % En aliaj okazoj (sufiksoj, finaĵoj, komencu per destra parto.
  (memberchk(RuleScheme,['pD','pv','pr','pAP','A+P']) ->
    Sub = (RRef1,RRef2)
  ; Sub = (RRef2,RRef1)
  ),

  % kunmetu la kod-partojn al tuta predikato-korpo
  PredExp =  (
   debug(Depth,'?',RuleScheme,Vrt), 
%     atom_concat(V1,Rest,Vrt), 
%     V1 \= '', Rest \= '',
     Splitter,
     D1 is Depth +1,
%     RRef2,
%     RRef1,
     Sub,
%%%     Rez=Rezulto,
   debug(Depth,'*',RuleScheme,Rez) 
    ).
%  term_variables(PredExp, [A,B,C,D,E,F]).

rule_exp(_,RuleExp,Vrt,Rez,Depth,PredExp) :-
  rule_ref(RuleExp,Vrt,Rez,Depth,PredExp).

% la regulo-parto referencas alian regulon
rule_ref(&RuleRef,Vrt,Rez,Depth,RuleCall) :- !,
  RuleRef =.. [RuleName|RuleArgs],
  append([RuleArgs,[Vrt,Rez,Depth]],Args),
  RuleCall =.. [RuleName|Args].

% la regulo-parto estas serĉo en la vortaro, je prefiksoj, radikoj, sufiksoj, finaĵoj...
rule_ref(DictSearch,Vrt,Vrt,_,DictSearch) :-
  DictSearch =.. [_,Vrt|_].

splitter(RuleScheme,RuleRef1,RuleRef2,Vrt,V1,Rest,Splitter) :-
    % PLIBONIGU: iom malavantaĝe estas, ke RuleId - unua argumento en RuleRef
    % ofte estas "_" kaj do ne konata, oni povus rigardi chiujn eblecojn pri specifa regulo
    % sed ofte elvenas intervalo 2.. kiu ne multe diferencas de 1..99
    get_rule_min_max(RuleRef1,Min1,Max1),
    get_rule_min_max(RuleRef2,Min2,Max2),
    
%%%    get_rule_min_max(RuleScheme,MinR,MaxR),
%    !,
    once((	
      memberchk(RuleScheme,['pD','pv','pr','pAP','A+P']),
        % prefikso pli mallonga ol la resto...
        Splitter = (
   %%%       atom_length(Vrt,L),
   %%%       between(MinR,MaxR,L),

          % maldekstra parto de la vorto (aŭ vortparto)
          % havanta longecon L1, kiu estu inter Min1 kaj Max1
          between(Min1,Max1,L1),
          sub_atom(Vrt,0,L1,L2,V1),

          % dekstra parto de la vorto (aŭ vortparto)
          % havanta longecon L2 = (vortlongeco)-L1
          % kaj estu inter Min2 kaj Max2
          between(Min2,Max2,L2),
          sub_atom(Vrt,L1,L2,0,Rest)
        )
/***********
      ;
      RuleScheme == 'A+P',
        Sum1 is Min1 + Max1,
        Splitter = (
          % preferu pli longajn radikojn komence...
          between(Min1,Max1,X1),
          plus(X1,L1,Sum1),
          sub_atom(Vrt,0,L1,L2,V1),

          between(Min2,Max2,L2),
          sub_atom(Vrt,L1,L2,0,Rest)
        )
*********/
      ; % ordinare komencu de malantaue
       % sufiksoj kaj finaĵoj normale estas mallongaj...
       Splitter = (
   %%%     atom_length(Vrt,L),
   %%%     between(MinR,MaxR,L),

         between(Min2,Max2,L2),
         sub_atom(Vrt,L1,L2,0,Rest), 

         between(Min1,Max1,L1),
         sub_atom(Vrt,0,L1,L2,V1)
     )
  )).


get_rule_min_max(RuleId,Min,Max) :-
  atom(RuleId),
  (min_max_len(RuleId,Mn,Mx) -> 
     Min is max(1,min(Mn,99)),
     Max is min(Mx,99),
     debug(0,rmin,RuleId,Min),
     debug(0,rmax,RuleId,Max)
  ; 
     Min is 1, 
     Max is 99). 

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

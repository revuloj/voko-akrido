/* -*- Mode: Prolog -*- */
% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1120, xfx, user:(<-) ). % disigas regulo-kapon, de esceptesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo
%:- op( 500, yfx, user:(~) ). % signas disigindajn vortojn

:- dynamic min_max_len/3. %, gra_debug/1.
:- multifile '&'/1. %, gra_debug/1.
:- dynamic vorto_gra:vorto/5.

/**
   transformas la regulojn de la gramatiko (vorto_gra) al interpretebla Prologo-lingvo.
   Uziĝas term_expansion por tiu transformado.
*/

/*
gra_debug(false). % default

debug(Depth,Msg,Scheme,Rezulto) :-
  gra_debug(true)
  ->
    sub_atom('------------------------------------------------------------------------------------------',0,Depth,_,Indent),
    format('~w ~w ~w ~w~n',[Indent,Msg,Scheme,Rezulto])
  ; true.
*/

% vi povas ŝalti sencimigajn mesaĝojn per debug(gramatiko).
% kaj malŝalti per nodebug(gramatiko).
debug(Depth,Msg,Scheme,Rezulto) :-
  debugging(gramatiko) -> (
    sub_atom('------------------------------------------------------------------------------------------',0,Depth,_,Indent),
    debug(gramatiko,'~w ~q ~q ~q',[Indent,Msg,Scheme,Rezulto])
  ); true.

% sencimigi ekde certa linio en vorto_gra.pl 
debug_gra(Line) :-
  source_file(F),
  sub_atom(F,_,_,0,'vorto_gra.pl'),
  set_breakpoint(F,Line,0,_),
  debug.

% transformo de analiz-rezulto al HTML-strukturo

vform('/','·').
vform('*','×').
vform('+','+').
vform('-','-').
vform('~','~').

ofc_cls('*','o_f').
ofc_cls('+','o_n').
ofc_cls('','').
ofc_cls('!',evi).
ofc_cls(O,Cls) :- atom_concat('o_',O,Cls).

%ofc_sup('*','\u02d9'). %'⁰'). %'\u202f\u20f0'). %'⭑ᶠ⭑٭*').
ofc_sup('*','ᶠ'). 
ofc_sup('!','⁽⁻⁾').
ofc_sup('+','⁽⁺⁾').
ofc_sup(N,S) :- 
  atom_codes(N,C),
  n_sup(C,Cs),
  atom_codes(S,Cs).

n_sup(`3`,`³`).
n_sup(`4`,`⁴`).
n_sup(`5`,`⁵`).
n_sup(`6`,`⁶`).
n_sup(`2`,`²`).
n_sup(`7`,`⁷`).
n_sup(`8`,`⁸`).
n_sup(`1`,`¹`).
n_sup(`9`,`⁹`).
n_sup(`0`,`⁰`).
n_sup(`(`,`⁽`).
n_sup(`)`,`⁾`).
n_sup([_],`ₓ`).
% n_sup([X],_) :- format(atom(Msg),'Ne valida ofc: ~d!',[X]), throw(Msg).

n_sup([],[]).
n_sup([N|Rest],[Ns|Rs]) :- n_sup([N],[Ns]), n_sup(Rest,Rs).

% kunmetoj (-) kun almenaŭ tri partoj
ana_html_(A1-A2-A3,Html,Cls) :-
  % vin-ber estas tiel ofte, 
  % ke ni esceptas ĝin tie ĉi el la dubeblaj
  A1-A2 \= vin^_-ber^_,
  vform('-',S),
  ana_html_(A1,H1,Cls1),
  ana_html_(A2,H2,Cls2),
  ana_html_(A3,H3,Cls3),
  append([[dubebla],Cls1,Cls2,Cls3],Cls),
  append([H1,[S],H2,[S],H3],Html).

% duopoj kun meza operatoro (/,-,~,+,*)
ana_html_(Ana,Html,Cls) :-
  Ana =..[S1,A,B],
  vform(S1,S2),
  ana_html_(A,Ha,Cls1),
  ana_html_(B,Hb,Cls2),
  (S1='~' 
    -> append([[kuntirita],Cls1,Cls2],Cls)
    ;  append(Cls1,Cls2,Cls)
  ),
  append([Ha,[S2],Hb],Html).

% oficialeco
%ana_html_(A^O,[A,element(sup,[],[O])],[Cls]) :-
%  atomic(A),
%  atomic(O),
%  ofc_cls(O,Cls).

ana_html_(A^O,[A,Os],[Cls]) :-
  atomic(A),
  atomic(O),
  once((
    O='*', Os=element(sup,[],['⭑'])
    ;
    ofc_sup(O,Os)
  )),
  ofc_cls(O,Cls).


% vortelemento
ana_html_(A,[A],[]) :-
  atomic(A).

ana_txt_(Ana,Lst) :-
  Ana =..[ S1,A,B],
  vform(S1,S2),
  ana_txt_(A,Ha),
  ana_txt_(B,Hb),
  append([Ha,[S2],Hb],Lst).

% oficialeco
ana_txt_(A^O,[A,Os]) :-
  atomic(A),
  atomic(O),
  ofc_sup(O,Os).

% vortelemento
ana_txt_(A,[A]) :-
  atomic(A).

% punoj, por trovi plej bonan
% analizon inter pluraj
% ĉiu oficiala parto: 1p
% ĉiu neoficiala parto: 3p
% ĉiu kunmeto (-): 2p

op_pt('-',2).
op_pt('+',1).
op_pt('~',1).
op_pt('*',0).
op_pt('/',0).

%poentoj(A1-A2,Poentoj) :-
%  poentoj(A1,P1),
%  poentoj(A2,P2),!,
%  Poentoj is 2 + P1 + P2.


poentoj(Ana,Poentoj) :-
  Ana =..[S,A1,A2],
  op_pt(S,Po),
  %vform(S,_),
  poentoj(A1,P1),
  poentoj(A2,P2),!,
  Poentoj is P1+Po+P2.

poentoj(_^'+',3). % neoficialaj
poentoj(_^'!',3). % evitindaj
poentoj(_^_,1).
poentoj(_,1).

/*** ni bezonas ankoraŭ en term_expanson.... */
reduce_full(Term,Flat) :-
  format(codes(A),'~w',[Term]),
  reduce_(A,F,"/*+~-^() "),
  atom_codes(Flat,F).

reduce_([],[],_).

/**
% oficialeco: ^.. -> [..]
reduce_([0'^,0'(,Ofc,0')|Ls],[0'[,Ofc,0']|F],DelLetters) :- 
  memberchk(Ofc,[0'*,0'!,0'+]), !, 
  reduce_(Ls,F,DelLetters). % ^(*) -> [*]

reduce_([0'^|Ls],Reduced,DelLetters) :- !, 
  reduce_ofc(Ls,Ofc,Rest), % ^9 -> [9] ktp
  reduce_(Rest,R1,DelLetters),
  append(Ofc,R1,Reduced).
***/

% se la unua litero troviĝas en forigendaj (DelLetters), ellasu ĝin
reduce_([L|Ls],F,DelLetters) :-
  string_code(_,DelLetters,L),!, % memberchk(L,DelLetters),!, 
  reduce_(Ls,F,DelLetters).

/***
% tri strekoj al longa streko
reduce_([0'-,0'(,0'-,0'),0'-|Ls],[8212|F],DelLetters) :- !, % -(-)- -> —
  reduce_(Ls,F,DelLetters).

% tri oblikvoj al rekta streko
reduce_([0'/,0'(,0'/,0'),0'/|Ls],[124|F],DelLetters) :- !, % /(/)/ -> |
  reduce_(Ls,F,DelLetters).

% unu oblikvo al mezpunkto
reduce_([0'/|Ls],[183|F],DelLetters) :- !, % / -> middot (\u00b7)
  reduce_(Ls,F,DelLetters).
***/

% ĉiujn aliajn signojn konservu en la rezulto
reduce_([L|Ls],[L|Fs],DelLetters) :-
  % \+ memberchk(L,"() "), 
  reduce_(Ls,Fs,DelLetters).

/***
% ni legas ĉion ĝis '''' kiel oficialeco
reduce_ofc(Ls,[0'[|Ofc],Rest) :-
  reduce_ofc_(Ls,O,Rest),
  append(O,[0']],Ofc).

reduce_ofc_([L|Ls],[L|Ofc],Rest) :-
  string_code(_,"1234567890*!+",L),!, % fakte * ! + ne devus okazi tie ĉi, 
                    % ĉar anstataŭ inter (..) ili aperas citile (vd. supre)
  reduce_ofc_(Ls,Ofc,Rest). 

reduce_ofc_(Ls,[],Ls):-!.
%reduce_ofc_([],[],[]). % ne devus okazi, ke ) mankas entute!

reduce_ofc_(_,_,_) :- throw("Nevalida sintakso ĉe indiko de oficialeco!?").
***/

%%%%%% Traduki regulesprimojn al normalaj Prologo-faktoj....
%%
%% 1. la maldekstra parto (kapo) tradukiĝas per *rule_head* (vd. difniojn malsupre)
%%   kiu konsitiĝas tiel:
%% - predikatnomo, respondas al al predikatonomo de la gramatika regulo, ekz. 'vorto'
%% - regulnomo respondas al la unua argumento de la gramatika regulo, ekz. v, pv, Df
%%   [ĝi estas mallongigo de la aplikata vortformada maniero, ekz Df = D)erivaĵo kun f)inaĵo]
%% - Spc: la vortspeco deduktita el la regulo - respondanta al la dua argumento de la gramatika regulo
%% - Vrt: la analizenda vorto
%% - Rez: la rezulto de la analizo, kiel kombinita esprimo [komparebla al matematika termo kun operatoroj /, - kc]
%% - Depth: la profundeco de la analizo, ni limigas ĝin por ne perdiĝi en senfineco...
%%
%% 2. la dekstra parto (korpo) per *rule_body* (vd. difinojn malsupre)
%%   kiu konsistiĝas tiel:
%% a) simpla rigardo en la vortaro, ekz. v(Vorto,Speco) 
%% b) analizo kiel kunmeto el du partoj
%%    - unue la analizendea vorto estas arbitre dismetita en du partojn, por optimumigi la tuton
%%      depende de la vorter-speco ni limigas la longecon, ekz. ni scias ke prefikso havas inter 2 kaj 6 literojn.
%%    - analizo de ambaŭ partoj: aŭ kiel faktoj el la vortaro aŭ kiel pli profunde analizita vortparto
%%    - kontrolo de pliaj kondiĉoj (post "~>", ekz-e nur certaj vortspecoj)

% Ekzemploj de transformado de gramatika regulo al
% funkcianta Prologo-kodo:
%
% a) simpla vorteto, ekz. hodiaŭ, ek
%   vorto(v,Spc) <= v(_,Spc).
%
% fariĝas:
%   vorto_gra:vorto(v, Spc, V1, V1, _) :-
%     v(V1, Spc).
% 
% b) simplaj mal-vortoj (malfor, malantaŭ, maltro...)
%   vorto(pv,Spc) <= p(mal,_) / v(_,Spc) ~> (Spc='adv'; Spc='prep').
% 
% fariĝas:
%   vorto_gra:vorto(pv, Spc, Vrt, mal/V1, Depth) :-
%     % ... ni provas apliki la gramatikan regulon 'pv'
%     debug(Depth, ?, pv, Vrt),
%     % ni provas identigi la unuajn 2 ĝis 6 literojn per prefikso
%     between(2, 6, L1),
%     sub_atom(Vrt, 0, L1, L2, mal),
%     % ni provas identigi la sekvajn 2 ĝis 10 literojn per vorteto
%     between(2, 10, L2),
%     sub_atom(Vrt, L1, L2, 0, V1),
%     _ is Depth+1,
%     p(mal, _),
%     v(V1, Spc),
%     % ni kontrolas, ĉu la vortspeco estas unu el 'adv', 'prep'
%     debug(Depth, *, pv, mal/V1),
%     (   Spc=adv
%     ;   Spc=prep
%     ).

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

% esceptojn ni difinas per simpla sageto: <- 
%    rv_sen_fin(e,subst) <- post/e/ul.
%
% transformu al: rv_sen_fin(e,subst,posteul,post/e/ul,_).
%? au alternative: rv_sen_fin(e,subst,Vrt,Rez,_Depth) :- Vrt = posteul, Rez = post/e/ul.

term_expansion( RuleHead <- RuleBody , RuleTranslated ) :-
  % silentu pri escpetoj, tro multaj linioj: format('%# ~k ...',[RuleHead]),
  reduce_full(RuleBody,Flat),
  RuleHead =..  [RuleName|RuleArgs],
  append(RuleArgs,[Flat,RuleBody,_Depth],Args),
  RuleTranslated =.. [RuleName|Args].
  % silentu pri escpetoj, tro multaj linioj: format('bone!~n').
  % format('  ~w~n',[RuleTranslated]).


rule_head(RuleHead,Vrt,Rez,Depth,PredHead) :-
   RuleHead =..  [RuleName|RuleArgs],
%   RuleArgs = [RuleScheme|_],
% format('# ~w(~w,_)~n',[RuleName,RuleScheme]),
   append(RuleArgs,[Vrt,Rez,Depth],Args),
   PredHead =.. [RuleName|Args].


rule_body(RuleHead,RuleExp ~> PostCond,Vrt,Rez,Depth,PredBody) :-
  % kreo de la unua parto
  rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,FirstPart),
  % alpendigo de la postkondiĉo, kiu ja estas valida Prologo-kodo per "KAJ" = ","
  % post la unua parto
  PredBody =.. [',',FirstPart,PostCond].

rule_body(RuleHead,RuleExp,Vrt,Rez,Depth,PredBody) :-
  % se ni ne havas postkondiĉon sufiĉas krei la "unuan parton"
  rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredBody).


% transformu regulo-esprimon (rule expression) al Prologo
rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredExp) :-
  RuleHead =.. [_,RuleScheme|_],
  % ĉu la regulesprimo (dekstra parto) enhavas unu el la permesataj operatoroj,
  % ekz. R1 / R2
  RuleExp =.. [Op|Refs],
  memberchk(Op,['+','/','~','-','*']),!,
  Refs = [R1,R2],
%%%%  Rezulto =.. [Op,Rez1,Rez2], 
  Rez =.. [Op,Rez1,Rez2], 

  % kreu la Prologo-kodon por la regul-aplikoj kaj
  % la vortdismeto (Splitter)
  % R1 kaj R2 referencas al la nomoj de gramatikaj reguloj
  % kiuj povas esti aŭ vortarserĉo aŭ gramatika regulo (komenciĝanta per "&")
  % la lasta argumento redonas la kunmetitan kodon por vokado de tiu regulo (aŭ serĉo)
  rule_ref(R1,V1,Rez1,D1,RRef1),
  rule_ref(R2,Rest,Rez2,D1,RRef2),
  splitter(RuleScheme,R1,R2,Vrt,V1,Rest,Splitter),

  % por optimuma analizo: se la regul-skemo trovita en la kapo
  % temas pri apliko de prefikso aŭ antaŭvorto,
  % komencu per maldekstra parto (ĉar tiu parto estas verŝajne pli mallonga)
  % En aliaj okazoj (sufiksoj, finaĵoj, komencu per destra parto.

  (memberchk(RuleScheme,['pD','vD','pv','pr','pAP','A+P']) ->
    Sub = (RRef1,RRef2)
  ; Sub = (RRef2,RRef1)
  ),

  % kunmetu nun la kod-partojn al tuta predikato-korpo
  PredExp =  (
    debug(Depth,'?',RuleScheme,Vrt), 
    Splitter,
    D1 is Depth +1,
    Sub,
    debug(Depth,'*',RuleScheme,Rez) 
  ).

% la dekstra parto povas ankaŭ esti unuparta, simpla, ekz. vortarserĉo
% aŭ forreferenco al subordigita regulo
rule_exp(RuleHead,RuleExp,Vrt,Rez,Depth,PredExp) :-
  rule_ref(RuleExp,Vrt,Rez,Depth,PredSmp),
  RuleHead =.. [_,RuleScheme|_],
  PredExp =  (
    debug(Depth,'?',RuleScheme,Vrt), 
    PredSmp,
    debug(Depth,'*',RuleScheme,Rez)
  ).


% komenciĝante per "&", la regulo-parto referencas alian regulon
rule_ref(&RuleRef,Vrt,Rez,Depth,RuleCall) :- !,
  RuleRef =.. [RuleName|RuleArgs],
  append([RuleArgs,[Vrt,Rez,Depth]],Args),
  RuleCall =.. [RuleName|Args].

% la regulo-parto estas serĉo en la vortaro, je prefiksoj, radikoj, sufiksoj, finaĵoj...
% DictSearch estas ekz-e v(Vrt,Spec,Ofc) - por vortoj kaj radikoj ni havas oficialecon
rule_ref(DictSearch,Vrt,Vrt^Ofc,_,DictSearch) :-
  DictSearch =.. [Srch,Vrt,_Spc,Ofc],
  memberchk(Srch,[v,r,nr,nr_,nk]),!.

% nommkomenco, t.e. mallongigita nomo kiel en Pe(tr)ĉjo
%rule_ref(DictSearch,Vrt,Vrt:Rest^Ofc,_,DictSearch) :-
%  DictSearch =.. [nk,Vrt,_Spc,Rest,Ofc],!.

% DictSearch estas alispeca vortero (sen oficialeco)
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
      memberchk(RuleScheme,['pD','vD','pv','pr','pAP','A+P']),
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

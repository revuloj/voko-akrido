
/******************** malstrikta vortanalizo ******
 * analizas vorton sen konsideri
 * striktajn derivadregulojn law la funkcioj
 * derivado_per_*. Do afiksoj povas aplikigxi
 * tie cxi al cxiaj vortspecoj.
****************************************************/

radika_vorto_sen_fino(Partoj) --> prefiksoj(Prefiksoj), radiko(Radiko), sufiksoj(Sufiksoj),
  { append([Prefiksoj,[Radiko],Sufiksoj],Partoj) }.

radika_vorto(Partoj) -->
  radika_vorto_sen_fino(RvsfPartoj),
  finajxo(Fino),
  { append(RvsfPartoj,Fino,Partoj) }.

prefiksoj([]) --> [].
prefiksoj([p(Prefikso,DeSpeco)|Prefiksoj]) -->
  p(Prefikso,DeSpeco),
  prefiksoj(Prefiksoj).
prefiksoj([p(Prefikso,AlSpeco,DeSpeco)|Prefiksoj]) -->
  p(Prefikso,AlSpeco,DeSpeco),
  prefiksoj(Prefiksoj).

radiko(r(Radiko,Speco)) -->
  r(Radiko,Speco).  

sufiksoj([]) --> [].
sufiksoj([s(Sufikso,AlSpeco,DeSpeco)|Sufiksoj]) -->
  s(Sufikso,AlSpeco,DeSpeco),
  sufiksoj(Sufiksoj).

finajxo([f(Fino,FSpeco)]) -->               
  f(Fino,FSpeco).

pronomo_sen_fino([u(Pronomo,Speco)]) -->
  u(Pronomo,Speco).

pronomo_sen_fino([i(Pronomo,Speco)]) -->
  i(Pronomo,Speco).

simpla_vorto([v(Vorto,Speco)]) -->
  v(Vorto,Speco).

simpla_vorto(Pronomo) --> 
  pronomo_sen_fino(Pronomo).

simpla_vorto([u(Pronomo,Speco),fu(Fino,FSpeco)]) -->
  u(Pronomo,Speco),        
  fu(Fino,FSpeco).

simpla_vorto([i(Pronomo,Speco)]) -->
  i(Pronomo,Speco).
  
simpla_vorto([i(Pronomo,Speco),fi(Fino,FSpeco)]) -->
  i(Pronomo,Speco),
  fi(Fino,FSpeco).

% mal+prep, mal+adv
simpla_vorto([p(mal,_),v(Vorto,VSpeco)]) -->
  "mal", v(Vorto,VSpeco),
  {
    (VSpeco='adv'; VSpeco='prep')
  }.

kunmetita_vorto(Partoj) -->
  antau_partoj(APartoj),
  post_parto(PParto),
  { APartoj \= [], append(APartoj,[PParto],Partoj) }.

antau_partoj([]) --> [].
antau_partoj([P1|P2]) -->
  antau_parto(P1),
  antau_partoj(P2).

antau_parto(Partoj) -->
  pronomo_sen_fino(Partoj).

antau_parto(Partoj) -->
  radika_vorto_sen_fino(Partoj).

% kun interfino (a,o)
antau_parto(Partoj) -->
  radika_vorto_sen_fino(P),
  c(InterFino,Speco),
  { append(P,[c(InterFino,Speco)],Partoj) }.

post_parto(Partoj) --> radika_vorto(Partoj).

%%%%%%%%%%%%%%%%%%%%%%

% aplikado der derivadreguloj...

/*******  hierarkieto  de vortspecoj ****************/

sub(X,X).
% sub(X,Z) :- sub(X,Y), sub(Y,Z).
sub(best,subst).
sub(parc,best).
sub(parc,subst).
sub(ntr,verb).
sub(tr,verb).
sub(perspron,pron).

subspc(S1,S2) :-
  sub(S1,S2),!.

/********
drv_per_prefikso(p(Pre,Spc),X), p/2+v, p/2+rvsf
drv_per_finajxo(X,f(Fin,Spc), rvsf+f, rvsf+c
drv_per_sufikso(X,s()), rvsf+s
kunigi: i+fi, u+fu
kunderivado: p/3+rvsf
kunmetado "-"

kunmeto() --> antauvortoj, postvorto.
antauvortoj --> [].
antauvortoj --> antauvorto, antauvortoj.
antauvorto --> rvsf; rvc; psf.
postvorto --> vorto.

rvsf --> ...?
rvc --> rvsf + c.

vorto --> kunigo(i,fi); kunigo(u,fu).
vorto -> kunderivajxo(p/3+rvsf)+f
***********/

kunigo(V,Ps) -->
  [i(P,Ps)], [fi(F,_)],
  { atomic_list_concat([P,F],'/',V) }.

kunigo(V,Ps) -->
  [u(P,Ps)], [fu(F,_)],
  { atomic_list_concat([P,F],'/',V) }.

% radika vorto sen finajxo kaj sufiksoj (sed kun prefiksoj)
radv_sen_suf(V,S) --> [r(V,S)].
radv_sen_suf(V,S) --> 
  [p(Pref,De)], radv_sen_suf(Rvss,S),
  { subspc(S,De), % !, 
    atomic_list_concat([Pref,Rvss],'/',V) }.


drv_per_suf(Spc,Al,De,Speco) :- 
  subspc(Spc,De), %!,
  	% Se temas pri sufikso kun nedifinita DeSpeco, 
	% ekz. s(acx,_,_) aw s(ist,best,_) la afero funkcias tiel:
	% sub(X,X) identigas DeSpeco kun Speco
	% Se AlSpeco ankau ne estas difinita ghi estu
	% la sama kiel Speco, tion certigas la sekva
	% identigo, se AlSpeco estas difinita kaj alia
	% ol Speco la rezulta vorto estu de AlSpeco

	% Se nur AlSpeco ne estas difinita, ekz s(in,_,best)
	% la sekva identigo donas la rezultan Specon, tiel
	% frat'in estas "parc" kaj ne nur "best".

	(Spc=Al,!, % se temas pri sufiksoj kiel s(acx,_,_),
                   % fakte suficxus ekzameni, cxu AlSpeco = _
          Speco=Spc;
	  Speco=Al 
        ).


% radika vorto sen finajxo (sed kun afiksoj)
radv_sen_fin(V,S,N) --> { N>=0 }, radv_sen_suf(V,S).
% KOREKTU: ne funkcias che pli ol unu sufikso, tial: "!" 
radv_sen_fin(V,S,N) --> { N>0, N_1 is N-1 }, % evitu senfinan ciklon
  radv_sen_fin(Rvsf,Spc,N_1),
  [s(Suf,Al,De)],
  { drv_per_suf(Spc,Al,De,S),
%format('spc ~w~n',S),
    atomic_list_concat([Rvsf,Suf],'/',V)
  }.

kunderiv(V,Al) --> 
  [p(Pre,Al,De)], radv_sen_fin(Vsf,VSpc,3), % apliku maks. 3 sufiksojn, ĉu sufiĉas?
  { subspc(VSpc,De), %!, 
    atomic_list_concat([Pre,Vsf],'+',V) }.

vrt_sen_fin(V,S) --> kunderiv(V,S).
vrt_sen_fin(V,S) --> radv_sen_fin(V,S,3). % apliku maks. 3 sufiksojn, ĉu sufiĉas?

vorto(V,S) --> [v(V,S)]; [u(V,S)]; [i(V,S)].
vorto(V,S) --> kunigo(V,S).
vorto(V,S) --> 
  vrt_sen_fin(Vsf,Vs), [f(F,Fs)], 
  { (subspc(Vs,Fs), 
       S=Vs %,!
     ; S=Fs), 
    atomic_list_concat([Vsf,F],'/',V) }.

vorto(V,S) --> 
  [p(mal,_)], [v(Vrt,S)],
  {
    (S='adv'; S='prep'),
    atomic_list_concat([mal,Vrt],'/',V) 
  }.

% kunmetita vorto...

vorto(V,S) --> antauvortoj(A), postvorto(P,S),
 { atomic_list_concat([A,P],'-',V) }.

antauvortoj('') --> [].
antauvortoj(A) --> antauvorto(Av), antauvortoj(Avj),
  { Avj \= '' -> atomic_list_concat([Av,Avj],'-',A); A= Av }.

antauvorto(A) --> [Rsf],
  { phrase(radv_sen_fin(A,_,3),Rsf) }.  % apliku maks. 3 sufiksojn, ĉu sufiĉas?
antauvorto(A) --> [Rsf],
  { phrase((radv_sen_fin(Vsf,_,3),  % apliku maks. 3 sufiksojn, ĉu sufiĉas?
           [c(F,_)]),Rsf),
    atomic_list_concat([Vsf,F],'/',A) }.
antauvorto(A) --> [[v(A,_)]]; [[u(A,_)]]; [[i(A,_)]].

postvorto(P,S) --> [V],
  { phrase(vorto(P,S),V) }.

%%%%%%%%%%%%%%%%%%%%%%
  
vortpartoj(Vorto,Partoj) :-
  phrase(simpla_vorto(Partoj),Vorto).

vortpartoj(Vorto,Partoj) :-
  phrase(radika_vorto(Partoj),Vorto).

vortpartoj(Vorto,Partoj) :-
  phrase(kunmetita_vorto(Partoj),Vorto).

vortanalizo(Vorto,Analizita,Speco) :-
  vortpartoj(Vorto,Partoj),
  (
    phrase(vorto(Analizita,Speco),Partoj)%;
    %phrase(kunmetita_vorto(Analizita,Speco),Partoj)
  ).



spc_fin_(Spc,Fin) :-
 (
    sub(Spc,subst), Fin=f(o,subst);
    sub(Spc,adj), Fin=f(a,adj),!;
    sub(Spc,verb), Fin=f(i,vrb);
    sub(Spc,adv), Fin=f(e,adv)
  ).

derivajho(Radiko,Derivajho,Speco) :-
  atom_codes(Radiko,RadCodes),
  phrase(r(Rad,Spc),RadCodes),
  phrase(s(Suf,AlSpc,DeSpc),_),
  spc_fin_(AlSpc,Fin),
  %member(Fin,[f(o,subst),f(a,adj),f(i,verb),f(e,adv)]),
  %member(Fin,[f(o,subst)]),
  phrase(vorto(Derivajho,Speco),[r(Rad,Spc),s(Suf,AlSpc,DeSpc),Fin]).

derivajho(Radiko,Derivajho,Speco) :-
  atom_codes(Radiko,RadCodes),
  phrase(r(Rad,Spc),RadCodes),
  phrase(p(Pref,AlSpc),_),
  spc_fin_(AlSpc,Fin),
  %member(Fin,[f(o,subst),f(a,adj),f(i,verb),f(e,adv)]),
  %member(Fin,[f(o,subst)]),
  phrase(vorto(Derivajho,Speco),[p(Pref,AlSpc),r(Rad,Spc),Fin]).
%test: derivajho(abel,D,_), writeln(D),fail.

derivajhoj(Radiko,Derivajhoj) :-
  setof(D,Spc^derivajho(Radiko,D,Spc),Derivajhoj).

testo(Vorto) :-
  vortpartoj(Vorto,Partoj),
  maplist(writeln,Partoj).

% ekz. grandegul
testo_suf(Vorto,N) :-
  phrase(radika_vorto_sen_fino(Partoj),Vorto),
  phrase(radv_sen_fin(V,S,N),Partoj),
  format('~w ~w~n',[V,S]).

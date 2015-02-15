
/******************** strikta vortanalizo ******
% aplikado der derivadreguloj...
***********************************************/

/******
TODO - KOREKTENDAJ:

ne estu permesata:
    'art-i-kol/o',

verbigo de substantivoj estu iel permesata:
  planado, muzikado, spicado, kau'zanta, kau'zata (nur por transitivaj)
***/

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

vorto --> pron_kunigo(i,fi); pron_kunigo(u,fu).
vorto -> kunderivajxo(p/3+rvsf)+f
***********/

pron_kunigo(V,Ps) -->          % pron + fin ekz. "min"
  [i(P,Ps)], [fi(F,_)],
  { atomic_list_concat([P,F],'/',V) }.

pron_kunigo(V,Ps) -->          % pron + fin, ekz. "kiujn"
  [u(P,Ps)], [fu(F,_)],
  { atomic_list_concat([P,F],'/',V) }.

nombr_kunigo(N,nombr) -->          % dudek -> du*dek
  [v(N1,nombr)], [v(N2,nombr)],
  { atomic_list_concat([N1,N2],'/',N) }.

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
radv_sen_fin(V,S,N) --> { N>=0 }, 
  radv_sen_suf(V,S).


radv_sen_fin(V,S,N) --> 
  { N>0, N_1 is N-1 }, % evitu senfinan ciklon
  radv_sen_fin(Rvsf,Spc,N_1),
  [s(Suf,Al,De)],
  { drv_per_suf(Spc,Al,De,S),
%format('spc ~w~n',S),
    atomic_list_concat([Rvsf,Suf],'/',V)
  }.

% foje funkcias apliki prefiksojn nur post sufiksoj, ekz. ne/(venk/ebl)
radv_sen_fin(V,S,N) -->
  [p(Pref,De)], 
  radv_sen_fin(Rvsf,S,N),
  { subspc(S,De), % !, 
    atomic_list_concat([Pref,Rvsf],'/',V) }.

kunderiv(V,Al) --> 
  [p(Pre,Al,De)], % kunderivado per prepozicioj (ekz. sur+strat/a)
  radv_sen_fin(Vsf,VSpc,3), % apliku maks. 3 sufiksojn, ĉu sufiĉas?
  { subspc(VSpc,De), %!, 
    atomic_list_concat([Pre,Vsf],'+',V) }.

kunderiv(V,adj) --> % altkreska, longdaura, plenkreska
  ([r(Adv,adv)];[r(Adv,adj)]),
  [r(Verb,VSpc)], 
  { subspc(VSpc,verb), atomic_list_concat([Adv,Verb],'+',V) }.

kunderiv(V,adj) --> % multlingva
  [r(Adj,adj)],
  [r(Subst,SSpc)],
  { subspc(SSpc,subst), atomic_list_concat([Adj,Subst],'+',V) }.

vrt_sen_fin(V,S) --> kunderiv(V,S).
vrt_sen_fin(V,S) --> radv_sen_fin(V,S,3). % apliku maks. 3 sufiksojn, ĉu sufiĉas?

% foje funkcias apliki sufiksojn nur post kunderivado, ekz. (sen+pied)/ul
vrt_sen_fin(V,S) -->
  kunderiv(KDrv,Spc),
  [s(Suf,Al,De)],
  { drv_per_suf(Spc,Al,De,S),
%format('spc ~w~n',S),
    atomic_list_concat([KDrv,Suf],'/',V)
  }.

vorto(V,S) --> [v(V,S)]; [u(V,S)]; [i(V,S)]. % vorteto aŭ pronomo
vorto(V,S) --> pron_kunigo(V,S).                  % pronomo kun finaĵo
vorto(V,S) --> nombr_kunigo(V,S).
vorto(V,S) --> 
  vrt_sen_fin(Vsf,Vs), [f(F,Fs)],  % senfinaĵa vorto + finaĵo
  { (subspc(Vs,Fs),                % derivado per finaĵo
       S=Vs %,!
     ; S=Fs), 
    atomic_list_concat([Vsf,F],'/',V) }.

vorto(V,S) --> 
  [p(mal,_)], [v(Vrt,S)],          % simplaj mal-vortoj (malfor, malantaŭ, maltro...)
  {
    (S='adv'; S='prep'),
    atomic_list_concat([mal,Vrt],'/',V) 
  }.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% kunmetita vorto...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vorto(V,S) --> antauvortoj(A), postvorto(P,S),
 { atomic_list_concat([A,P],'-',V) }.

% foje funkcias apliki prefiksojn nur al jam kunmetita vorto, ekz. ne/(progres-pov/a)
vorto(V,S) -->
  %%%pref_kunm(Pref,De), 
  [[p(Pref,De)]], 
  antauvortoj(A), 
  postvorto(P,S),
  { subspc(S,De), % !, 
    atomic_list_concat([A,P],'-',K),
    atomic_list_concat([Pref,K],'/',V) }.

antauvortoj('') --> [].
antauvortoj(A) --> antauvorto(Av), antauvortoj(Avj),
  { Avj \= '' -> atomic_list_concat([Av,Avj],'-',A); A= Av }.

antauvorto(A) --> [Rsf],
  { phrase(radv_sen_fin(A,_,3),Rsf) }.  % apliku maks. 3 sufiksojn, ĉu sufiĉas?
antauvorto(A) --> [Rsf],
  { phrase((radv_sen_fin(Vsf,_,3),  % apliku maks. 3 sufiksojn, ĉu sufiĉas?
           [c(F,_)]),Rsf),
    atomic_list_concat([Vsf,F],'/',A) }.

% eble iom dubinda ("mi-dir/i" , "ĉiu-hom/o" kompare kund kunderivado "ambaŭ+pied/e", "ĉiu+jar/a"
antauvorto(A) --> [[v(A,_)]]; [[u(A,_)]]; [[i(A,_)]].

postvorto(P,S) --> [V],
  { phrase(vorto(P,S),V) }.




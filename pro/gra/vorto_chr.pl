/* -*- Mode: Prolog -*- */
:- use_module( library(chr)).
/*
r(san,adj).
s(ec,adj,subst).
f(o,subst).    
*/

:- chr_constraint last/1, v/4, r/4, nk/4,
   i/4, u/4, p/4, p/5, s/5, sn/5, f/4, fi/4, fu/4,
   os/3, nr/4, nr_/4, ns/4, 
   rad/4, rv_sen_suf/4, rv_sen_fin/4, nm_sen_fin/4, vorto/4.


%! sub(?Subspeco:atom,?Speco:atom) is nondet.
%
% Malgranda hierakieto de vortspecoj: sub(best,subst), sub(tr,verb) k.a.

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

%! nk(?Nomo:atom,?Speco:atom) is nondet.
%
% formi nomkomencon el radikoj, por apliki nj, ĉj, ekz. paĉj': r(patr,pers) -> nk(pa,pers) 

nk(Nom,Spc) :- 
    sub(Spc,pers),
    (vortaro:r(Nomo,Spc); vortaro:nr(Nomo,Spc)),
    sub_atom('aeioujŭrlnm',_,1,_,Lit),
    sub_atom(Nomo,B,1,_,Lit),
    B_1 is B+1,
    sub_atom(Nomo,0,B_1,_,Nom).


drv_per_suf(Spc,Al,De,Speco) :- 
  subspc(Spc,De), %!,
        % Se temas pri sufikso kun nedifinita DeSpeco, 
        % ekz. s(aĉ,_,_) aŭ s(ist,best,_) la afero funkcias tiel:
        % sub(X,X) identigas DeSpeco kun Speco
        % Se AlSpeco ankaŭ ne estas difinita ĝi estu
        % la sama kiel Speco, tion certigas la sekva
        % identigo, se AlSpeco estas difinita kaj alia
        % ol Speco la rezulta vorto estu de AlSpeco

        % Se nur AlSpeco ne estas difinita, ekz s(in,_,best)
        % la sekva identigo donas la rezultan Specon, tiel
        % frat'in estas "parc" kaj ne nur "best".

        (Spc=Al, !, % se temas pri sufiksoj kiel s(aĉ,_,_),
                   % fakte suficxus ekzameni, cxu AlSpeco = _
          Speco=Spc;
          Speco=Al 
        ).



% simpla vorteto, ekz.  hodiaŭ, ek
v @ v(0,last,V,Spc) <=> vorto(0,last,V,Spc).

% simplaj mal-vortoj (malfor, malantaŭ, maltro...)
pv @ p(0,1,mal,_), v(1,last,V,Spc) <=> (Spc='adv'; Spc='prep') | vorto(0,last,mal/V,Spc).

% pron + fin, ekz. mi/n
ifi @ i(0,1,Pron,Spc), fi(1,last,Fin,_) <=> vorto(0,last,Pron/Fin,Spc).

% pronomo, ekz. mi
i @ i(0,last,Pron,Spc) <=> vorto(0,last,Pron,Spc). 

% pron + fin, ekz. kiu/jn
ufu @ u(0,1,Pron,Spc), fu(1,last,Fin,_) <=> vorto(0,last,Pron/Fin,Spc).

% pronomo, ekz. kiu
u @ u(0,last,Pron,Spc) <=> vorto(0,last,Pron,Spc).

% radika (derivita) vorto + finaĵo
'Df' @ rv_sen_fin(0,N1,Rvsf,VSpc), f(N1,last,Fin,FSpc) <=> subspc(VSpc,FSpc) |
				    (Spc=VSpc ; Spc=FSpc), vorto(0,last,Rvsf/Fin,Spc).



% derivaĵo per nomo, ekz "Atlantiko"
% PLIBONIGU: distingu o(jn)-finaĵon (majuskle) kaj aliajn (minuskle)
% ankoraŭ mankas ebleco analizi majusklajn naciojn franc/ -> Franc/uj

'Mf' @ nm_sen_fin(0,N1,Nsf,VSpc), f(N1,last,Fin,FSpc) <=> subspc(VSpc,FSpc) |  
				   (Spc=VSpc ; Spc=FSpc), vorto(0,last,Nsf/Fin,Spc).

% radikoj...
% ne traktu afiksojn kiel radikoj
% por teĥnikaj prefiksoj kiel nitro-, kilo- k.a. difinu
% apartajn regulojn por "prefikso" kaj "sufikso"
r @ r(N0,N1,Rad,Spc) <=> Spc \= suf, Spc \= pref | rad(N0,N1,Rad,Spc).

% substantivigo de verboj, kiel celi -> celo (ekz. por formi "tiu+cel/a")
r_ @ r(N0,N1,Rad,VSpc) <=> subspc(VSpc,verb) | rad(N0,N1,Rad,subst).

% verbigo de substantivoj, ekz. kauzo -> kauzi, spico -> spici
% sed foje kaŭzas malĝustan analizon:
% strat/i -> sur/strat/a anstataŭ sur+strat/a
r_ @ r(N0,N1,Rad,SSpc) <=> subspc(SSpc,subst) | rad(N0,N1,Rad,tr).

% substantivigo de nombroj: tri -> trio
r_ @ r(N0,N1,Rad,nombr) <=> rad(N0,N1,Rad,subst).

% adjektivigo de adverboj: bele -> bela -> belulo, ( super -> super/a -> superulo ?)
r_ @ r(N0,N1,Rad,adv) <=> rad(N0,N1,Rad,adj).

% verbigo de adjektivoj: simili, ĵaluzi, utili, trankvili ktp.
r_ @ r(N0,N1,Rad,adj) <=> rad(N0,N1,Rad,verb).

% permesu oblikvon '/' post la radiko, speciale por la kapvortoj de Revo
'r/' @ r(N0,N1,Rad,Spc), os(N1,N2,Obl) <=>  Spc \= suf, Spc \= pref | rad(N0,N2,Rad/Obl,Spc).

% minusklaj nomradikoj uziĝas kiel ordinaraj
% radikoj, ekz. trans+antlantik, pra/franc/a
m @ nr_(N0,N1,Nr,Spc) <=> rad(N0,N1,Nr,Spc).
'm/' @ nr_(N0,N1,Nr,Spc), os(N1,N2,Obl) <=> rad(N0,N2,Nr/Obl,Spc).

% derivado per prefikso
pr @ p(N0,N1,Pref,De), rad(N1,N2,Rad,Spc) <=> subspc(Spc,De) | rv_sen_suf(N0,N2,Pref/Rad,Spc).
pD @ p(N0,N1,Pref,De), rv_sen_suf(N1,N2,Rvss,Spc) <=> subspc(Spc,De) | rv_sen_suf(N0,N2,Pref/Rvss,Spc). 

% derivado per prepozicioj uzataj prefikse ĉe verboj
pr @ p(N0,N1,Pref,Al,De), rad(N1,N2,Rad,Spc) <=> subspc(Spc,De), subspc(De,verb) |
		rv_sen_suf(N0,N2,Pref/Rad,Al). %, subspc(Al,verb).
pD @ p(N0,N1,Pref,Al,De), rv_sen_suf(N1,N2,Rvss,Spc) <=> subspc(Spc,De), subspc(De,verb) |
		rv_sen_suf(N0,N2,Pref/Rvss,Al). %, subspc(Al,verb).

r @ rad(N0,N1,Rad,Spc) <=> rv_sen_fin(N0,N1,Rad,Spc).
% radika vorto sen finaĵo (sed kun afiksoj)
'D' @ rv_sen_suf(N0,N1,Rvss,Spc) <=> rv_sen_fin(N0,N1,Rvss,Spc).

% rad+sufikso, ekz. san/ul
'Ds' @ rv_sen_fin(N0,N1,Rvsf,Vs), s(N1,N2,Suf,Al,De) <=> drv_per_suf(Vs,Al,De,Spc) |
				   rv_sen_fin(N0,N2,Rvsf/Suf,Spc).

'Ds' @ rv_sen_fin(N0,N1,Rvsf,nombr), sn(N1,N2,Nsuf,nombr,nombr) <=> rv_sen_fin(N0,N2,Rvsf/Nsuf,nombr).

% foje funkcias apliki prefiksojn nur post sufiksoj, 
% ekz. ne/(venk/ebl), eks/(lern/ej/an)/oj !!! 'Ds' -> pD
pD @ p(N0,N1,Pref,De), rv_sen_fin(N1,N2,Rvsf,Spc) #'Ds' <=> subspc(Spc,De) |
				rv_sen_fin(N0,N2,Pref/Rvsf,Spc).

% karesnomo
'N' @ nk(N0,N1,Kares,Spc), ns(N1,N2,Nsuf,Ss) <=> subspc(Spc,Ss) | rv_sen_fin(N0,N2,Kares/Nsuf,Spc).

% majusklaj nomoj povas havi nur sufiksojn, ekz. Atlantik/ec, Rus/uj
'M' @ nr(N0,N1,Nom,Spc) <=> nm_sen_fin(N0,N1,Nom,Spc).
'Ms' @ nm_sen_fin(N0,N1,Nsf,Ns), s(N1,N2,Suf,Al,De) <=> drv_per_suf(Ns,Al,De,Spc) |
				  nm_sen_fin(N0,N2,Nsf/Suf,Spc).



%r(N0,N1,Rad,Spc), s(N1,N2,Suf,Spc,Spc1) <=> vsf(N0,N2,Rad/Suf,Spc1).
%vsf(N0,N1,V,_), f(N1,N2,F,Spc) <=> vorto(N0,N2,V/F,Spc).    
    

/**    
?- r(san,adj),s(ec,adj,subst),f(o,subst).
vorto(san/ec/o, subst).
    
?- r(0,1,san,adj),s(1,2,ec,adj,subst),f(2,3,o,subst).

    i(0,1,mi,pron),fi(1,last,n,_).
    
% eks/(lern/ej/an)/oj

p(0,1,eks,subst),r(1,2,lern,tr),s(2,3,ej,subst,verb),f(3,last,o,subst).

    **/


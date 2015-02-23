:- ensure_loaded(gramatiko).
:- discontiguous vorto/2, vorto/3.
:- dynamic min_max_len/3.

% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo

%gra_debug(true).

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

% oni povus pli flekseble tion kalkuli rikure
% el la reguloj mem...
min_max_len(v,2,10).
min_max_len(pv,5,13).
min_max_len(i,2,5).
min_max_len(u,2,5).
min_max_len(ifi,3,6).
min_max_len(ufu,3,7).
min_max_len(r,2,18).
min_max_len(f,1,3).
min_max_len('Df',3,99).
min_max_len(p,2,7).
min_max_len(s,2,4).
min_max_len(pr,4,25).
min_max_len('Ds',4,99).
min_max_len(pD,4,99).
min_max_len('Kf',7,99).
min_max_len('Vf',7,99).
min_max_len('Ks',6,99).
min_max_len(pD,4,99).
min_max_len(rr,4,99).
min_max_len(nn,5,8).
min_max_len('A',2,33).
min_max_len('A+',2,99).
min_max_len('P',3,99).
min_max_len(c,1,1).
min_max_len('Df',3,33).
min_max_len('D',2,33).
min_max_len('AP',5,99).
min_max_len('A+P',5,99).
min_max_len(pAP,7,99).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% simplaj, nekunmetitaj vortoj 
%%% - nur derivado per afiksoj kaj finaĵoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% simpla vorteto, ekz.  hodiaŭ, ek
vorto(v,Spc) <= v(_V,Spc).

% simplaj mal-vortoj (malfor, malantaŭ, maltro...)
vorto(pv,Spc) <= p(mal,_) / v(_V,Spc) :- (Spc='adv'; Spc='prep').

% pronomo, ekz. mi
vorto(i,Spc) <= i(_Pron,Spc). 

% pronomo, ekz. kiu
vorto(u,Spc) <= u(_Pron,Spc). 

% pron + fin, ekz. mi/n
vorto(ifi,Spc) <= i(_Pron,Spc) / fi(_Fin,_).

% pron + fin, ekz. kiu/jn
vorto(ufu,Spc) <= u(_Pron,Spc) / fu(_Fin,_).

vorto('Df',Spc) <= &rv_sen_fin(_,Vs) / f(_Fin,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

/***
verbigo de substantivoj estu iel permesata, ĉu en la gramatiko aŭ per la vortaro:
  planado, muzikado, spicado, kau'zanta, kau'zata (nur por transitivaj)
***/


% derivado per prefikso
rv_sen_suf(pr,Spc) <= p(_Pref,De) / r(_Rad,Spc) ~> subspc(Spc,De).

% radika vorto sen finaĵo (sed kun afiksoj)
rv_sen_fin(r,Spc) <= r(_Rad,Spc). 
%%rv_sen_fin(Spc) <= &rv_sen_suf(Spc).

% rad+sufikso, ekz. san/ul
rv_sen_fin('Ds',Spc) <= &rv_sen_fin(_,Vs) / s(_Suf,Al,De) ~> drv_per_suf(Vs,Al,De,Spc).

% foje funkcias apliki prefiksojn nur post sufiksoj, ekz. ne/(venk/ebl)
rv_sen_fin(pD,Spc) <= p(_Pref,De) / &rv_sen_fin(rvs,Spc) ~> subspc(Spc,De). 

% karesnomo
rv_sen_fin('N',Spc) <= nk(_Nom,Spc) / ns(_NomSuf,Ss) ~> subspc(Spc,Ss).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% kunderivitaj vortoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% senfinaĵa vorto + finaĵo, t.e. derivado per finaĵo
% ekz. ŝu/o, (en+ir)/i ...
%
% PLIBONIGO: eble pro optimumigo estus bone havi antau-, kaj postkondichojn
%            momente ":- ..." efikas kiel antaukondichoj...
vorto('Kf',Spc) <= &kdrv(_,Vs) / f(_Fin,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

% foje funkcias apliki sufiksojn nur post kunderivado, ekz. (sen+pied)/ul
vorto('Vf',Spc) <= &vrt_sen_fin(_,Vs) / f(_Fin,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

vrt_sen_fin('Ks',Spc) <= &kdrv(_,Ks) / s(_Suf,Al,De) ~> drv_per_suf(Ks,Al,De,Spc).

% kunderivado per prepozicioj (ekz. sur+strat/a)
kdrv(pD,Al) <= p(_Prep,Al,De) + &rv_sen_fin(_,Spc) ~> subspc(Spc,De).

% kunderivado per adverboj, ekz. altkreska, longdaura, plenkreska
kdrv(rr,adj) <= r(_Adv,Spc1) + r(_Verb,VSpc) ~> (Spc1 = adv ; Spc1 = adj), subspc(VSpc,verb).

% kunderivado per adjektivoj, ekz. multlingva
kdrv(rr,adj) <= r(_Adj,adj) + r(_Subst,SSpc) ~> subspc(SSpc,subst).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% kunmetitaj vortoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% nombrokunmeto, ekz. du*dek
% KOREKTU: permesu nur dekojn kiel N2, ciferojn 1..9 kiel N1
cifero(N) :- memberchk(N,[unu,du,tri,kvar,kvin,ses,sep,ok,'naŭ']). 
vorto(nn,nombr) <= v(N1,nombr) * v(dek,nombr) ~> cifero(N1).
vorto(nn,nombr) <= v(N1,nombr) * v(cent,nombr) ~> cifero(N1).
vorto(nn,nombr) <= v(N1,nombr) * v(mil,nombr) ~> cifero(N1).

% ekz. dom-hund/o, ...
vorto('A+P',Spc) <= &antauvortoj(_,_) - &postvorto(_,Spc).

% foje funkcias apliki prefiksojn nur al jam kunmetita vorto
% ekz. ne/(progres-pov/a)
vorto(pAP,Spc) <= p(_Pref,De) / &kunmetita(_,Spc) ~> subspc(Spc,De).

kunmetita('A+P',Spc) <= &antauvortoj(_,_) - &postvorto(_,Spc).
antauvortoj('A',Spc) <= &antauvorto(_,Spc).
antauvortoj('A+',Spc) <= &antauvorto(_,Spc) - &antauvortoj(_,Spc).

antauvorto('D',Spc) <= &rv_sen_fin(_,Spc).
antauvorto('Dc',Spc) <= &rv_sen_fin(_,_) / c(_InterFin,Spc).
antauvorto(nn,Spc) <= &vorto(nn,Spc).

% eble iom dubindaj ("mi-dir/i" , "ĉiu-hom/o" kompare kund kunderivado "ambaŭ+pied/e", "ĉiu+jar/a"
%antauvorto(Spc) <= v(_V,Spc).
%antauvorto(Spc) <= u(_Pron,Spc).
%antauvorto(Spc) <= i(_Pron,Spc).

postvorto('Df',Spc) <= &rv_sen_fin(_,Vs) / f(_Fin,Fs) 
   ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).







:- ensure_loaded(gramatiko).
:- discontiguous vorto/2, vorto/3.

% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo


sub(X,X).
% sub(X,Z) :- sub(X,Y), sub(Y,Z).
sub(best,subst).
sub(parc,best).
sub(parc,subst).
sub(ntr,verb).
sub(tr,verb).
sub(perspron,pron).

subspc(S1,S2) :-
  sub(S1,S2). %,!.

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

        (Spc=Al, %!, % se temas pri sufiksoj kiel s(aĉ,_,_),
                   % fakte suficxus ekzameni, cxu AlSpeco = _
          Speco=Spc;
          Speco=Al 
        ).


/***
p(en,tr,verb).
r(ir,ntr).
f(i,verb).

sub(tr,verb).
sub(ntr,verb).
***/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% simplaj, nekunmetitaj vortoj 
%%% - nur derivado per afiksoj kaj finaĵoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% simpla vorteto, ekz.  hodiaŭ, ek
vorto(Spc) <= v(_V,Spc).

% simplaj mal-vortoj (malfor, malantaŭ, maltro...)
vorto(Spc) <= p(mal,_) / v(_V,Spc) :- (Spc='adv'; Spc='prep').

% pronomo, ekz. mi
vorto(Spc) <= i(_Pron,Spc). 

% pronomo, ekz. kiu
vorto(Spc) <= u(_Pron,Spc). 

% pron + fin, ekz. mi/n
vorto(Spc) <= i(_Pron,Spc) / fi(_Fin,_).

% pron + fin, ekz. kiu/jn
vorto(Spc) <= u(_Pron,Spc) / fu(_Fin,_).

vorto(Spc) <= &rv_sen_fin(Vs) / f(_Fin,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

/***
verbigo de substantivoj estu iel permesata, ĉu en la gramatiko aŭ per la vortaro:
  planado, muzikado, spicado, kau'zanta, kau'zata (nur por transitivaj)
***/


% radika vorto sen finaĵo (sed kun afiksoj)
rv_sen_fin(Spc) <= r(_Rad,Spc). 
%%rv_sen_fin(Spc) <= &rv_sen_suf(Spc).

% rad+sufikso, ekz. san/ul
rv_sen_fin(Spc) <= &rv_sen_fin(Vs) / s(_Suf,Al,De) ~> drv_per_suf(Vs,Al,De,Spc).

% foje funkcias apliki prefiksojn nur post sufiksoj, ekz. ne/(venk/ebl)
rv_sen_fin(Spc) <= p(_Pref,De) / &rv_sen_fin(Spc) ~> subspc(Spc,De). 

% derivado per prefikso
rv_sen_suf(Spc) <= p(_Pref,De) / &rv_sen_suf(Spc) ~> subspc(Spc,De).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% kunderivitaj vortoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% senfinaĵa vorto + finaĵo, t.e. derivado per finaĵo
% ekz. ŝu/o, (en+ir)/i ...
%
% PLIBONIGO: eble pro optimumigo estus bone havi antau-, kaj postkondichojn
%            momente ":- ..." efikas kiel antaukondichoj...
vorto(Spc) <= &kdrv(Vs) / f(_Fin,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

% foje funkcias apliki sufiksojn nur post kunderivado, ekz. (sen+pied)/ul
vorto(Spc) <= &vrt_sen_fin(Vs) / f(_Fin,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

vrt_sen_fin(Spc) <= &kdrv(Ks) / s(_Suf,Al,De) ~> drv_per_suf(Ks,Al,De,Spc).

% kunderivado per prepozicioj (ekz. sur+strat/a)
kdrv(Al) <= p(_Prep,Al,De) + &rv_sen_fin(Spc) ~> subspc(Spc,De).

% kunderivado per adverboj, ekz. altkreska, longdaura, plenkreska
kdrv(adj) <= r(_Adv,Spc1) + r(_Verb,VSpc) ~> (Spc1 = adv ; Spc1 = adj), subspc(VSpc,verb).

% kunderivado per adjektivoj, ekz. multlingva
kdrv(adj) <= r(_Adj,adj) + r(_Subst,SSpc) ~> subspc(SSpc,subst).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% kunmetitaj vortoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nombrokunmeto, ekz. du*dek
% KOREKTU: permesu nur dekojn kiel N2, ciferojn 1..9 kiel N1
vorto(nombr) <= v(_N1,nombr) * v(_N2,nombr).

% ekz. dom-hund/o, ...
vorto(Spc) <= &antauvortoj(_) - &postvorto(Spc).

% foje funkcias apliki prefiksojn nur al jam kunmetita vorto
% ekz. ne/(progres-pov/a)
vorto(Spc) <= p(_Pref,De) / &kunmetita(Spc) ~> subspc(Spc,De).

kunmetita(Spc) <= &antauvortoj(_) - &postvorto(Spc).
antauvortoj(Spc) <= &antauvorto(Spc).
antauvortoj(Spc) <= &antauvorto(Spc) - &antauvortoj(Spc).

antauvorto(Spc) <= &rv_sen_fin(Spc).
antauvorto(Spc) <= &rv_sen_fin(_) / c(_InterFin,Spc).

% eble iom dubindaj ("mi-dir/i" , "ĉiu-hom/o" kompare kund kunderivado "ambaŭ+pied/e", "ĉiu+jar/a"
%antauvorto(Spc) <= v(_V,Spc).
%antauvorto(Spc) <= u(_Pron,Spc).
%antauvorto(Spc) <= i(_Pron,Spc).

postvorto(Spc) <= &rv_sen_fin(Vs) / f(_Fin,Fs) 
   ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).







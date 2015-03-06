:- ensure_loaded(gramatiko2).

:- multifile rv_sen_fin/5, vorto/5.
:- discontiguous vorto/5.
:- dynamic min_max_len/3.

% PLIBONIGU: anstau uzi user: ebligu importi tion de gramatiko...
:- op( 1120, xfx, user:(<=) ). % disigas regulo-kapon, de regulesprimo
:- op( 1110, xfy, user:(~>) ). % enkondukas kondichojn poste aplikatajn al sukcese aplikita regulo
:- op( 150, fx, user:(&) ). % signas referencon al alia regulo
%:- op( 500, yfx, user:(~) ). % signas disigindajn vortojn

%:- retract(gra_debug(false)).
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

% PLIBONIGU: oni povus pli flekseble tion kalkuli rikure
% el la reguloj mem...(?)
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
vorto(v,Spc) <= v(_,Spc).

% simplaj mal-vortoj (malfor, malantaŭ, maltro...)
vorto(pv,Spc) <= p(mal,_) / v(_,Spc) ~> (Spc='adv'; Spc='prep').

% pronomo, ekz. mi
vorto(i,Spc) <= i(_,Spc). 

% pronomo, ekz. kiu
vorto(u,Spc) <= u(_,Spc). 

% pron + fin, ekz. mi/n
vorto(ifi,Spc) <= i(_,Spc) / fi(_,_).

% pron + fin, ekz. kiu/jn
vorto(ufu,Spc) <= u(_,Spc) / fu(_,_).

vorto('Df',Spc) <= &rv_sen_fin(_,Vs) / f(_,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

% derivaĵo per nomo, ekz "Atlantiko"
% PLIBONIGU: distingu o(jn)-finaĵon (majuskle) kaj aliajn (minuskle)
% ankorau mankas ebleco analizi majusklajn naciojn franc/ -> Franc/uj

vorto('Mf',Spc) <= &nr_sen_fin(_,Vs) / f(_,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

rad(r,Spc) <=  r(_,Spc).
rad('r/',Spc) <=  r(_,Spc) / os(_).

% minusklaj nomradikoj uziĝas kiel ordinaraj
% radikoj, ekz. trans+antlantik, pra/franc/a
rad(m,Spc) <= nr_(_,Spc). 
rad('m/',Spc) <= nr_(_,Spc) / os(_). 

% derivado per prefikso
rv_sen_suf(pr,Spc) <= p(_,De) / &rad(_,Spc) ~> subspc(Spc,De).
rv_sen_suf(pD,Spc) <= p(_,De) / &rv_sen_suf(_,Spc) ~> subspc(Spc,De).

% radika vorto sen finaĵo (sed kun afiksoj)
rv_sen_fin(r,Spc) <= &rad(_,Spc). 

rv_sen_fin('D',Spc) <= &rv_sen_suf(_,Spc).

% rad+sufikso, ekz. san/ul
rv_sen_fin('Ds',Spc) <= &rv_sen_fin(_,Vs) / s(_,Al,De) ~> drv_per_suf(Vs,Al,De,Spc).

% foje funkcias apliki prefiksojn nur post sufiksoj, ekz. ne/(venk/ebl)
rv_sen_fin(pD,Spc) <= p(_,De) / &rv_sen_fin('Ds',Spc) ~> subspc(Spc,De). 

% karesnomo
rv_sen_fin('N',Spc) <= nk(_,Spc) / ns(_,Ss) ~> subspc(Spc,Ss).

% majusklaj nomoj povas havi nur sufiksojn, ekz. Atlantik/ec, Rus/uj
nr_sen_fin('M',Spc) <= nr(_,Spc). 
nr_sen_fin('Ms',Spc) <= &nr_sen_fin(_,Ns) / s(_,Al,De) ~> drv_per_suf(Ns,Al,De,Spc).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% kunderivitaj vortoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% senfinaĵa vorto + finaĵo, t.e. derivado per finaĵo
% ekz. ŝu/o, (en+ir)/i ...
%
% PLIBONIGO: eble pro optimumigo estus bone havi antau-, kaj postkondichojn
%            momente ":- ..." efikas kiel antaukondichoj...
vorto('Kf',Spc) <= &kdrv(_,Vs) / f(_,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

% foje funkcias apliki sufiksojn nur post kunderivado, ekz. (sen+pied)/ul
vorto('Vf',Spc) <= &vrt_sen_fin(_,Vs) / f(_,Fs) 
  ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).

vrt_sen_fin('Ks',Spc) <= &kdrv(_,Ks) / s(_,Al,De) ~> drv_per_suf(Ks,Al,De,Spc).

% kunderivado per prepozicioj (ekz. sur+strat/a)
kdrv(pD,Al) <= p(_,Al,De) + &rv_sen_fin(_,Spc) ~> subspc(Spc,De).

% kunderivado per adverboj, ekz. altkreska, longdaura, plenkreska
kdrv(rr,adj) <= r(_,ASpc) + r(_,VSpc) ~> (ASpc = adv ; ASpc = adj), subspc(VSpc,verb).

% esceptoj kiel artefarita...(?)
% fakte ne estas vera kunderivado, chu???
% krome misanalizas kin/e-arto, vid/e-arto
%%% kdrv(vr,VSpc) <= &vorto(_Adv,adv) ~ r(_Verb,VSpc) ~> subspc(VSpc,verb).

% kunderivado per adjektivoj, ekz. multlingva
kdrv(rr,adj) <= r(_,adj) + r(_,SSpc) ~> subspc(SSpc,subst).

% kunderivado per pronomo: 

%   per ambaŭ manoj -> ambaŭ+mane
kdrv(vr,adj) <= v(_,pron) + r(_,SSpc) ~> subspc(SSpc,subst).
% PLIBONIGU: necesas permesi substantivigi verbojn
% sed pro verbigo de substantivoj en vortaro3.pl momente riskas senfinan ciklon:
%   al tiu celo -> tiucela (tamen verba radiko cel'i)
%   je tia okazo -> tia+okaze, necesus substantivigi okaz'
kdrv(ur,adj) <= u(_,_) + r(_,SSpc) ~> subspc(SSpc,subst).
% ne scias, ekzemploj?...:
%kdrv(ir,adj) <= i(_,_) + r(_,SSpc) ~> subspc(SSpc,subst).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%% kunmetitaj vortoj
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% nombrokunmeto, ekz. du*dek
% KOREKTU: permesu nur dekojn kiel N2, ciferojn 1..9 kiel N1
cifero(N) :- memberchk(N,[unu,du,tri,kvar,kvin,ses,sep,ok,'naŭ']). 
vorto(nn,nombr) <= v(N1,nombr) * v(dek,nombr) ~> cifero(N1).
vorto(nn,nombr) <= v(N1,nombr) * v(cent,nombr) ~> cifero(N1).
vorto(nn,nombr) <= v(N1,nombr) * v(mil,nombr) ~> cifero(N1).

% ekz. dom-hund/o, ..., preferu dupartajn kunmetitajn
vorto('AP',Spc) <= &antauvorto(_,_) - &postvorto(_,Spc).
vorto('A+P',Spc) <= &antauvortoj(_,_) - &postvorto(_,Spc).

% foje funkcias apliki prefiksojn nur al jam kunmetita vorto
% ekz. ne/(progres-pov/a)
vorto(pAP,Spc) <= p(_,De) / &kunmetita(_,Spc) ~> subspc(Spc,De).

% preferu dupartajn kunmetitajn...
kunmetita('AP',Spc) <= &antauvorto(_,_) - &postvorto(_,Spc).

% plurpartaj...
kunmetita('A+P',Spc) <= &antauvortoj(_,_) - &postvorto(_,Spc).
antauvortoj('AA',Spc) <= &antauvorto(_,_) - &antauvorto(_,Spc).
antauvortoj('A+',Spc) <= &antauvorto(_,_) - &antauvortoj(_,Spc).


antauvorto('D',Spc) <= &rv_sen_fin(_,Spc).
antauvorto('Dc',Spc) <= &rv_sen_fin(_,_) / c(_,Spc).
antauvorto('D-',Spc) <= &rv_sen_fin(_,Spc) / ls(_).
antauvorto(nn,Spc) <= &vorto(nn,Spc).

% eble iom dubindaj ("mi-dir/i" , "ĉiu-hom/o" kompare kun kunderivado "ambaŭ+pied/e", "ĉiu+jar/a"
antauvorto('v',Spc) <= v(_,Spc).
antauvorto('u',Spc) <= u(_,Spc).
antauvorto('i',Spc) <= i(_,Spc). % ĉio-pova (pova de ĉio)

postvorto('Df',Spc) <= &rv_sen_fin(_,Vs) / f(_,Fs) 
   ~> (subspc(Vs,Fs),  
      % eble once(...)?            
       Spc=Vs 
     ; Spc=Fs).






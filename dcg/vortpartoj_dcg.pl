
/******************** malstrikta vortanalizo ******
 * komence analizas vorton sen konsideri
 * striktajn derivadregulojn law la funkcioj
 * derivado_per_*. Do afiksoj povas aplikigxi
 * tie cxi al cxiaj vortspecoj.
****************************************************/

radika_vorto_sen_fino(Partoj) --> 
    prefiksoj(Prefiksoj), 
    radiko(Radiko), 
    sufiksoj(Sufiksoj),
    { append([Prefiksoj,[Radiko],Sufiksoj],Partoj) }.

radika_vorto(Partoj) -->
  radika_vorto_sen_fino(RvsfPartoj),
  finajxo(Fino),
  { append(RvsfPartoj,Fino,Partoj) }.

% derivajxo per nomo, ekz "Atlantiko"
% PLIBONIGU: distingu o(jn)-finaĵon (majuskle) kaj aliajn (minuskle)
radika_vorto(Partoj) -->
  nomrad_sen_fino(RvsfPartoj),
  finajxo(Fino),
  { append(RvsfPartoj,Fino,Partoj) }.

nomrad_sen_fino(Partoj) --> % transatlantikej
    prefiksoj(Prefiksoj), {Prefiksoj \= []},
    nomrad_min(Radiko), 
    sufiksoj(Sufiksoj),
    { append([Prefiksoj,[Radiko],Sufiksoj],Partoj) }.

nomrad_sen_fino(Partoj) --> % Atlantikej
    (nomrad_maj(Radiko); nomrad_min(Radiko)), % PLIBONIGU: distingu o(jn)-finaĵon (majuskle) kaj aliajn (minuskle)
    sufiksoj(Sufiksoj),
    { append([[Radiko],Sufiksoj],Partoj) }.

prefiksoj([]) --> [].
prefiksoj([p(Prefikso,DeSpeco)|Prefiksoj]) -->
  p(Prefikso,DeSpeco),
  prefiksoj(Prefiksoj).
prefiksoj([p(Prefikso,AlSpeco,DeSpeco)|Prefiksoj]) -->
  p(Prefikso,AlSpeco,DeSpeco),
  prefiksoj(Prefiksoj).

radiko(r(Radiko,Speco)) -->
  r(Radiko,Speco), 
  % ne traktu afiksojn kiel radikoj
  % por teĥnikaj prefiksoj kiel nitro-, kilo- k.a. difinu
  % apartajn regulojn por predikatoj "prefikso" kaj "sufikso"
  { Speco \= suf, Speco \= pref}.  

nomrad_maj(r(Radiko,Speco)) -->
  nr(Radiko,Speco). % Atlantik

nomrad_min(r(Radiko,Speco)) -->
  nr_(Radiko,Speco). % antlantik

sufiksoj([]) --> [].
sufiksoj([s(Sufikso,AlSpeco,DeSpeco)|Sufiksoj]) -->
  s(Sufikso,AlSpeco,DeSpeco),
  sufiksoj(Sufiksoj).

finajxo([f(Fino,FSpeco)]) -->               
  f(Fino,FSpeco).

finajxo([f(Fino,FSpeco)]) -->  "/", % glutu "/" ĉe /a /o ktp.        
  f(Fino,FSpeco).

kunderivita_sen_fino([r(Adv,adv),r(Verb,VSpc)]) -->
  (radiko(r(Adv,adv)); radiko(r(Adv,adj))),
  radiko(r(Verb,VSpc)), { subspc(VSpc,verb) }. 

kunderivita_sen_fino([r(Adv,adj),r(Subst,SSpc)]) -->
  (radiko(r(Adv,adv)); radiko(r(Adv,adj))),
  radiko(r(Subst,SSpc)), { subspc(SSpc,subst) }. 

kunderivita_vorto(Partoj) -->
  kunderivita_sen_fino(Kdsf),
  finajxo(Fino),
  { append(Kdsf,Fino,Partoj) }.

kunderivita_vorto(Partoj) -->
  kunderivita_sen_fino(Kdsf),
  sufiksoj(Sufiksoj),
  finajxo(Fino),
  { append([Kdsf,Sufiksoj,Fino],Partoj) }.

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

simpla_vorto([v(N1,nombr),v(N2,nombr)]) -->
  v(N1,nombr),
  v(N2,nombr).

% mal+prep, mal+adv
simpla_vorto([p(mal,_),v(Vorto,VSpeco)]) -->
  "mal", v(Vorto,VSpeco),
  {
    (VSpeco='adv'; VSpeco='prep')
  }.

fremda_vorto([fv(Vorto,Speco)]) -->
  fv(Vorto,Speco).

interkunmeto --> "-"; []. % glutu strektetojn en kunmetitaj vortoj

% preferu dupartaj kunmetoj
kunmetita_vorto([AParto,PParto]) -->
  antau_parto(AParto), interkunmeto,
  post_parto(PParto).
 

kunmetita_vorto(Partoj) -->
  antau_partoj(APartoj), interkunmeto,
  post_parto(PParto),
  { APartoj \= [], append(APartoj,[PParto],Partoj) }.

prefikso([p(Prefikso,DeSpeco)]) --> p(Prefikso,DeSpeco).
pref_kunmetita_vorto([Pref|Partoj]) --> 
  prefikso(Pref),
  kunmetita_vorto(Partoj).

antau_partoj([]) --> [].
antau_partoj([P1|P2]) -->
  antau_parto(P1), interkunmeto,
  antau_partoj(P2).

antau_parto(Partoj) -->
  pronomo_sen_fino(Partoj).

% kun interfino (a,o)
antau_parto(Partoj) -->
  radika_vorto_sen_fino(P),
  c(InterFino,Speco),
  { append(P,[c(InterFino,Speco)],Partoj) }.

antau_parto(Partoj) -->
  radika_vorto_sen_fino(Partoj).

post_parto(Partoj) --> radika_vorto(Partoj).


%%%%%%%%%%%%%%%%%%%%%%

vortpartoj(Vorto,Partoj) :-
  phrase(simpla_vorto(Partoj),Vorto).

vortpartoj(Vorto,Partoj) :-
  phrase(fremda_vorto(Partoj),Vorto).

vortpartoj(Vorto,Partoj) :-
  phrase(radika_vorto(Partoj),Vorto).

vortpartoj(Vorto,Partoj) :-
  phrase(kunderivita_vorto(Partoj),Vorto).

% foje funkcias apliki prefiksojn nur al jam kunmetita vorto, ekz. ne/(progres-pov/a)
vortpartoj(Vorto,Partoj) :-
  phrase(pref_kunmetita_vorto(Partoj),Vorto).

vortpartoj(Vorto,Partoj) :-
%  length(Partoj,2), % preferu dupartajn kunmetojn
  phrase(kunmetita_vorto(Partoj),Vorto).

%vortpartoj(Vorto,Partoj) :-
%  phrase(kunmetita_vorto(Partoj),Vorto),
%  length(Partoj,L), L>2.



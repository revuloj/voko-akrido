
/******************** malstrikta vortanalizo ******
 * analizas vorton sen konsideri
 * striktajn derivadregulojn law la funkcioj
 * derivado_per_*. Do afiksoj povas aplikigxi
 * tie cxi al cxiaj vortspecoj.
****************************************************/

% helpfunkcio por eviti senfinajn ciklojn
divido([H1|T1],[H2|T2]) -->
  [H1|T1], [H2|T2].

% radiko
vort_sen_fin_malstrikta(Radiko,Speco) -->
  r(Radiko,Speco).  

% prefikso
vort_sen_fin_malstrikta(Vorto,Speco) -->
  p(Prefikso,_),
  vort_sen_fin_malstrikta(Vsf,Speco),
  { kunigi(Prefikso,Vsf,Vorto) }.


/****
% sufikso
vort_sen_fin_malstrikta(Vorto,SufSpeco) -->
% KOREKTU: se iu ne estas analizebla, tio kondukas al senfina ciklo... 
  vort_sen_fin_malstrikta(Vsf,_),          
  s(Sufikso,SufSpeco,_),
  kunigi(Vsf,Sufikso,Vorto).
****/

% sufikso
vort_sen_fin_malstrikta(Vorto,SufSpeco) -->
  % evitu senfinan ciklon...
  divido(Vrt,Suf),
  { 
    phrase(vort_sen_fin_malstrikta(Vsf,_),Vrt), 
    phrase(s(Sufikso,SufSpeco,_),Suf),
    kunigi(Vsf,Sufikso,Vorto) 
  }.

% kunderivajho
vort_sen_fin_malstrikta(Vorto,PreSpeco) -->
  p(Prefikso,PreSpeco,_),  
  vort_sen_fin_malstrikta(Vsf,_),
  { kunigi(Prefikso,Vsf,Vorto) }.          

% vorteto
vorto_malstrikta(Vorto,Speco) -->             
  v(Vorto,Speco).

% j-pronomo, eble kun finajxo
vorto_malstrikta(Pronomo,Speco) -->
  u(Pronomo,Speco).        

vorto_malstrikta(Vorto,Speco) -->
  u(Pronomo,Speco),
  fu(Fino,_),
  { kunigi(Pronomo,Fino,Vorto) }.

% n-pronomo
vorto_malstrikta(Pronomo,Speco) --> 
  i(Pronomo,Speco).
  
vorto_malstrikta(Pronomo/Fino,Speco) -->
  i(Pronomo,Speco),
  fi(Fino,_).
  
% iu vorto derivita el radiko kaj kun finajxo
vorto_malstrikta(Vorto,Speco) -->               
  vort_sen_fin_malstrikta(Vsf,VSpeco),
  f(Fino,FSpeco),
  { derivado_per_finajxo(Vsf,VSpeco,Fino,FSpeco,Vorto,Speco) }.

/********* malstrikte kunmetitaj vortoj *****/

% pronomoj
unua_vortparto_malstrikta(Pronomo,Speco) -->
  u(Pronomo,Speco).

unua_vortparto_malstrikta(Pronomo,Speco) -->             
  i(Pronomo,Speco).

% iu vorto derivita el radiko
unua_vortparto_malstrikta(Vorto,Speco) -->             
  vort_sen_fin_malstrikta(Vorto,Speco).

% iu vorto derivita el radiko kaj kun inter-litero (o,a)
unua_vortparto_malstrikta(Vorto,Speco) -->  
  vort_sen_fin_malstrikta(Vsf,VSpeco),    
  c(Litero,LSpeco),
  { derivado_per_finajxo(Vsf,VSpeco,Litero,LSpeco,Vorto,Speco) }.

% pluraj kunmetitaj vortoj
/**********
unua_vortparto_malstrikta(Vort1/Vort2,Speco) --> 
% KOREKTU: senfina ciklo...
  unua_vortparto_malstrikta(Vort1,_),
  unua_vortparto_malstrikta(Vort2,Speco).
***/

unua_vortparto_malstrikta(Vorto,Speco) --> 
  % eviti ciklon...
  divido(V1,V2),
  {           
    phrase(unua_vortparto_malstrikta(Vort1,_),V1),
    phrase(unua_vortparto_malstrikta(Vort2,Speco),V2),
    kunigi(Vort1,Vort2,Vorto) 
  }.

% analizi kunmetitan vorton	                   
kunmetita_vorto_malstrikta(Vorto,Speco) -->
  unua_vortparto_malstrikta(Vort1,_),
  vorto_malstrikta(Vort2,Speco),
  { kunigi(Vort1,Vort2,Vorto) }.


/********************* strikta vortanalizo ****************
 * cxe tio la afiksoj aplikigxas nur al certaj vortspecoj
 * kiel difinita en la vortaro.
*/


% radiko
vort_sen_fin(Vorto,Speco) --> 
  r(Vorto,Speco).

% prefikso
vort_sen_fin(Vorto,Speco) -->
  p(Prefikso,DeSpeco),
  vort_sen_fin(Vsf,VSpeco),
  { derivado_per_prefikso(Prefikso,DeSpeco,Vsf,VSpeco,Vorto,Speco) }.

% sufikso
/****
vort_sen_fin(Vorto,Speco) -->
% KOREKTU: tio kondukas al senfina ciklo...    
  vort_sen_fin(Vsf,VSpeco),  
  s(Sufikso,AlSpeco,DeSpeco),
  { derivado_per_sufikso(Vsf,VSpeco,Sufikso,AlSpeco,DeSpeco,Vorto,Speco) }.
***/

% sufikso
vort_sen_fin(Vorto,Speco) -->
  % evitu senfinan ciklon...
  divido(Vrt,Suf),
  { 
    phrase(vort_sen_fin(Vsf,VSpeco),Vrt), 
    phrase(s(Sufikso,AlSpeco,DeSpeco),Suf),
    derivado_per_sufikso(Vsf,VSpeco,Sufikso,AlSpeco,DeSpeco,Vorto,Speco) 
  }.




% kunderivajxo
vort_sen_fin(Vorto,Speco) -->   
  p(Prefikso,AlSpeco,DeSpeco),
  vort_sen_fin(Vsf,VSpeco),         
  { kunderivado([Prefikso,AlSpeco,DeSpeco],[Vsf,VSpeco],[Vorto,Speco]) }.

% vorteto
vorto(Vorto,Speco) -->              
  v(Vorto,Speco).

% j-pronomo

vorto(Pronomo,Speco) -->      
  u(Pronomo,Speco).

vorto(Vorto,Speco) -->      
  u(Pronomo,Speco),
  fu(Fino,_),
  { kunigi(Pronomo,Fino,Vorto) }.
       
% n-pronomo
vorto(Pronomo,Speco) -->            
  i(Pronomo,Speco).

vorto(Vorto,Speco) -->              
  i(Pronomo,Speco),
  fi(Fino,_),
  { kunigi(Pronomo,Fino,Vorto) }.

% mal+prep, mal+adv
vorto(Vorto,Speco) -->
  "mal", v(Vrt,VSpeco),
  {
    (VSpeco='adv'; VSpeco='prep'),
    derivado_per_prefikso('mal',_,Vrt,VSpeco,Vorto,Speco) 
  }.

% vorto derivita el radiko kaj kun finajxo
vorto(Vorto,Speco) -->
  vort_sen_fin(Vsf,VSpeco), 
  f(Fino,FSpeco), 
  { derivado_per_finajxo(Vsf,VSpeco,Fino,FSpeco,Vorto,Speco) }.

%test: phrase(vorto(V,S),"abelujo").


/************ kunmetitaj vortoj **********/

% pronomoj
unua_vortparto(Pronomo,Speco) -->            
  u(Pronomo,Speco).

unua_vortparto(Pronomo,Speco) -->
  i(Pronomo,Speco).

% vorto derivita el radiko sen finajxo
unua_vortparto(Vorto,Speco) -->
  vort_sen_fin(Vorto,Speco).

% vorto derivita el radiko kaj inter-litero (o,a)
unua_vortparto(Vorto,Speco) -->
  c(Litero,LSpeco),     
  vort_sen_fin(Vsf,VSpeco),
  { derivado_per_finajxo(Vsf,VSpeco,Litero,LSpeco,Vorto,Speco) }.

% pluraj vortoj
unua_vortparto(Vorto,Speco) --> 
  % eviti ciklon...
  divido(V1,V2),
  {           
    phrase(unua_vortparto(Vorto1,_),V1),
    phrase(unua_vortparto(Vorto2,Speco),V2),
    kunigi_(Vorto1,Vorto2,Vorto) 
  }.

% analizi kunmetitan vorton                        
kunmetita_vorto(Vorto,Speco) -->
  unua_vortparto(V1,_),
  vorto(V2,Speco),
  { kunigi_(V1,V2,Vorto) }.


/*********** analizfunkcioj ******/

vortanalizo_strikta(Vorto,Analizita,Speco) :-
  call_with_depth_limit(phrase(vorto(Analizita,Speco),Vorto),100,_).

vortanalizo_strikta(Vorto,Analizita,Speco) :-
  call_with_depth_limit(phrase(kunmetita_vorto(Analizita,Speco),Vorto),100,_).

vortanalizo_malstrikta(Vorto,Analizita,Speco) :-
  call_with_depth_limit(phrase(vorto_malstrikta(Analizita,Speco),Vorto),100,_).

vortanalizo_malstrikta(Vorto,Analizita,Speco) :-
  call_with_depth_limit(phrase(kunmetita_vorto_malstrikta(Analizita,Speco),Vorto),100,_).

vortanalizo(Vorto,Analizita,Speco) :-
	% trovu cxiujn strikte analizeblajn eblecojn
	vortanalizo_strikta(Vorto,Analizita,Speco),!.
vortanalizo(Vorto,Analizita,Speco) :-
	% se ne ekzistas strikta ebleco, trovu malstriktajn
	vortanalizo_malstrikta(Vorto,Ana,Speco),
	atom_concat('!',Ana,Analizita).

% por neinteraga regximo kun fina marko (???)
vortanalizo_markita(Vorto,Rezulto) :-
	vortanalizo(Vorto,Ana,Spec),
	term_to_atom([Ana,Spec],Str),
	atom_concat(Str,'###',Rezulto).



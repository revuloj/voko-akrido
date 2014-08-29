
/******************** malstrikta vortanalizo ******
 * analizas vorton sen konsideri
 * striktajn derivadregulojn law la funkcioj
 * derivado_per_*. Do afiksoj povas aplikigxi
 * tie cxi al cxiaj vortspecoj.
****************************************************/

% radiko
vort_sen_fin_malstrikta(Vorto,Rezulto) :- 
	rad(Vorto,Rezulto).  

% prefikso
vort_sen_fin_malstrikta(Vorto,Rezulto) :-               
	pre(Vorto,Resto,[Prefikso,_]),
	atom_length(Resto,L), L>1,
	vort_sen_fin_malstrikta(Resto,[Vsf,Speco]),
	kunigi(Prefikso,Vsf,Speco,Rezulto).

% sufikso
vort_sen_fin_malstrikta(Vorto,Rezulto) :-             
	suf(Vorto,Resto,[Sufikso,AlSpeco,_]),
	atom_length(Resto,L), L>1,
	vort_sen_fin_malstrikta(Resto,[Vsf,_]),
	kunigi(Vsf,Sufikso,AlSpeco,Rezulto).

% kunderivajho
vort_sen_fin_malstrikta(Vorto,Rezulto) :-             
	pre2(Vorto,Resto,[Prefikso,AlSpeco,_]),
	atom_length(Resto,L), L>1,
	vort_sen_fin_malstrikta(Resto,[Vsf,_]),
	kunigi(Prefikso,Vsf,AlSpeco,Rezulto).

% vorteto
vorto_malstrikta(Vorto,[Vorto,Speco]) :-             
	v(Vorto,Speco).

% j-pronomo, eble kun finajxo
vorto_malstrikta(Vorto,Rezulto) :-               
	j_pro(Vorto,Resto,[Pronomo,Speco]),
	(
	    Resto='', Rezulto = [Pronomo,Speco];
	    fu(Resto,_), kunigi(Pronomo,Resto,Speco,Rezulto)
	).

% n-pronomo
vorto_malstrikta(Vorto,Rezulto) :-              
	n_pro(Vorto,Resto,[Pronomo,Speco]),
	(
	    Resto='', Rezulto = [Pronomo,Speco];
	    fi(Resto,_), kunigi(Pronomo,Resto,Speco,Rezulto)
	).

% iu vorto derivita el radiko kaj kun finajxo
vorto_malstrikta(Vorto,Rezulto) :-               
	fin(Vorto,Resto,Finajxo),
	atom_length(Resto,L), L>1,
	vort_sen_fin_malstrikta(Resto,Vsf),
	derivado_per_finajxo(Vsf,Finajxo,Rezulto).

% pronomoj
unua_vortparto_malstrikta(Vorto,[Vorto,Speco]) :-       
	u(Vorto,Speco).

unua_vortparto_malstrikta(Vorto,[Vorto,Speco]) :-             
	i(Vorto,Speco).

% iu vorto derivita el radiko
unua_vortparto_malstrikta(Vorto,Rezulto) :-             
	vort_sen_fin_malstrikta(Vorto,Rezulto).

% iu vorto derivita el radiko kaj kun inter-litero (o,a)
unua_vortparto_malstrikta(Vorto,Rezulto) :-            
	int(Vorto,Resto,Litero),
	atom_length(Resto,L), L>1,
	vort_sen_fin_malstrikta(Resto,Vsf),
	derivado_per_finajxo(Vsf,Litero,Rezulto).

% pluraj kunmetitaj vortoj
unua_vortparto_malstrikta(Vorto,Rezulto) :-            
	% iel dismetu la vorton en partojn kun almenau du literoj
	atom_concat(Parto1,Parto2,Vorto),
	atom_length(Parto1,L1), L1 > 1,
	atom_length(Parto2,L2), L2 > 1,

	% analizu la du partojn
	unua_vortparto_malstrikta(Parto1,[Vorto1,_]),
	unua_vortparto_malstrikta(Parto2,[Vorto2,Speco]),
	kunigi_(Vorto1,Vorto2,Speco,Rezulto).


% analizi kunmetitan vorton	                   
kunmetita_vorto_malstrikta(Vorto,Rezulto) :-
        % iel dismetu la vorton en partojn kun almenau du literoj
	atom_concat(Parto1,Parto2,Vorto),
	atom_length(Parto1,L1), L1 > 1,
	atom_length(Parto2,L2), L2 > 1,

	% analizu la du partojn
	unua_vortparto_malstrikta(Parto1,[Vorto1,_]),
	vorto_malstrikta(Parto2,[Vorto2,Speco]),
	kunigi_(Vorto1,Vorto2,Speco,Rezulto).


/********************* strikta vortanalizo ****************
 * cxe tio la afiksoj aplikigxas nur al certaj vortspecoj
 * kiel difinita en la vortaro.
*/

% radiko
vort_sen_fin(Vorto,Rezulto) :- 
	rad(Vorto,Rezulto).   

% prefikso
vort_sen_fin(Vorto,Rezulto) :-            
	pre(Vorto,Resto,Prefikso),
	atom_length(Resto,L), L>1,
	vort_sen_fin(Resto,Vsf),
	derivado_per_prefikso(Prefikso,Vsf,Rezulto).

% sufikso
vort_sen_fin(Vorto,Rezulto) :-            
	suf(Vorto,Resto,Sufikso), 
   	atom_length(Resto,L), L>1,
	vort_sen_fin(Resto,Vsf),
	derivado_per_sufikso(Vsf,Sufikso,Rezulto).

% kunderivajxo
vort_sen_fin(Vorto,Rezulto) :-            
	pre2(Vorto,Resto,Prefikso), 
   	atom_length(Resto,L), L>1,
	vort_sen_fin(Resto,Vsf),
	kunderivado(Prefikso,Vsf,Rezulto).

% vorteto
vorto(Vorto,[Vorto,Speco]) :-              
	v(Vorto,Speco).

% j-pronomo
vorto(Vorto,Rezulto) :-             
	j_pro(Vorto,Resto,[Pronomo,Speco]),
	(
	    Resto='', Rezulto=[Pronomo,Speco];
	    fu(Resto,_), kunigi(Pronomo,Resto,Speco,Rezulto)
	).

% n-pronomo
vorto(Vorto,Rezulto) :-              
	n_pro(Vorto,Resto,[Pronomo,Speco]),
	(
	    Resto='', Rezulto=[Pronomo,Speco];
	    fi(Resto,_), kunigi(Pronomo,Resto,Speco,Rezulto)
	).

% mal+prep, mal+adv
vorto(Vorto,Rezulto) :-
	atom_concat('mal',Resto,Vorto),
	atom_length(Resto,L), L>1,
	v(Resto,Speco),
	(Speco='adv'; Speco='prep'),
	derivado_per_prefikso(['mal',_],[Resto,Speco],Rezulto).

% vorto derivita el radiko kaj kun finajxo
vorto(Vorto,Rezulto) :-              
	fin(Vorto,Resto,Finajxo),
	atom_length(Resto,L), L>1,
	vort_sen_fin(Resto,Vsf),
	derivado_per_finajxo(Vsf,Finajxo,Rezulto).


% pronomoj
unua_vortparto(Vorto,[Vorto,Speco]) :-            
	u(Vorto,Speco).

unua_vortparto(Vorto,[Vorto,Speco]) :-
	i(Vorto,Speco).

% vorto derivita el radiko sen finajxo
unua_vortparto(Vorto,Rezulto) :-  
	vort_sen_fin(Vorto,Rezulto).

% vorto derivita el radiko kaj inter-litero (o,a)
unua_vortparto(Vorto,Rezulto) :-          
	int(Vorto,Resto,Litero),
	atom_length(Resto,L), L>1,
	vort_sen_fin(Resto,Vsf),
	derivado_per_finajxo(Vsf,Litero,Rezulto).

% pluraj vortoj
unua_vortparto(Vorto,Rezulto) :-   
        % iel dismetu la vorton en partojn kun almenau du literoj
	atom_concat(Parto1,Parto2,Vorto),
	atom_length(Parto1,L1), L1 > 1,
	atom_length(Parto2,L2), L2 > 1,
   
	% analizu la du partojn
	unua_vortparto(Parto1,[Vorto1,_]),
	unua_vortparto(Parto2,[Vorto2,Speco]),
	kunigi_(Vorto1,Vorto2,Speco,Rezulto).

% analizi kunmetitan vorton	                   
kunmetita_vorto(Vorto,Rezulto) :-
        % iel dismetu la vorton en partojn kun almenau du literoj
	atom_concat(Parto1,Parto2,Vorto),
	atom_length(Parto1,L1), L1 > 1,
	atom_length(Parto2,L2), L2 > 1,

	% analizu la du partojn
	unua_vortparto(Parto1,[Vorto1,_]),
	vorto(Parto2,[Vorto2,Speco]),
	kunigi_(Vorto1,Vorto2,Speco,Rezulto).

/*********** analizfunkcioj ******/

vortanalizo_strikta(Vorto,Rezulto) :-
	vorto(Vorto,Rezulto).
vortanalizo_strikta(Vorto,Rezulto) :-
	kunmetita_vorto(Vorto,Rezulto).

vortanalizo_malstrikta(Vorto,Rezulto) :-
	vorto_malstrikta(Vorto,Rezulto).
vortanalizo_malstrikta(Vorto,Rezulto) :-
	kunmetita_vorto_malstrikta(Vorto,Rezulto).

vortanalizo(Vorto,Rezulto) :-
	% trovu cxiujn strikte analizeblajn eblecojn
	vortanalizo_strikta(Vorto,R) *->
	Rezulto=R;
	% se ne ekzistas strikta ebleco, trovu malstriktajn
	vortanalizo_malstrikta(Vorto,[V,S]),
	atom_concat('!',V,R), Rezulto=[R,S].

% por neinteraga regximo kun fina marko
vortanalizo_markita(Vorto,Rezulto) :-
	vortanalizo(Vorto,Rez),
	term_to_atom(Rez,Str),
	atom_concat(Str,'###',Rezulto).



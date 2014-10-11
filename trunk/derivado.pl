

/*******  hierarkieto  de vortspecoj ****************/

sub(X,X).
% sub(X,Z) :- sub(X,Y), sub(Y,Z).
sub(best,subst).
sub(parc,best).
sub(parc,subst).
sub(ntr,verb).
sub(tr,verb).
sub(perspron,pron).

/*************** derivadreguloj *****************/

% kunigi du vortpartojn S1 kaj S2 kaj alpendigi la
% specon Spec.
% ekz. jun'ul+in+best -> [jun'ul'in,best]

kunigi(Vortero1,Vortero2,Speco,[Vorto,Speco]) :-
	atomic_list_concat([Vortero1,',',Vortero2],Vorto).

% nova:
kunigi(V1,V2,Vorto) :- atomic_list_concat([V1,V2],'/',Vorto).

kunigi__(Vortero1,Vortero2,Speco,[Vorto,Speco]) :-
	atomic_list_concat([Vortero1,'_',Vortero2],Vorto).

%nova:
kunigi__(V1,V2,Vorto) :- atomic_list_concat([V1,V2],'+',Vorto).

kunigi_(Vortero1,Vortero2,Speco,[Vorto,Speco]) :-
	atomic_list_concat([Vortero1,'-',Vortero2],Vorto).

%nova:
kunigi_(V1,V2,Vorto):- atomic_list_concat([V1,V2],'-',Vorto).


% derivi vorteron per sufikso.
% ekz. [jun,adj] + [ul,best,adj] -> [jun'ul,best]

derivado_per_sufikso([Vorto,Speco],[Sufikso,AlSpeco,DeSpeco],Rezulto) :-
	sub(Speco,DeSpeco),!,

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

	(Speco=AlSpeco,!, % se temas pri sufiksoj kiel s(acx,_,_),
                          % fakte suficxus ekzameni, cxu AlSpeco = _
          kunigi(Vorto,Sufikso,Speco,Rezulto);
	  kunigi(Vorto,Sufikso,AlSpeco,Rezulto) 
        ).

%nova:
derivado_per_sufikso(Vorto,VSpeco,Sufikso,AlSpeco,DeSpeco,Derivajxo,Speco) :-
	sub(VSpeco,DeSpeco),!,

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

        kunigi(Vorto,Sufikso,Derivajxo),
	(VSpeco=AlSpeco,!, % se temas pri sufiksoj kiel s(acx,_,_),
                          % fakte suficxus ekzameni, cxu AlSpeco = _
          Speco=VSpeco;
	  Speco=AlSpeco 
        ).


% derivi vorteron per prefikso:
% ekz. [mal,adj] + [jun,adj] -> [mal'jun,adj]

derivado_per_prefikso([Prefikso,DeSpeco],[Vorto,Speco],Rezulto) :-
	sub(Speco,DeSpeco),!,
	kunigi(Prefikso,Vorto,Speco,Rezulto).

% nova
derivado_per_prefikso(Prefikso,DeSpeco,Vorto,Speco,Derivajxo,Speco) :-
	sub(Speco,DeSpeco),!,
	kunigi(Prefikso,Vorto,Derivajxo).


% kunderivado, simila al prefikso, sed la rezulto
% estas adjektiva, ekz. [sen,adj,subst] + [hom,subst] ->[sen'hom,adj]

kunderivado([Prefikso,AlSpeco,DeSpeco],[Vorto,Speco],Rezulto) :-
	sub(Speco,DeSpeco),!,
	kunigi__(Prefikso,Vorto,AlSpeco,Rezulto).


% derivi vorteron per finajxo:
% ekz. [jun,adj] + [e,adv] -> [jun'e,adv]

derivado_per_finajxo([Vorto,Speco],[Finajxo,FinSpeco],Rezulto) :-
	sub(Speco,FinSpeco),!,
	kunigi(Vorto,Finajxo,Speco,Rezulto);
	kunigi(Vorto,Finajxo,FinSpeco,Rezulto).


%nova:
derivado_per_finajxo(Vorto,VSpeco,Fino,FSpeco,Derivajxo,VSpeco) :-
	sub(VSpeco,FSpeco),!,
	kunigi(Vorto,Fino,Derivajxo).

derivado_per_finajxo(Vorto,_,Fino,FSpeco,Derivajxo,FSpeco) :-
	kunigi(Vorto,Fino,Derivajxo).


%drv_per_fin(VortSpeco,FinSpeco,VortSpeco) :-
%	sub(VortSpeco,FinSpeco),!.
%drv_per_fin(_,FinSpeco,FinSpeco).

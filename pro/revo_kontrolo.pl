:- module(analizu_revo_art,[
	      analizu_revo_art/1,
	      analizu_revo_art_novaj/0, 
	      analizu_revo_art_prefix/1
	  ]).

:- use_module(library(unix)).
:- use_module(library(filesex)).

:- use_module(analizilo).

revo_txt('../txt').
skribo_pado('../html').

dosiero_max_infer(10000000000). % se 10 mrd. rezonoj ne sufiĉas por dosiero, ĉesu!
concurrent(true).

/** <module> Analizilo por Revo-artikoloj

  Antaŭsupozas, ke la artikoloj estas transformitaj al tekstoj antaŭe. Uzu la Perlo-programeton
  $VOKO/bin/xml2txt.pl por tio. Tekstoj estas antendataj en /home/revo/revo/txt.

  La predikataj enlegas tekston kaj donas la rezulton kun analizitaj vortoj kaj markiloj de neanalizeblaj vortoj. Vidu 
  ./html/klarigoj.html

*/


helpo :-
  format('analizu_revo_art(Art); analizu_revo_art_novaj; analizu_revo_art_prefix(Komenco)').

%! analizu_revo_art(+Artikolo:atom) is det.
%
% Legas artikolon kun dosiernomo Art (sen .txt), analizas kaj skribas la rezulton kiel HTML-kodo al STDOUT.
% Ne analizeblaj vortoj el la verda listo estas markitaj verde anstataŭ ruĝe.


analizu_revo_art(Art) :-
    %legu_verdan_liston_se_malplena,

    artikolo_fonto_dosiero(Art,TxtFile),
    read_file_to_codes(TxtFile,Txt,[]),
    %verda_listo(Art,BL),
    forigu_esceptojn(Txt,Txt1),
    analizu_tekston_kopie(Txt1,html),!. %BL),!.

%! analizu_revo_art_prefix(+Prefikso:atom) is det.
%
% Legas ĉiujn artikolojn kies dosiernomoj komenciĝas per prefikso, analizas ilin kaj skribas la rezulton kiel HTML-dosiero
% al la dosierujo ./kontrolitaj

analizu_revo_art_prefix(Prefix) :-
   %legu_verdan_liston_se_malplena,

   fonto_dosieroj(Prefix,TxtFiles),
   once((
     concurrent(true),
     concurrent_maplist(kontrolu_dosieron,TxtFiles)
    ;
     maplist(kontrolu_dosieron,TxtFiles)
   )).


%! analizu_revo_art_novaj is det.
%
% Legas kaj kontrolas ĉiujn artikolojn kies dosieroj estas pli novaj ol la laste
% kontrolita dosiero (HTML) en dosierujo html/

% al la dosierujo ./kontrolitaj

analizu_revo_art_novaj :-
    format('analizu novajn...~n'),
    %legu_verdan_liston_se_malplena,
    novaj_fonto_dosieroj(Novaj),
    once((
      concurrent(true),
      concurrent_maplist(kontrolu_dosieron,Novaj)
      ;
      maplist(kontrolu_dosieron,Novaj)
    )).


kontrolu_dosieron(TxtFile) :-
    fonto_celo_dosiero(TxtFile,HtmlFile),
    format('~w -> ~w~n',[TxtFile,HtmlFile]),
    read_file_to_codes(TxtFile,Txt,[]),
    forigu_esceptojn(Txt,Txt1),
    dosiero_max_infer(MaxI),
    call_with_inference_limit(
      analizu_tekston_outfile(Txt1,HtmlFile,html), %,BL). 
      %10000000000,
      MaxI,
      _
    ). 

forigu_esceptojn([],[]). % ⧼...⧽ = 10748, ..., 10749
forigu_esceptojn([10748|TxtKun],TxtSen) :- !,
  ignoru_ghis_10749(TxtKun,TxtSen).
forigu_esceptojn([X|TxtKun],[X|TxtSen]) :- !,
  forigu_esceptojn(TxtKun,TxtSen).
ignoru_ghis_10749([10749|TxtKun],TxtSen) :- !,
  forigu_esceptojn(TxtKun,TxtSen).
ignoru_ghis_10749([_|TxtKun],TxtSen) :- !,
  ignoru_ghis_10749(TxtKun,TxtSen).
ignoru_ghis_10749([],[]) :- throw(mankas_ferma_10749).	

artikolo_fonto_dosiero(Art,TxtFile) :-
    atom(Art),
    revo_txt(TxtPado),
    atomic_list_concat([TxtPado,'/',Art,'.txt'],TxtFile).

artikolo_fonto_dosiero(Art,TxtFile) :-
    atom(TxtFile),
    file_base_name(TxtFile,File),
    atom_concat(Art,'.txt',File).

fonto_celo_dosiero(Fnt,Cel) :-
    atom(Fnt),
%   revo_txt(TxtPado), 
   skribo_pado(Kontrolitaj),
   file_base_name(Fnt,FntArt),
   atom_concat(Art,'.txt',FntArt),
   sub_atom(Art,0,1,_,Unua), % ekz.'a'
   atomic_list_concat([Kontrolitaj,'/',Unua,'/',Art,'.html'],Cel).

fonto_celo_dosiero(Fnt,Cel) :-
   atom(Cel),
   revo_txt(TxtPado), 
   file_base_name(Cel,CelArt),
   atom_concat(Art,'.html',CelArt),
   atomic_list_concat([TxtPado,'/',Art,'.txt'],Fnt).

fonto_dosieroj(Prefix,Dosieroj) :-
    revo_txt(TxtPado), 
    atomic_list_concat([TxtPado,'/',Prefix,'*.txt'],TxtInput),
    expand_file_name(TxtInput,Dosieroj).

novaj_fonto_dosieroj(NovajDosieroj) :-
    fonto_dosieroj('',ChiujTxt),
    findall(
      File,
      (
         member(File,ChiujTxt),
         fonto_celo_dosiero(File,Celo),
         once((
	      \+ exists_file(Celo)
	     ;
        set_time_file(File,[modified(FntTempo)],[]),
	      set_time_file(Celo,[modified(CelTempo)],[]),
	      FntTempo > CelTempo
	     ))
      ),
      NovajDosieroj
    ).
	   

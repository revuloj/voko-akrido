:- module(analizu_revo_art,[
	      analizu_revo_art/1,
	      analizu_revo_art_novaj/0, 
	      analizu_revo_art_prefix/1
	  ]).


%:- use_module(library(process)).
:- use_module(library(unix)).
:- use_module(library(filesex)).

:- use_module(analizilo).
:- use_module('dcg/vortlisto_dcg.pl'). % por enlegi la "Verdan Liston"

%:- consult(revo_blanka_listo).
:- consult('vrt/v_revo_evitindaj').

:- dynamic(verda/2).

%revo_xml('/home/revo/revo/xml').
revo_txt('/home/revo/revo/txt').
%txt_xsl('/home/revo/voko/xsl/revotxt_eo.xsl').
skribo_pado('kontrolitaj').
revo_verda_listo('vrt/revo_verda_listo_provizora.txt').

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
% Legas artikolon kun dosiernomo Artikolo (sen .txt), analizas kaj skribas la rezulton kiel HTML-kodo al STDOUT.
% Ne analizeblaj vortoj el la verda listo estas markitaj verde anstataŭ ruĝe.

analizu_revo_art(Art) :-
    legu_verdan_liston_se_malplena,

    artikolo_fonto_dosiero(Art,TxtFile),
    read_file_to_codes(TxtFile,Txt,[]),
    verda_listo(Art,BL),
    analizu_tekston_kopie(Txt,BL),!.

%! analizu_revo_art_prefix(+Prefikso:atom) is det.
%
% Legas ĉiujn artikolojn kies Dosiernomoj komenciĝas per Prefikso, analizas ilin kaj skribas la rezulton kiel HTML-dosiero
% al la dosierujo ./kontrolitaj

analizu_revo_art_prefix(Prefix) :-
   legu_verdan_liston_se_malplena,

   fonto_dosieroj(Prefix,TxtFiles),
   forall(
      member(TxtFile,TxtFiles),
      kontrolu_dosieron(TxtFile)
   ).


%! analizu_revo_art_novaj is det.
%
% Legas kaj kontrolas ĉiujn artikolojn kies dosieroj estas pli novaj ol la laste kontrolita dosiero (HTML) en dosierujo ./kontrolitaj

% al la dosierujo ./kontrolitaj

analizu_revo_art_novaj :-
    format('analizu novajn...~n'),
    legu_verdan_liston_se_malplena,
    novaj_fonto_dosieroj(Novaj),
    forall(
      member(TxtFile,Novaj),
      kontrolu_dosieron(TxtFile)
    ).

artikolo_verda_listo :-
    revo_verda_listo(Infile),
    format('legas ''~w''~n',[Infile]),
    retractall(verda(_,_)),
    setup_call_cleanup(
      open(Infile,read,In),
      artikolo_verda_listo_(In),
      close(In)		 
    ).

artikolo_verda_listo_(In) :-
  (
    repeat,
    read_line_to_codes(In,Linio),
    ( Linio == end_of_file -> !
      ;
      once((
	phrase(linio(Art,Vortoj),Linio)
	   ; atom_codes(L,Linio), throw(sintakseraro(L))
      )),
      % debugging:
      % format('~s~n',[Art,Vortoj]),
      atom_codes(Artikolo,Art),
      assert(verda(Artikolo,Vortoj)),
      fail % read next line
    )
  ).


verda_listo(Art,Listo) :-
  once((
      atom_concat('/',Art1,Art);
      Art1 = Art
    )),
  once((
      verda(Art1,Lst); 
      Lst = []
    )),
  once((
      evi(Art1,Vrt), Vrt1 = [Vrt];
      Vrt1 = []
    )),
  append(Vrt1,Lst,Listo).


kontrolu_dosieron(TxtFile) :-
    fonto_celo_dosiero(TxtFile,HtmlFile),
    format('~w -> ~w~n',[TxtFile,HtmlFile]),
    read_file_to_codes(TxtFile,Txt,[]),
    artikolo_fonto_dosiero(Art,TxtFile),
    verda_listo(Art,BL),
    analizu_tekston_outfile(Txt,HtmlFile,BL). 

legu_verdan_liston_se_malplena :-
    verda(_,_) -> true
    ;  % enlegu la verdan liston se ankorau ne antaue... 
    catch(
	 artikolo_verda_listo,
	 Exc,
	 format('~w~n',[Exc]) % print exception and proceed
    ).
			

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
	   

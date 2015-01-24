:- use_module(library(process)).
:- use_module(library(unix)).
%:- use_module(library(memfile)).

:- consult(analizilo2).
:- consult('dcg/vortlisto_dcg.pl').

%:- consult(revo_blanka_listo).
:- consult('vrt/v_revo_evitindaj').

info :-
  format('revo_art_txt(XmlInput,Txt); analizu_revo_art(Art); analizu_revo_art_litero(Komenco)').

%%% revo_xml('http://retavortaro.de/revo/xml').
revo_xml('/home/revo/revo/xml').
revo_txt('/home/revo/revo/txt').
txt_xsl('/home/revo/voko/xsl/revotxt_eo.xsl').
skribo_pado('kontrolitaj').
%xslt('/usr/bin/xsltproc').
%lynx('/usr/bin/lynx').
revo_verda_listo('vrt/revo_verda_listo.pl').


/***
revo_art_txt(XmlInput,Txt) :-
% xsltproc $VOKO/xsl/revotxt_eo.xsl $infile
  xslt(XsltProc), txt_xsl(Xsl),
% lynx -nolist -dump -assume_local_charset=utf8 -display_charset=utf8 -stdin 
  lynx(Lynx),
  atomic_list_concat([XsltProc,Xsl,XmlInput,'|',Lynx,'-nolist','-dump',
		      '-assume_local_charset=utf8','-display_charset=utf8','-stdin'],' ',Cmd),
  open(pipe(Cmd),read,HtmlOut,[]),
  read_stream_to_codes(HtmlOut,Txt),
  close(HtmlOut).
***/

analizu_revo_art(Art) :-
    revo_txt(TxtPado),
    atomic_list_concat([TxtPado,'/',Art,'.txt'],TxtFile),
    read_file_to_codes(TxtFile,Txt,[]),
    verda_listo(Art,BL),
    analizu_tekston_kopie(Txt,BL).

/***
analizu_revo_art(Art) :-
  revo_xml(XmlPado),
  atomic_list_concat([XmlPado,'/',Art,'.xml'],XmlInput),
  revo_art_txt(XmlInput,Txt),
  verda_listo(Art,BL),
  analizu_tekston_kopie(Txt,BL).
***/

analizu_revo_art_litero(Litero) :-
   revo_txt(TxtPado), 
   skribo_pado(Kontrolitaj),
   atomic_list_concat([TxtPado,'/',Litero,'*.txt'],TxtInput),
   expand_file_name(TxtInput,TxtFiles),
   forall(member(TxtFile,TxtFiles),
     (
       file_base_name(TxtFile,File),
       atom_concat(Art,'.txt',File),
       sub_atom(Art,0,1,_,Unua), % ekz.'a'
       atomic_list_concat([Kontrolitaj,'/',Unua,'/',Art,'.html'],HtmlFile),
       format('~w -> ~w~n',[TxtFile,HtmlFile]),
%      revo_art_txt(XmlFile,Txt),
       read_file_to_codes(TxtFile,Txt,[]),
       verda_listo(Art,BL),
       analizu_tekston_outfile(Txt,HtmlFile,BL)
     )
   ).

/*****
analizu_revo_art_litero(Litero) :-
   revo_xml(XmlPado), 
   skribo_pado(Kontrolitaj),
   atomic_list_concat([XmlPado,'/',Litero,'*.xml'],XmlInput),
   expand_file_name(XmlInput,XmlFiles),
   forall(member(XmlFile,XmlFiles),
     (
       atom_concat(XmlPado,File,XmlFile),
       atom_concat(Art,'.xml',File),
       sub_atom(Art,0,2,_,Unua), % ekz.'/a'
       atomic_list_concat([Kontrolitaj,Unua,Art,'.html'],HtmlFile),
       format('~w -> ~w~n',[XmlFile,HtmlFile]),
       revo_art_txt(XmlFile,Txt),
       verda_listo(Art,BL),
       analizu_tekston_outfile(Txt,HtmlFile,BL)
     )
   ).
****/

artikolo_verda_listo :-
    revo_verda_listo(Infile),
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
      phrase(linio(Art,Vortoj),Linio),
      % debugging:
      format('~s~n',[Art,Vortoj]),
      atom_codes(Artikolo,Art),
      assert(verda(Artikolo,Vortoj)),
      fail % read next line
    )
  ).

artikolo_verda_listo_testo :-
    revo_verda_listo(Infile),
    setup_call_cleanup(
      open(Infile,read,In),
(		       
repeat,
 read_line_to_codes(In,Linio),
    (  Linio == end_of_file
    -> !
    ;   format('~s~n',[Linio]),
       fail
    )
),
      close(In)		 
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

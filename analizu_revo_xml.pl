:- use_module(library(process)).
%:- use_module(library(memfile)).
:- consult(analizilo2).

revo_xml('http://retavortaro.de/revo/xml').
txt_xsl('/home/revo/voko/xsl/revotxt_eo.xsl').
xslt('/usr/bin/xsltproc').
lynx('/usr/bin/lynx').

revo_art_txt(Art,Txt) :-

% xsltproc $VOKO/xsl/revotxt_eo.xsl $infile
  revo_xml(XmlPado),
  atomic_list_concat([XmlPado,'/',Art,'.xml'],XmlInput),
  xslt(Xslt), txt_xsl(Xsl),
  process_create(Xslt,[Xsl,XmlInput],[stdout(pipe(HtmlOut))]),
  read_stream_to_codes(HtmlOut,Html),
  close(HtmlOut),
  
% lynx -nolist -dump -assume_local_charset=utf8 -display_charset=utf8 -stdin 
  lynx(Lynx),
  process_create(Lynx,['-nolist','-dump','-assume_local_charset=utf8','-display_charset=utf8','-stdin'],
		 [stdin(pipe(HtmlIn)),stdout(pipe(TxtOut))]),
  format(HtmlIn,'~s',[Html]),
  close(HtmlIn),
  read_stream_to_codes(TxtOut,Txt),
  close(TxtOut).

analizu_revo_art(Art) :-
   revo_art_txt(Art,Txt),
   analizu_tekston_kopie(Txt).


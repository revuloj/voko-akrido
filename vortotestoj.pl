:- consult(analizilo2).


a1(Vorto,Analizita,Speco) :-
  vortanalizo(Vorto,Ana,Spc),!,
  Ana = Analizita,
  Speco = Spc.

ak(Vorto,Analizita,Speco) :-
  vortanalizo(Vorto,Analizita,Speco).

an(Vorto) :- \+ ak(Vorto,_,_).

% testo de la unua analizo
t1(Vorto,Analizita,Speco) :-
  format('~s -> ~w: ',[Vorto,Analizita]),
  (a1(Vorto,Analizita,Speco) -> format('bone!~n'); format('ERARO~n')).

% testo de iu analizo, ne la unua tuj devas esti ĝusta...
tk(Vorto,Analizita,Speco) :-
  format('~s -> ~w: ',[Vorto,Analizita]),
  (ak(Vorto,Analizita,Speco) -> format('bone!~n'); format('ERARO~n')).

% neanalizebla, negativa testo
tn(Vorto) :-
  format('\\+ ~s: ',[Vorto]),
  (an(Vorto) -> format('bone!~n'); format('ERARO~n')).

testoj_plej :-
  tn("plejofte");
  tn("plejebla");
  tn("plejgranda");
  t1("plejparte",'plej+part/e',adv).

testoj_prunte :-
  tn("pruntedoni");
  tn("pruntepreni");
  t1("pruntedonitaĵo",'prunt/e+don/it/aĵ/o',subst).
  
testoj_prep :-
  tn("depost"),
  tn("ekde").

testoj_pasivo :-
  tn("laborita");
  t1("kaŭzita",'kaŭz/it/a',adj);
  t1("celito",'cel/it/o',best);
  t1("plenplovita",'plen+blov/it/a',adj);
  t1("prilaborita",'pri+labor/it/a',adj).

testoj_ambau :-
  t1("ambaŭflanka",'ambaŭ+flank/a',adj);
  t1("ambaŭflanke",'ambaŭ+flank/e',adv);
  t1("ambaŭtranĉa",'ambaŭ+tranĉ/a',adj);
  t1("ambaŭdekstra",'ambaŭ+dekstr/a',adj);
  t1("ambaŭmana",'ambaŭ+man/a',adj);
  t1("ambaŭdirekta",'ambaŭ+direkt/a',adj);
  t1("ambaŭseksulo",'ambaŭ+seks/ul/o',best);
  t1("ambaŭokaze",'ambaŭ+okaz/e',adv);
  t1("ambaŭlingva",'ambaŭ+lingv/a',adj);
  t1("ambaŭekstreme",'ambaŭ+ekstrem/e',adv).

testoj_nombroj :- 
  t1("okdek",'ok-dek',nombr);
  tn("okdektri");
  tn("dekkvinmil");
  t1("okdektria",'ok-dek+tri/a',adj);
  t1("okdek-tria",'ok-dek+tri/a',adj);
  t1("tricentsesdekkvinono",'tri-cent+ses-dek+kvin/on/o',subst);
  t1("tricent-sesdek-kvinono",'tri-cent+ses-dek+kvin/on/o',subst);
  t1("dekkvinjara",'dek-kvin+jar/a',adj);
  t1("dek-kvin-jara",'dek-kvin+jar/a',adj);
  t1("kvardekmonata",'kvardek+monat/a',adj);
  t1("dekunusilaba",'dek-unu+silab/a',adj);
  t1("dekduedro",'dek+du-edr/o',subst);
  t1("dudekedro",'du-dek-edr/o',subst);
  t1("sesdekkvinedro",'ses-dek+kvin-edr/o',subst);
  t1("sepdekjarulo",'sep-dek+jar/ul/o',best).

testoj_mlg :-
  t1("PIV",'PIV',_);
  t1("PIV-o",'PIV/o',subst);
  t1("PIV-a",'PIV/a',adj);
  t1("PIV-ojn",'PIV-ojn',subst).

testoj_pronomoj :-
  t1("ĉiujara",'ĉiu+jar/a',adj);
  t1("tiujara",'tiu+jar/a',adj);
  t1("kiujare",'kiu+jar/e',adv);
  t1("neniujara",'neniu+jar/a',adj);
  t1("ĉiaspeca",'ĉia+spec/a',adj);
  t1("tiaspece",'tia+spec/e',adv);
  t1("kiaspeca",'kia+spec/a',adj);
  t1("neniaaspekta",'nenia+aspekt/a',adj);
  t1("miaflanke",'mi/a+flank/e',adv);
  t1("viavice",'vi/a+vic/e',adv).

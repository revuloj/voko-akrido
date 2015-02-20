:- consult(gramatiko).

p(en,tr,verb).
r(ir,ntr).
f(i,verb).

sub(tr,verb).
sub(ntr,verb).

kdrv(Al) <= p(_Prep,Al,De) + &rad_sen_suf(Spc) :- sub(Spc,De).
rad_sen_suf(Spc) <= r(_Rad,Spc). 
vrt_sen_fin(Spc) <= &kdrv(Spc).


% pro optimumigo estus bone havi antau, kaj postkondichojn
% momente :- efikas kiel antaukondichoj...
vorto(Spc) <= &vrt_sen_fin(Vs) / f(_Fin,Fs)  % senfinaĵa vorto + finaĵo
  :- (sub(Vs,Fs),                % derivado per finaĵo
       Spc=Vs %,!
     ; Spc=Fs).
    




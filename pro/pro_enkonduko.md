# Enkonduko al Prolog per romiaj ciferoj

<-- https://www.metalevel.at/prolog/concepts -->

Vi povas elprovi cion ĉi ĉe [SWI-Ŝelo `SWISH`](https://swish.swi-prolog.org/).

```
rn(1,'I').
rn(2,'II').
rn(3,'III').
rn(4,'IV').
rn(5,'V').
rn(6,'VI').
rn(7,'VII').
rn(8,'VIII').
rn(9,'IX').
rn(10,'X').
```

Ni povas nun uzi en pluraj manieroj...

1. Demandi, ĉu io estas valida romia nombro:

```
?- rn(_,'VII').
true.

?- rn(_,'IIV').
false.
```
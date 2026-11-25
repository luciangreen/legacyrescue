# legacyrescue

move old code onto a new API without changing what it does. Rewrite rules map a deprecated predicate to a current one with its arguments reordered; rescue/2 rewrites a goal everywhere (inside conjunctions, disjunctions, negations and findall, and where an old predicate is passed by name to call/N, maplist, include, exclude or foldl), and deprecated/2 lists what is still old. The legacy predicates are kept here so old and new goals can be run side by side. Rules: rule(OldName/Arity, NewName, ArgOrder).

## Use

```prolog
?- use_module(prolog/legacyrescue).
?- rescue(concat_old([c], [a, b], X), G).          % G = append([a, b], [c], X)
?- rescue((len_old(N, [x]), \+ member_old([y], q)), G).   % G = (length([x], N), \+ member(q, [y]))
?- rescue(maplist(len_old, Ns, [[a], [b, c]]), G).        % G = maplist(v/[N, L]>>length(L, N), Ns, [[a], [b, c]])
```

## Proofs

`proofs/theorems.pl` proves 6 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every legacy call over lists from [], [a], [a, b], with each argument either given or left open, and the same calls passed by name to call/N, maplist, include, exclude and foldl

1. After rescue no deprecated call remains.
2. The rescued goal has exactly the same answers as the old one.
3. Rescuing twice is the same as rescuing once.
4. Goals with no legacy calls are left alone, and every rule maps to a defined current predicate with a permutation of its arguments.
5. After rescue no retired predicate name is left anywhere in the goal, including closures.
6. deprecated/2 reports something exactly when a retired name is in the goal.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.

# legacyrescue

move old code onto a new API without changing what it does. Rewrite rules map a deprecated predicate to a current one with its arguments reordered; rescue/2 rewrites a goal everywhere (inside conjunctions, disjunctions, negations and findall), and deprecated/2 lists what is still old. The legacy predicates are kept here so old and new goals can be run side by side. Rules: rule(OldName/Arity, NewName, ArgOrder).

## Use

```prolog
?- use_module(prolog/legacyrescue).
?- rescue(concat_old([c], [a, b], X), G).          % G = append([a, b], [c], X)
?- rescue((len_old(N, [x]), \+ member_old([y], q)), G).   % G = (length([x], N), \+ member(q, [y]))
```

## Proofs

`proofs/theorems.pl` proves 4 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every legacy call over lists from [], [a], [a, b], with each argument either given or left open

1. After rescue no deprecated call remains.
2. The rescued goal has exactly the same answers as the old one.
3. Rescuing twice is the same as rescuing once.
4. Goals with no legacy calls are left alone, and every rule maps to a defined current predicate with a permutation of its arguments.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.

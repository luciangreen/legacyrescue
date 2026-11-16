% legacyrescue: move old code onto a new API without changing what it does. Rewrite rules map a
% deprecated predicate to a current one with its arguments reordered; rescue/2 rewrites a goal
% everywhere (inside conjunctions, disjunctions, negations and findall), and deprecated/2 lists
% what is still old. The legacy predicates are kept here so old and new goals can be run side by side.
% Rules: rule(OldName/Arity, NewName, ArgOrder).
%?- rescue(concat_old([c], [a, b], X), G).          % G = append([a, b], [c], X)
%?- rescue((len_old(N, [x]), \+ member_old([y], q)), G).   % G = (length([x], N), \+ member(q, [y]))
:- module(legacyrescue, [rule/3, rescue/2, deprecated/2, concat_old/3, len_old/2, rev_old/2, member_old/2]).
:- use_module(library(lists)).
:- use_module(library(apply)).

rule(concat_old/3, append, [2, 1, 3]).
rule(len_old/2, length, [2, 1]).
rule(rev_old/2, reverse, [1, 2]).
rule(member_old/2, member, [2, 1]).

% The legacy API, as it behaved.
concat_old(B, A, C) :- append(A, B, C).
len_old(N, L) :- length(L, N).
rev_old(L, R) :- reverse(L, R).
member_old(L, X) :- member(X, L).

rescue(G, G) :- var(G), !.
rescue((A, B), (A2, B2)) :- !, rescue(A, A2), rescue(B, B2).
rescue((A ; B), (A2 ; B2)) :- !, rescue(A, A2), rescue(B, B2).
rescue(\+ A, \+ A2) :- !, rescue(A, A2).
rescue(findall(T, A, L), findall(T, A2, L)) :- !, rescue(A, A2).
rescue(G, G2) :- functor(G, N, Ar), rule(N/Ar, New, Order), !, G =.. [_|Args], pick(Order, Args, Args2), G2 =.. [New|Args2].

% pick(+Order, +Args, -Picked): plain recursion, so the goal's variables stay shared with the new goal.
pick([], _, []).
pick([I|Is], Args, [X|Xs]) :- nth1(I, Args, X), pick(Is, Args, Xs).
rescue(G, G).

deprecated(G, Ds) :- findall(N/A, old_in(G, N/A), D0), sort(D0, Ds).
old_in(G, _) :- var(G), !, fail.
old_in((A, B), D) :- !, ( old_in(A, D) ; old_in(B, D) ).
old_in((A ; B), D) :- !, ( old_in(A, D) ; old_in(B, D) ).
old_in(\+ A, D) :- !, old_in(A, D).
old_in(findall(_, A, _), D) :- !, old_in(A, D).
old_in(G, N/A) :- functor(G, N, A), rule(N/A, _, _).

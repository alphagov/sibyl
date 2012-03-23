Sibyl
=====

This is a parser and interpreter for smart answers that aims to address a few
challenges with our current embedded Ruby implementations, specifically:

* Verifying correctness: no cycles, dead ends, or unreachable nodes
* Retaining readability and terseness
* Facilitate proofing by showing all steps
* Have some kind of form that we can share over an API

It's named after the prophets of antiquity. Why Sibyl? Well, I could hardly
call it Oracle or Delphi, could I?

Syntax
------

The syntax is relatively simple, and consists of metadata, steps, and outcomes.
The grammar is specified in the file `lib/sibyl/parser.rb`; some examples
follow. Note that white space is not really significant (the indentation and
line breaks are just a convention) and that anything between `{` and `}` is
evaluated as Ruby against a context object.

    -- Metadata
    metadata need 1660
    metadata status published

    -- Define a multiple-choice step
    step multiple "step a"
      option foo -> "step b"
      option bar -> "step c"

    -- Define a direct transition that sets a variable
    step number "step c"
      set x { input }
      go -> "step d"

    -- Choose a step based on a calculation
    step number "step d"
      set y { input }
      go ->
        if { y > x } -> "step e"
        otherwise    -> "step f"

    -- or
    step multiple "step f"
      option baz ->
        if { something? } -> "step g"
        if { something_else? } -> "step h"
        otherwise -> "step i"
      option quux -> "step j"

    -- Reject values that fail a logical test
    step number "step k"
      reject { input.odd? }
      go -> "step l"

    -- Define final steps
    outcome "step l"

Usage
-----

    require "sibyl/graph"
    graph = Sibyl::Graph.new(source)
    graph.validate! # raises an exception if the graph is incorrect
    step = graph.walk(["yes", "a", "1"])

Validation
----------

Validation checks that:

* There are steps
* Each step is valid
* No step is unreachable
* Every possible exit leads somewhere
* The graph is acyclic

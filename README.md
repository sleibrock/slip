untitled lisp in zig program
---

(title) is a small, compact Lisp-like runtime written in Zig. It is an attempt at creating one's own language and using it for small scripting purposes using a lightweight runtime engine.

The goal of the runtime engine is to create a true REPL experience, and staying true to the purpose of the REPL.

### TODOs:

* figure out string interning (hashing and re-using common strings)
* create a reference counter manager that allocates memory and frees unused variables
* sketch out a running REPL environment structure to manage identifiers and bindings
* create an evaluation abstract syntax tree to parse tokens and be evaluate-able

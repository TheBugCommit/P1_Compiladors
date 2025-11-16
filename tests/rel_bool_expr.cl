int i, j
float x
bool b, b1, b2, b3

i := 10
j := 5
x := 10.0
b1 := true

// Prova d'operadors relacionals
b2 := i > j // true
b3 := i < j // false
b2 := i >= j // true
b3 := i <= j // false
b2 := i = j // false
b3 := i <> j // true
b2 := i = x // true (prova de comparació int/float)
b3 := i <> x // false

// Prova de precedència: not > and > or
// true or false and not true = true or (false and false) = true or false = true
b1 := true or false and not true
// (true or false) and not true = true and false = false
b2 := (true or false) and not true

// Prova combinada
// 10 > 5 and 5 < 10 = true and true = true
b1 := i > j and j < i
// 10 < 5 or 10 = 10.0 and true = false or (true and true) = true
b2 := i < j or i = x and b1

// ----- Proves d'error -----

i := 10
b := i > "hola" // Error: Comparació de tipus incompatibles (int > string)
b := true and 5 // Error: 'and' espera dos booleans
b := not 10 // Error: 'not' espera un booleà
b := i < j < 10 // Error: (si la gramàtica no ho permet, e.g. (i < j) < 10 -> bool < int)

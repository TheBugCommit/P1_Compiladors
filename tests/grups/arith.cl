int i, j, k
float x, y, z

i := 2
j := 3
k := 4
x := 1.5
y := 0.5

// Prova de precedència: ** > * > +
// 10 + 3 * 2**3 = 10 + 3 * 8 = 10 + 24 = 34
i := 10 + j * i ** j
// 2**3**2 = 2**(3**2) = 2**9 = 512 (si l'associativitat és dreta)
// (2**3)**2 = 8**2 = 64 (si l'associativitat és esquerra)
// Cal provar-ho! Assumim associativitat dreta (comú)
k := 2 ** 3 ** 2

// Prova de precedència: *, /, % tenen la mateixa
// 10 * 4 / 2 = 20 / 2 = 10 (associativitat esquerra)
j := 10 * k / i
// 10 % 3 * 4 = 1 * 4 = 4 (associativitat esquerra)
k := 10 % j * k

// Prova de precedència d'unaris (mateixa que +/- binari)
// 10 + -2 = 8
i := 10 + -2
// 10 - -2 = 12
j := 10 - -2
// 10 * (-2) = -20 (l'unari ha de tenir més precedència que *)
k := 10 * (-i)
// 10 / (+2) = 5
i := 10 / (+i)
// -10 + 5 = -5
j := -10 + 5

// Prova de parèntesis
i := (10 + 2) * 3 // 36
j := 10 + (2 * 3) // 16
k := -(10 + 2) // -12

// ----- Proves d'error -----
i := 10 * (2 + 3 // Error: Manca parèntesi de tancament
i := 10 * 2 + // Error: Manca operand
i := (2 + 3) 5 // Error: Manca operador

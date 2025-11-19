float x, y
int i
string s

x := 1.0
i := 10
s := "Bon dia"

// Prova de constants
x := PI //3.14159
y := E //2.71828
x := PI * 2.0 //6.28319

// Prova de funcions trigonomètriques
x := sin(0.0) //0
y := cos(PI) //-1
x := tan(x + y) //-1.55741

// Prova de funcions de cadena
LEN(s) // 7
SUBSTR(s; 0; 3) // "Bon"
SUBSTR("Hola"; 2; 2) // "la"

// Prova d'ús en expressions
sin(PI / 2.0) + cos(0.0) //2
LEN("Hola" + " " + "Món") // 9
SUBSTR(s; 0; LEN(s) - 1) // "Bon di"

// ----- Proves d'error -----
i := PI // Error: Assignació de float a int
x := sin() // Error: Manca 1 argument
x := sin(1.0, 2.0) // Error: Sobren arguments
x := sin("hola") // Error: Tipus d'argument incorrecte (espera float/int)
i := LEN(123) // Error: Tipus d'argument incorrecte (espera string)
s := SUBSTR(s; 1) // Error: Manquen arguments
s := SUBSTR(s; "a"; "b") // Error: Tipus d'argument incorrecte
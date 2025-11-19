// Definició de l'estructura
struct Punt {
    int x;
    float y;
    string nom;
} p1, p2, p5

struct Punt2 {
    int x;
    float y;
    string nom;
} punt2

int x
string nom

// ----- Proves d'error declaracio -----
struct PuntX p3 
struct Cercle {
    struct Punt {
        int x;
        float y;
    } centre
    float radi
} p3 

p3.radi := 3.2
p3.radi

int punt2 //Error punt2 ja declarat
struct Punt2 {
    int x;
    float y;
} p 

// Assignació x accés a camps
p1.x := 10
p1.y := 3.14
p1.nom := "Punt A"

x := p1.x + 5 // 15
nom := p1.nom //"Punt A"
p2.x := p1.x * 2 //20
p2.y := p1.y / 2.0 //1.57
p2.nom := p1.nom + " (copia)" //"Punt A (copia)"

// Ús en expressions
x := p1.x + p2.x // 30
p1.x := p1.x + p2.x // 30

//Copia d'structs
p5 := p1 //Punt
p5.x //30
p5.y //3.14
p5.nom //"Punt A"

p1.x := 3 //3
p1.x //3
p5.x //30

// ----- Proves d'error -----
p1.z := 100 // Error: El camp 'z' no existeix a 'Punt'
x := p1 // Error: Assignació de struct a int
punt2 := p1 // Error: Assignació d'struct diferents a struct (si no està permesa)
p5.x := "hola" // Error: Tipus incorrecte (assignant string a int)
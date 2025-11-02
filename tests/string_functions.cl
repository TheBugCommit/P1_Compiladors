string s, d

s := "Hola"

LEN(s)

d := s + " " + "Mundo " + 1
LEN(s + " " + "Mundo " + 1)
LEN(1)
LEN(true)

SUBSTR(d + "hola" + "!!!"; LEN(d) - 2*3; 10)
SUBSTR(true; LEN(d) - 2*3; 10)
SUBSTR(1; LEN(d) - 2*3; 10)
SUBSTR(d + "hola" + "!!!"; true; 10)
SUBSTR(d + "hola" + "!!!"; "a"; 10)
SUBSTR(d + "hola" + "!!!"; 1; true)
SUBSTR(d + "hola" + "!!!"; 1; "a")

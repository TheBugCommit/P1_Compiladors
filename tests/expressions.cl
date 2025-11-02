int a
float b, c
string s, s_empty
bool l, t, f

# basic assig 
a := 5
b := 3.14
c := -2.71
s := "Hola"
s_empty := ""
l := true
t := true
f := false

# literals and unary
-5
+10
-(+3)
-(-5)
+(-(-3))
---5   
++-+-3 

# basic arith 
a + 2
b * 2.0
c / 2
a % 2
2 ** 3
(-2) ** 3
(-2) ** 4
-(+3*-2) * -2 * -5

# identifiers in expressions
a + b
c * a - b / 2
a + b * c - 1
-c + b
(a + b) * (c - 1)

# strings
s + " Mundo"
"Hola" + " " + "Mundo"
s_empty + "test"
"X" + s_empty + "Y"

# booleans
a > 2
b <= c
l and false
a <> 10
not l
a > 1 and b < 4
l or false
not a > 5 or l and true
a = a
1 = b

# bolean parentesis
(1 < 2) and (3 > 1)
not (l or false)
not (l or false) and (a > 0)

#precedence order
1 + 2 * 3
(1 + 2) * 3
2 ** 3 ** 2           
-(2 ** 3) ** 2
1 + 2 * 3 ** 2
(1 + 2 * 3) ** 10
not false and true or false

# assignations
a := (a + 2) * 3
b := b / (1 + 1)
s := s + "!!!"
l := not (a < 0)

#  Special cases
0 ** 0
a / 0        
a % 0        
"Hola" + 5   
true + 1     
"Test" ** 2  

Instruccions d'execució:
- Des de l'arrel del projecte compilar-lo amb "make"
- Seguidament:
     - make test (executa tots els testos de la carpeta tests/)
     - make run_one FILE=tests/XXX.cl (executa el test XXX)

Desicions de disseny:
 - Per defecte la sortida del log, es troba en la carpeta logs/compiler.log
 - Per emmagatzemar els structs, guardo el nom de l'estruct, amb la "plantilla de atributs" a la taula de simbols.
   Per les diferents instàncies d'estructs, es fa una copia dels atributs de la "plantilla de atributs".
 - Permeto la copia d'structs del mateix tipus com: s1 := s2
 
Limitació: 
 - La obligació a tenir els operadors unaris al mateix nivell que suma i resta, m'obliga a utilitzar parèntesis en operacions 
   on l'operador unari d'aplica la dreta de l'operació, i l'operació té més prioritat que una suma o resta, com:
    1 * (-1)
    5 / (-2)
    2 ** (-2)
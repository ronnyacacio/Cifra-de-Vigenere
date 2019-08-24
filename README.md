# Cifra-de-Vigenere
A cifra de Vigenère é um método de criptografia que usa uma série de diferentes cifras
de César baseadas em letras de uma senha. Esta cifra é muito conhecida porque é fácil pôr
em prática e aparentar ser inquebrável, para quem tem pouca prática em criptoanalise. Du-
rante mais de 300 anos esta cifra foi julgada inquebrável, mas Charles Babbage e Friedrich
Kasiski, independentemente um do outro, encontraram um modo de resolvê-la em meados
do século XIX.

Numa cifra de César, cada letra do alfabeto é deslocada da sua posição um número fixo de
vezes; por exemplo, se tiver um deslocamento de 3, “A” torna-se “D”, “B” vira “E”, etc.
A cifra de Vigenère consiste no uso de várias cifras de César em sequência, com diferentes
valores de deslocamento ditados por uma “palavra-chave”.

Para cifrar, é usada uma tabela de alfabetos que consiste no alfabeto escrito 26 vezes em
diferentes linhas, cada um deslocado ciclicamente do anterior por uma posição. As 26 linhas
correspondem às 26 possı́veis cifras de César. Uma palavra é escolhida como “palavra-chave”,
e cada letra desta palavra vai indicar a linha a ser utilizada para cifrar ou decifrar uma letra
da mensagem.

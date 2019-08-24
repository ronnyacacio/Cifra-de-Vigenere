;
;=====================================================================================
;
;       Filename:  main.asm
;
;    Description:  
;
;        Version:  1.0
;        Created:  14/06/2019 09:03:55
;       Revision:  none
;
;         Author:  Luiz Ronny Acácio, ronnyacacio27@gmail.com
;   Organization:  UFC-Quixadá
;
; =====================================================================================
;/
; 1 passo: Dê um make para compilar e criar os arquivos de chave e de entrada.
; 2 passo: Dê conteúdo à esses dois arquivos para que o programa faça sua função.
; 3 passo: Execute o arquivo 'app'.
; OBS: não altere o nome desses arquivos, pois isso é essencial para o funcinamento do programa.
; OBS: Dê um make clean antes de realizar outra encriptação.

%define BUF_SIZE 256

section .data
;========Mensagens de erro e ecxeções========
print db "Digite 1 para encriptar, 2 para descriptar ou 0 para sair: ",0
tam EQU ($ - print)
printException db "Digite um número válido: ",0
tamException EQU ($ - printException)
ERROR_MSG db "Ocorreu algum erro inesperado na execução!",0
tamERROR EQU ($ - ERROR_MSG)
ERROR_FAIL_ARQ db "Erro, você deve encriptar primeiro!",0
tamERROR_ARQ EQU ($ - ERROR_FAIL_ARQ)
ERROR_FAIL_IN db "Erro, algum arquivo chamado 'entrada.txt' deve ser criado!",0
tamERROR_IN EQU ($ - ERROR_FAIL_IN)
ERROR_FAIL_KEY db "Erro, algum arquivo chamado 'chave.txt' deve ser criado!",0
tamERROR_KEY EQU ($ - ERROR_FAIL_KEY)
ERROR_EXISTS db "Erro, o arquivo já foi cifrado!",0
tamERROR_ERROR_EXISTS EQU ($ - ERROR_EXISTS)
ERROR_EXISTS_2 db "Erro, o arquivo já foi decifrado!",0
tamERROR_ERROR_EXISTS_2 EQU ($ - ERROR_EXISTS_2)
newline db 10
tamLine EQU ($ - newline)

;========Nome para os arquivos========
in_file_name db "entrada.txt",0
in_file_name_chave db "chave.txt",0
out_test db "saidaCrip.txt",0
out_file_descrip db "saidaDescrip.txt",0

section .bss
;========variáveis========
opcao resb 1
fd_in resd 1
fd_in_chave resd 1
fd_out resd 1
in_buf resd BUF_SIZE
in_buf_chave resd BUF_SIZE
out_buf resd BUF_SIZE

section .text
global _start
_start:
    mov ebp, esp

    Print_option: ;Interrupção para imprimir a mensagem de menu
    mov EAX, 4
    mov EBX, 1
    mov ECX, print
    mov EDX, tam
    int 0x80

    ler: ;Interrupção para ler a entrada do usuário
    mov EAX, 3
    mov EBX, 0
    mov ECX, opcao
    mov EDX, 2
    int 0x80

    ;Menu que analísa a entrada do usuário
    ;Executando assim o que lhe foi pedido
    cmp [opcao], byte 49
    je cripitografar
    cmp [opcao], byte 50 
    je descriptografar 
    cmp [opcao], byte 48
    je done
    
    ;Interrupção que imprime uma mensagem de exceção
    ;Caso seja digitado um número inválido
    mov EAX, 4
    mov EBX, 1  
    mov ECX, printException
    mov EDX, tamException
    int 0x80 
    jmp ler

cripitografar:
open_input: ;Interrupção que abre o arquivo 'entrada.txt'
    mov EAX,5            
    mov EBX,in_file_name 
    mov ECX,0            
    mov EDX,0700         
    int 0x80
    mov [fd_in], EAX ;Move para a variável 'fd_in' a localização
                     ;dos caractares do arquivo 'entrada.txt'      
    
    cmp EAX, 0 ;Caso EAX < 0, algum erro ocorreu na abertura 
    jge open_key
    call ErroIN ;Mensagem de erro
    call NEWLINE ;Quebra de linha
    jmp done ;Fim da execução

open_key: ;Interrupção que abre o arquivo 'chave.txt'
    mov EAX, 5
    mov EBX, in_file_name_chave
    mov ECX, 0
    mov EDX, 0700
    int 0x80
    mov [fd_in_chave], EAX ;Move para a variável 'fd_in_chave' a localização
                           ;dos caracteres do arquivo 'chave.txt'

    cmp EAX, 0 ;Caso EAX < 0, algum erro ocorreu na abertura
    jge create
    call ErroKEY ;Mensagem de erro
    call NEWLINE ;Quebra de linha
    jmp done ;Fim da execução

create: ;Interrupção que cria o arquivo 'SaidaCrip.txt'
    mov EAX,8                
    mov EBX,out_test    
    mov ECX,777              
    int 0x80
    mov [fd_out],EAX ;Move para a variável 'fd_out' a localização
                     ;do arquivo

    cmp EAX, 0 ;Caso EAX < 0, algum erro ocorreu na criação
    jge read_key
    call Erro_exists ;Mensagem de erro
    call NEWLINE ;Quebra de linha
    jmp done ;Fim da execução

read_key: ;Interrupção que ler o arquivo 'chave.txt'
    mov EAX, 3
    mov EBX, [fd_in_chave]
    mov ECX, in_buf_chave
    mov EDX, BUF_SIZE
    int 0x80
    mov edi, EAX ;Move para EDI a quantidade de caracteres lídos

read_input: ;Interrupção que ler o arquivo 'entrada.txt'
    mov EAX, 3
    mov EBX, [fd_in]
    mov ECX, in_buf
    mov EDX, BUF_SIZE
    int 0x80

criptar: ;Início da criptação
    mov ecx, EAX
    xor edx, edx
    xor esi, esi
    ;ESI: Iterador do buffer de entrada
    ;EDX: Iterador do buffer de chave
    A:  
        ;Comparação que replica a chave caso ela seja menor do que a entrada
        cmp edi, edx
        jg R
        xor edx, edx

        R:
        ;Logíca da cifra de Vigenère ((((Input+Key)-130)%26)+65)
        ;Input+Key-130
        mov bl, [in_buf+(esi)]
        add bl, [in_buf_chave+(edx)]
        sub bl, 130
        
        ;Mod 26
        push edx
        push eax
        push ecx
        mov eax, ebx
        xor edx, edx
        mov ecx, 26
        div ecx
        mov bl, dl
        pop ecx
        pop eax
        pop edx
        
        ;+ 65
        add bl, 65
        mov [in_buf+(esi)], bl
        add esi, 1
        add edx, 1
        dec ecx
        cmp ecx, 0
        jne A

write: ;Interrupção que escreve no arquivo "saidaCrip.txt"
    mov EDX, EAX ;Quantidade de caracteres que serão
    mov EAX, 4
    mov EBX, [fd_out]
    mov ECX, in_buf
    int 0x80

close_out: ;Interrupção que fecha o arquivo "SaidaCrip.txt"
    mov EAX,6           
    mov EBX,[fd_out]
    int 0x80

close_key: ;Interrupção que fecha o arquivo "chave.txt"
    mov EAX, 6
    mov EBX, [fd_in_chave]
    int 0x80

close_in: ;Interrupção que fecha o arquivo "entrada.txt"
    mov EAX,6
    mov EBX,[fd_in]
    int 0x80
    jmp done ;Pula pro encerramento do programa

descriptografar:
open_out: ;Interrupção que abre o arquivo "SaidaCrip.txt"
    mov EAX, 5
    mov EBX, out_test
    mov ECX, 0
    mov EDX, 0700
    int 0x80
    mov [fd_in], EAX

    cmp EAX, 0 ;Verifica se a encriptação já foi feita
    jge open_key2
    call ErroArq ;Mensagem de erro
    call NEWLINE ;Quebra de linha
    jmp Print_option ;Volta ao início para que o usuário realize outra operação antes

open_key2: ;Interrupção que abre o arquivo "chave.txt"
    mov EAX, 5
    mov EBX, in_file_name_chave
    mov ECX, 0
    mov EDX, 0700
    int 0x80
    mov [fd_in_chave], EAX

    cmp EAX, 0 ;Verifica se o arquivo existe
    jge create2
    jmp Erro ;Mensagem de erro

create2: ;Interrupção que cria o arquivo "SaidaDescrip.txt"
    mov EAX, 8
    mov EBX, out_file_descrip
    mov ECX, 777
    int 0x80
    mov [fd_out], EAX

    cmp EAX, 0 ;Verifica se houve algum erro na criação
    jge read_key2
    call Erro_exists2 ;Mensagem de erro
    call NEWLINE ;Quebra de linha
    jmp done ;Pula para o encerramento do programa

read_key2: ;Interrupção que lê o arquivo "chave.txt"
    mov EAX, 3
    mov EBX, [fd_in_chave]
    mov ECX, in_buf_chave
    mov EDX, 256
    int 0x80
    mov edi, EAX ;Guarda em EDI a quantidade de caracteres lídos

read_out: ;Interrupção que que lê o  arquivo "SaidaCrip.txt"
    mov EAX, 3
    mov EBX, [fd_in]
    mov ECX, in_buf
    mov EDX, 256
    int 0x80

descriptar: ;Início da decriptação
    mov ecx, EAX ;Move para ECX a quantidade de caracteres do arquivo "SaidaCrip.txt"
    xor esi, esi
    xor edx, edx
    ;ESI: Iterador do buffer do arquivo cifrado
    ;EDX: Iterador do buffer de chave
    P:
        ;Comparação que replica a chave caso ela seja menor do que o arquivo cifrado
        cmp edi, edx
        jg G
        xor edx, edx
        ;Logíca contrária da cifra de Vigenère ((((Output-Key)+26)%26)+65)
        ;Input-Key+26
        G:
        mov bl, [in_buf+(esi)]
        sub bl, [in_buf_chave+(edx)]
        add bl, 26

        ;Mod 26
        push edx
        push eax
        push ecx
        mov eax, ebx
        xor edx, edx
        mov ecx, 26
        div ecx
        mov bl, dl
        pop ecx
        pop eax
        pop edx

        ;+65
        add bl, 65
        mov [in_buf+(esi)], bl
        add esi, 1
        add edx, 1
        dec ecx
        cmp ecx, 0
        jne P

write2: ;Interrupção que escreve no arquivo "SaidaDescrip.txt"
    mov EDX, EAX
    mov EAX, 4
    mov EBX, [fd_out]
    mov ECX, in_buf
    int 0x80

close_out_Descrip: ;Interrupçao que fecha o arquivo "SaidaDescrip.txt"
    mov EAX, 6
    mov EBX, [fd_out]
    int 0x80

close_out_Crip: ;Interrupção que fecha o arquivo "SaidaCrip.txt"
    mov EAX, 6
    mov EBX, [fd_in]
    int 0x80

close__key: ;Interrupção que fecha o arquivo "chave.txt"
    mov EAX, 6
    mov EBX, [fd_in_chave]
    int 0x80

done: ;Interrupção que encerra o programa
    mov ebx, 0 ;Error_code = 0 (OK)
    mov eax, 1
    int 0x80 ; Kernel

;=======Interrupções de Ecxeções / Procedimentos de organização=======; 
Erro:
    mov EAX, 4
    mov EBX, 1
    mov ECX, ERROR_MSG
    mov EDX, tamERROR
    int 0x80
    ret

ErroArq:
    mov EAX, 4
    mov EBX, 1
    mov ECX, ERROR_FAIL_ARQ
    mov EDX, tamERROR_ARQ
    int 0x80
    ret

ErroIN:
    mov EAX, 4
    mov EBX, 1
    mov ECX, ERROR_FAIL_IN
    mov EDX, tamERROR_IN
    int 0x80
    ret

ErroKEY:
    mov EAX, 4
    mov EBX, 1
    mov ECX, ERROR_FAIL_KEY
    mov EDX, tamERROR_KEY
    int 0x80
    ret

Erro_exists:
    mov EAX, 4
    mov EBX, 1
    mov ECX, ERROR_EXISTS
    mov EDX, tamERROR_ERROR_EXISTS
    int 0x80
    ret

Erro_exists2:
    mov EAX, 4
    mov EBX, 1
    mov ECX, ERROR_EXISTS_2
    mov EDX, tamERROR_ERROR_EXISTS_2
    int 0x80
    ret

NEWLINE:
    mov EAX, 4
    mov EBX, 1
    mov ECX, newline
    mov EDX, tamLine
    int 0x80
    ret
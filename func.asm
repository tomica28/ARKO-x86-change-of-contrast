section	.data
array	TIMES 256 DB 0

section	.text
global  func

func:
	push	ebp
	mov	ebp, esp
    push ebx

    ;napelnianie tablicy
    mov ebx, array
    mov eax, 0
wpisywanie:
    mov byte[ebx], al
    add ebx, 1
    add eax, 1
    cmp eax, 256
    jl wpisywanie
    ;wybor trybu
    cmp DWORD[ebp+20], 1
    je factor

    mov eax, [ebp+8]
    mov ebx, DWORD[eax+10];offset
    mov ecx, DWORD[eax+34];rozmiar bitmapy
    add eax, ebx ;na poczatek bit mapy
    movzx ebx, byte[eax] ;ebx min
    movzx edx, byte[eax] ;edx maks
    add eax, 1
petla_szukaj:
    push ecx
    movzx ecx, byte[eax]
    test ecx, ecx
    jz dalej
    cmp ecx, ebx
    jg spr_histo
    mov ebx, ecx
spr_histo:
    cmp ecx, edx
    jl dalej
    mov edx, ecx
dalej:
    add eax, 1
    pop ecx
    sub ecx, 1
    cmp ecx, 0
    jg petla_szukaj


    ;w edx maks w ebx min
    ;obliczenie maks - min w edx
    sub edx, ebx
    mov eax, 255
    mov ecx, edx
    mov edx, 0
    shl eax, 12
    shl ecx, 6
    div ecx
    mov edx, eax
    ;uzupelnienie tablicy

    mov ecx, array
	mov eax, 256

petla_tablica_histo:
    push eax
    movzx eax, byte[ecx]
    sub eax, ebx
    shl eax, 6
    push edx
    imul edx
    pop edx
    sar eax, 12

zapis_histo:
    mov byte[ecx], al
    add ecx, 1
    pop eax
    sub eax, 1
    cmp eax, 0
    jg petla_tablica_histo

    jmp zmiana
factor:	;obczliczam factor
	mov	ecx, DWORD [ebp+16]	;wczytuje kontrast
	mov	ebx, ecx
	mov	eax, 259
	sub	eax, ecx
	mov edx, 255
	mul	edx
	mov	ecx, eax
	add	ebx, 255
	mov	eax, ebx
	mov edx, 259
	mul	edx
	shl	eax, 12
	shl	ecx, 6
	div	ecx
	;w eax factor
	push eax	;factor na stos
	;petal tworzaca tablice kolorow
	mov ebx, array
	mov ecx, 256
petla_tablica:
    movzx eax, byte[ebx]
    sub eax, 128
    shl eax, 6
    mov edx, [ebp-8]
    imul edx
    sar eax, 12
    add eax, 128
    cmp eax, 255
    jl spr
    mov eax, 255
spr:
    cmp eax, 0
    jge zapis
    mov eax, 0
zapis:
    mov byte[ebx], al
    add ebx, 1
    sub ecx, 1
    cmp ecx, 0
    jg petla_tablica

    ;zdejmuje factor ze stosu
    pop eax
zmiana:
    ;przeksztalcanie obrazu
    mov	ebx, DWORD [ebp+12]	;adres *b do eax
	mov	eax, DWORD [ebp+8]	;adres *a do ebx


	mov ecx, DWORD[eax+10]
kopia_header:
    mov dl, byte[eax]
    mov byte[ebx],  dl
    sub ecx, 1
    add eax, 1
    add ebx, 1
    cmp ecx, 0
    jg  kopia_header

    ;wczytanie rozmiaru bitmapy
    mov ecx, [ebp+8]
    mov edx, DWORD[ecx+34]

petla_glowna:
    push edx
    movzx ecx, byte[eax]  ;wczytanie bajtu ze zrodla
debug1:
    mov edx, array
debug2:
    add edx, ecx    ;odczyt nowej wartosci z tablicy
debug3:
    mov cl, byte[edx]
debug4:
    mov byte[ebx], cl   ;zapis nowej wartosci
    add eax, 1
    add ebx, 1
    pop edx
    sub edx, 1
    cmp edx, 0  ;sprawdzenie czy juz wszystkie bajty
    jg  petla_glowna

epilog:
    pop ebx
	pop	ebp
	ret



.section .text
.globl _start

_start:
    lw x8, 88(x0)      # Lee M desde la dirección 88(x0)
    addi x9, x0, 0
    beq x8, x9, suma     # Si M == 0, realiza la suma A + B
    addi x9, x0, 1
    beq x8, x9, restaAB  # Si M == 1, realiza A - B
    addi x9, x0, 2
    beq x8, x9, restaBA  # Si M == 2, realiza B - A
    addi x9, x0, 3
    beq x8, x9, andAB    # Si M == 3, realiza A AND B
    addi x9, x0, 4
    beq x8, x9, orAB     # Si M == 4, realiza A OR B
    addi x9, x0, 5
    beq x8, x9, xorAB    # Si M == 5, realiza A XOR B
    addi x9, x0, 6
    beq x8, x9, notA     # Si M == 6, realiza NOT A
    addi x9, x0, 7
    beq x8, x9, notB     # Si M == 7, realiza NOT B
    addi x9, x0, 8
    beq x8, x9, mulAB    # Si M == 8, realiza A * B
    addi x9, x0, 9
    beq x8, x9, divAB    # Si M == 9, realiza A / B
    addi x9, x0, 10
    beq x8, x9, shiftL   # Si M == 10, realiza desplazamiento a la izquierda
    addi x9, x0, 14
    beq x8, x9, fibonacci # Si M == 14, realiza Fibonacci
    addi x9, x0, 15
    beq x8, x9, factorial # Si M == 15, realiza Factorial de A
    addi x9, x0, 16
    beq x8, x9, potenciaAB  # Si M == 16, realiza A^B
    addi x9, x0, 17
    beq x8, x9, modAB       # Si M == 17, realiza A % B
    addi x9, x0, 18
    beq x8, x9, raizA       # Si M == 18, realiza la raíz cuadrada de A

    j _start              # Si no coincide, reinicia

# Operaciones
suma:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    add x3, x4, x5        # A + B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

restaAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    sub x3, x4, x5        # A - B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

restaBA:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    sub x3, x5, x4        # B - A
    sw x3, 100(x0)        # Guarda el resultado
    j _start

andAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    and x3, x4, x5        # A AND B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

orAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    or x3, x4, x5         # A OR B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

xorAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    xor x3, x4, x5        # A XOR B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

notA:
    lw x4, 96(x0)         # Lee A
    not x3, x4            # NOT A
    sw x3, 100(x0)        # Guarda el resultado
    j _start

notB:
    lw x5, 92(x0)         # Lee B
    not x3, x5            # NOT B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

mulAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    mul x3, x4, x5        # A * B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

divAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    div x3, x4, x5        # A / B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

shiftL:
    lw x4, 96(x0)         # Lee A
    sll x3, x4, 1         # Desplazamiento a la izquierda
    sw x3, 100(x0)        # Guarda el resultado
    j _start

fibonacci:
    lw x4, 96(x0)         # Lee A
    # Algoritmo de Fibonacci aquí
    sw x3, 100(x0)        # Guarda el resultado
    j _start

factorial:
    lw x4, 96(x0)         # Lee A (número a calcular factorial)
    li x3, 1             # Inicializa resultado en 1
    li x5, 1             # Inicializa contador en 1

loop_factorial:
    beq x4, x0, done     # Si n == 0, termina (factorial de 0 es 1)
    mul x3, x3, x4       # resultado *= n
    addi x4, x4, -1      # n -= 1
    bne x4, x0, loop     # Repetir mientras n > 0

done_factorial:
    sw x3, 100(x0)       # Guarda el resultado en memoria
    j _start             # Regresa al inicio

# Nuevas operaciones
potenciaAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    li x3, 1             # Inicializa resultado en 1
    beq x5, x0, done     # Si B == 0, el resultado es 1

loop_potencia:
    mul x3, x3, x4       # resultado *= A
    addi x5, x5, -1      # B -= 1
    bne x5, x0, loop     # Repetir mientras B > 0

done_potencia:
    sw x3, 100(x0)       # Guarda el resultado en memoria
    j _start             # Regresa al inicio

modAB:
    lw x4, 96(x0)         # Lee A
    lw x5, 92(x0)         # Lee B
    rem x3, x4, x5        # A % B
    sw x3, 100(x0)        # Guarda el resultado
    j _start

raizA:
    lw x4, 96(x0)        # Lee A
    li x3, 0             # Inicializa resultado (raíz)
    li x5, 1             # Inicializa contador impar (1, 3, 5, ...)
    
loop:
    sub x4, x4, x5       # A -= número impar
    blt x4, x0, done     # Si A < 0, terminar
    addi x3, x3, 1       # Incrementa resultado
    addi x5, x5, 2       # Siguiente número impar
    j loop               # Repite el ciclo

done:
    sw x3, 100(x0)       # Guarda el resultado en memoria
    j _start             # Regresa al inicio
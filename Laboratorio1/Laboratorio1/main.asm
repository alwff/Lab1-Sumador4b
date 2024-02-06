
;******************************************************************
;
; Universidad del Valle de Guatemala 
; IE2023:: Programación de Microcontroladores
; contador_antirebote.asm
; Autor: Alejandra Cardona 
; Proyecto: Laboratorio 1
; Hardware: ATMEGA328P
; Creado: 30/01/2024
; Última modificación: 05/02/2024
;
;******************************************************************
; ENCABEZADO
;******************************************************************

.INCLUDE "M328PDEF.INC"
.CSEG

.ORG 0x00

;******************************************************************
; STACK POINTER
;******************************************************************

	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

;******************************************************************
; CONFIGURACIÓN 
;******************************************************************
Setup:

	;Prescaler
	LDI R24, (1 << CLKPCE)
	STS CLKPR, R24		
	LDI R24, 0b0000_0100
	STS CLKPR, R24			; (Dividido por 16, 1MHz)
	
	;Setting
	;Direcciones
	LDI R18, 0b0000_1111 ; (1<<PC3)|(1<<PC2)|(1<<PC1)|(1<<PC0) para Sumador 1 
	LDI R19, 0b0010_0111 ; (1<<PB5)|(1<<PB2)|(1<<PB1)|(1<<PB0) para Sumador 2 
	LDI R20, 0b0001_1111 ; (1<<PD4)|(1<<PD3)|(1<<PD2)|(1<<PD1)|(1<<PD0) para Resultado 
	OUT	DDRB, R19 ; DDR en la dirección asignada se carga el registro.
	OUT	DDRC, R18
	OUT	DDRD, R20
	LDI R18, 0b0001_1000 ; Pullups
	LDI R19, 0b0011_0000 
	LDI R20, 0b0010_0000
	OUT PORTB, R18
	OUT PORTC, R19
	OUT PORTD, R20	; Fin de pullups
	; Los registros donde se opera inician en 0
	LDI R21, 0 ;Sumador 1
	LDI R22, 0 ;Sumador 2
	LDI R23, 0 ;Resultado
	LDI R28, 1 ;Operador, vale 1bit y permite agregar o quitar al contador con cada pulso de botón.

;******************************************************************
; LOOP 
;******************************************************************

LOOP: 
	SBIS PINB, PB4
	CALL BUT1
	SBIS PINB, PB3
	CALL BUT2
	SBIS PINC, PC4
	CALL BUT3
	SBIS PINC, PC5
	CALL BUT4
	SBIS PIND, PD5
	CALL BUT5
	RJMP LOOP

;****************************************************************** 
; Delay
; Código de delay basado en "https://www.youtube.com/watch?v=zQ3av4G9Hzs&ab_channel=RojoCaf%C3%A9"
;******************************************************************
Delayy: 
	
	LDI R25, 0xFF ; El valor máximo para el ATmega328p
	DelayyA: 
		LDI R26, 0xFF
		DelayyB: 
			DEC R25
			BRNE DelayyB ; Branch if not equal, siempre que no sea 0 se cicla
			DEC R26
			BRNE DelayyA
	RET ; Regresa al punto donde fue llamada la etiqueta
 	
;****************************************************************** 
		
			; FUNCIÓN DE LOS BOTONES: 

		;BOTÓN1 Y BOTÓN3 AGREGAN AL CONTADOR 
		;BOTÓN2 Y BOTÓN4 QUITAN AL CONTADOR
			;BOTÓN1 Y BOTÓN2 AL SUMADOR 1
			;BOTÓN3 Y BOTÓN4 AL SUMADOR 2
			;BOTÓN5 MUESTRA RESULTADO

;****************************************************************** 
; SUMADOR  1 (Usa el registro R21)
;****************************************************************** 

BUT1:
CALL Delayy ; Retraso
CLR R27 ; Se limpia R27	
MOV R27, R28 ; A R27 se le asigna valor de 1 bit
ADD R21, R27 ; Se le suma al valor de R27 A R21 
OUT PORTB, R21 ; El resultado sale a PORTB
RJMP LOOP

BUT2:	
CALL Delayy
CLR R27
MOV R27, R28
SUB R21, R27 ; Se le resta el valor de R27 A R21 
OUT PORTB, R21
RJMP LOOP

;****************************************************************** 
; SUMADOR 2 (Usa el registro R22)
;****************************************************************** 

BUT3:
CALL Delayy
CLR R27 ; Se limpia R27	
MOV R27, R28 ; A R27 se le asigna valor de 1 bit
ADD R22, R27 ; Se le suma al valor de R27 A R22 
OUT PORTC, R22 ; El resultado sale a PORTC
RJMP LOOP

BUT4: 
CALL Delayy
CLR R27
MOV R27, R28
SUB R22, R27 ; Se le resta el valor de R27 A R22
OUT PORTC, R22
RJMP LOOP

;****************************************************************** 
; RESULTADO (Usa el registro R23)
;****************************************************************** 

BUT5:
CALL Delayy
MOV R23, R21 ; Copia el valor de R21 en R23
ADD R23, R22 ; Suma lo que hay en R22 a R23 
OUT PORTD, R23
RJMP LOOP
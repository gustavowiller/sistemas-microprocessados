;****************************************************************************************************
; PRATICA2.ASM
; Prof. Maurílio J. Inácio
; Engenharia de Sistemas
; Unimontes / 2016
;
;****************************************************************************************************
;
;Digito mais			   Digito menos
;					    significativo		   significativo
;						  ---a1---  			 ---a2---  
;						 |        |				|        |	
;						 f1       b1			f2       b2
;						 |        |				|        |
;						  ---g1--- 				 ---g2--- 
;						 |        |				|        |
;						 e1       c1			e2       c2
;						 |        |				|        |
;						  ---d1---  .p1			 ---d2---  .p2
;---------------------------------------------------------------------------------------------------
; Configuração do microcontrolador
;---------------------------------------------------------------------------------------------------
	list p=18F4550 ; define o modelo do microcontrolador
	#include <p18f4550.inc> ; inclui um arquivo adicional
	CONFIG WDT=OFF ; desabilita o Watchdog Timer
	CONFIG MCLRE = ON ; define o estado do pino MCLEAR
	CONFIG DEBUG = ON ; habilita o Debug Mode
	CONFIG LVP = OFF ; desabilita o modo Low-Voltage Programming
	CONFIG FOSC = HS ; define o oscilador externo tipo HS
;---------------------------------------------------------------------------------------------------
; Definição de rótulos
;---------------------------------------------------------------------------------------------------
	#define LED PORTD,1 ; rótulo para o Led3
	#define BUZZER PORTC,1
	#define BTN_BOOT PORTB,4 ; rótulo para o botão Boot
	#define BTN_ONE PORTE,1 ; rótulo para o botão 1
	#define BTN_TWO PORTE,2 ; rótulo para o botão 1
	#define RELE PORTC,0; 
	#define KEY_1 PORTA,1; chave porta 1
	#define KEY_2 PORTA,2; chave porta 2	
	#define KEY_3 PORTA,3; chave porta 3
	#define KEY_4 PORTA,4; chave porta 4
	DAT DB 0x00
	#define SEGMENT_A1 PORTD,5;
	#define SEGMENT_B1 PORTD,4;
	#define SEGMENT_C1 PORTB,5;
	#define SEGMENT_D1 PORTB,6;
	#define SEGMENT_E1 PORTB,7;
	#define SEGMENT_F1 PORTD,7;
	#define SEGMENT_G1 PORTD,6;
	#define SEGMENT_A2 PORTC,6;
	#define SEGMENT_B2 PORTD,2;
	#define SEGMENT_C2 PORTB,0;
	#define SEGMENT_D2 PORTB,2;
	#define SEGMENT_E2 PORTB,3;
	#define SEGMENT_F2 PORTC,7;
	#define SEGMENT_G2 PORTB,1;
	
;---------------------------------------------------------------------------------------------------
; Rotina principal
;---------------------------------------------------------------------------------------------------
	org 0x1000 ; endereço inicial do programa
	clrf PORTB ; limpa a porta B
	clrf PORTD ; limpa a porta D
	clrf PORTE ; limpa a porta E
	clrf PORTC ; limpa a porta C
	clrf PORTA ; limpa a porta A

	movlw b'1111111'; %Configura como porta de entrada
	movwf TRISA

	movlw b'00001111'; %desabilita funçã analogica
	movwf ADCON1

	movlw b'0110'; %Configura como porta de entrada
	movwf TRISE

	movlw b'00000000' ; configura os pinos da porta B
	movwf TRISB
	
	movlw b'00000000' ; configura os pinos da porta D
	movwf TRISD
	
	movlw b'0000000'
	movwf TRISC

	
	

LOOP
	;Zerar as outras entradas
	movf PORTA,w
	movwf DAT
	movlw b'00011110'
	andwf DAT,f

	call CLEAR_DISPLAY;
 
	movlw b'00011110'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_0

	movlw b'00001110'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_1

	movlw b'00010110'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_2


	movlw b'00000110'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_3


	movlw b'00011010'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_4

	movlw b'00001010'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_5

	movlw b'00010010'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_6

	movlw b'00000010'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_7

	movlw b'00011100'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_8

	movlw b'00001100'
	subwf DAT,w
	btfsc STATUS,2
	call DISPLAY_9


	goto LOOP

CLEAR_DISPLAY
	
	bsf SEGMENT_A1
	bsf SEGMENT_B1
	bsf SEGMENT_C1
	bsf SEGMENT_D1
	bsf SEGMENT_E1
	bsf SEGMENT_F1
	bsf SEGMENT_G1


	RETURN

DISPLAY_0	

	bcf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_C2
	bcf SEGMENT_D2
	bcf SEGMENT_E2
	bcf SEGMENT_F2

	bsf SEGMENT_G2
	
	RETURN

DISPLAY_1

	bcf SEGMENT_B2
	bcf SEGMENT_C2

	bsf SEGMENT_A2
	bsf SEGMENT_D2
	bsf SEGMENT_E2
	bsf SEGMENT_F2
	bsf SEGMENT_G2
	
	RETURN;

DISPLAY_2

	bcf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_D2
	bcf SEGMENT_E2
	bcf SEGMENT_G2

	bsf SEGMENT_C2
	bsf SEGMENT_F2
	
	RETURN;

DISPLAY_3
	bcf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_C2
	bcf SEGMENT_D2
	bsf SEGMENT_E2
	bsf SEGMENT_F2
	bcf SEGMENT_G2
	RETURN;


DISPLAY_4
	bsf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_C2
	bsf SEGMENT_D2
	bsf SEGMENT_E2
	bcf SEGMENT_F2
	bcf SEGMENT_G2
	RETURN;


DISPLAY_5
	bcf SEGMENT_A2
	bsf SEGMENT_B2
	bcf SEGMENT_C2
	bcf SEGMENT_D2
	bsf SEGMENT_E2
	bcf SEGMENT_F2
	bcf SEGMENT_G2
	RETURN;

DISPLAY_6
	bcf SEGMENT_A2
	bsf SEGMENT_B2
	bcf SEGMENT_C2
	bcf SEGMENT_D2
	bcf SEGMENT_E2
	bcf SEGMENT_F2
	bcf SEGMENT_G2
	RETURN;


DISPLAY_7
	bcf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_C2
	bsf SEGMENT_D2
	bsf SEGMENT_E2
	bsf SEGMENT_F2
	bsf SEGMENT_G2
	RETURN;


DISPLAY_8
	bcf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_C2
	bcf SEGMENT_D2
	bcf SEGMENT_E2
	bcf SEGMENT_F2
	bcf SEGMENT_G2
	RETURN;


DISPLAY_9
	bcf SEGMENT_A2
	bcf SEGMENT_B2
	bcf SEGMENT_C2
	bcf SEGMENT_D2
	bsf SEGMENT_E2
	bcf SEGMENT_F2
	bcf SEGMENT_G2
	RETURN;


	end
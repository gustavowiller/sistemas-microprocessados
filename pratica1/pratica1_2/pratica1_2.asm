;****************************************************************************************************
; PRATICA1.ASM
; Prof. Maurílio J. Inácio
; Engenharia de Sistemas
; Unimontes / 2016
;
;****************************************************************************************************
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
	#define BTN_UM PORTE,1 ; rótulo para o botão 1
	#define BTN_DOIS PORTE,2 ; rótulo para o botão 1
	#define RELE PORTC,0; 
;---------------------------------------------------------------------------------------------------
; Rotina principal
;---------------------------------------------------------------------------------------------------
	org 0x1000 ; endereço inicial do programa
	clrf PORTB ; limpa a porta B
	clrf PORTD ; limpa a porta D
	clrf PORTE ; limpa a porta E
	clrf PORTC ; limpa a porta C
	clrf PORTA ; limpa a porta A

	movlw b'00001111'; %Configura como porta de entrada
	movwf ADCON1

	movlw b'0110'; %Configura como porta de entrada
	movwf TRISE


	movlw b'11111111' ; configura os pinos da porta B
	movwf TRISB
	
	movlw b'00000000' ; configura os pinos da porta D
	movwf TRISD
	
	movlw b'0000000'
	movwf TRISC
	

LOOP_LED
	btfsc BTN_BOOT ; verifica o botão
	goto DESLIGA_LED ; desvia se o botão não estiver pressionado
	goto LIGA_LED ; desvia se o botão estiver pressionado
DESLIGA_LED
	bcf LED ; desliga o led
	goto LOOP_BUZZER
LIGA_LED
	bsf LED ; liga o led
	goto LOOP_BUZZER

LOOP_BUZZER
	btfsc BTN_UM ; verifica o botão
	goto LIGA_BUZZER ; desvia se o botão estiver pressionado
	goto DESLIGA_BUZZER ; desvia se o botão não estiver pressionado
DESLIGA_BUZZER
	bcf BUZZER ; desliga o led
	goto LOOP_RELE
LIGA_BUZZER
	bsf BUZZER ; liga o led
	goto LOOP_RELE

LOOP_RELE
	btfsc BTN_DOIS ; verifica o botão
	goto LIGA_RELE ; desvia se o botão estiver pressionado
	goto DESLIGA_RELE ; desvia se o botão não estiver pressionado
DESLIGA_RELE
	bcf RELE ; desliga o led
	goto LOOP_LED
LIGA_RELE
	bsf RELE ; liga o led
	goto LOOP_LED
	end
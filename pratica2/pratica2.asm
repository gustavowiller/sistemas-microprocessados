;****************************************************************************************************
; PRATICA2.ASM
; Prof. Maurílio J. Inácio
; Engenharia de Sistemas
; Unimontes / 2016
; Gustavo Willer / Diego Maia
;****************************************************************************************************
;---------------------------------------------------------------------------------------------------; Configuração do microcontrolador
;---------------------------------------------------------------------------------------------------

		list p=18F4550 ; define o modelo do microcontrolador
		#include <p18f4550.inc> ; inclui um arquivo adicional
		CONFIG WDT=OFF ; desabilita o Watchdog Timer
		CONFIG MCLRE = ON ; define o estado do pino MCLEAR
		CONFIG DEBUG = ON ; habilita o Debug Mode
		CONFIG LVP = OFF ; desabilita o modo Low-Voltage Programming
		CONFIG FOSC = HS ; define o oscilador externo tipo HS

;---------------------------------------------------------------------------------------------------; Definição de rótulos
;---------------------------------------------------------------------------------------------------

		#define BUZZER PORTC,1 ; rótulo para o Buzzer
		#define BOTAO1 PORTE,1 ; rótulo para o botão 1
		#define BOTAO2 PORTE,2 ; rótulo para o botão 2
		DIGIT_R DB 0x00				; definição de bytes para o display do lado direito
		DIGIT_L DB 0x00				; definição de bytes para o display do lado direito
		TRAVA_BOTAO DB 0x00			; definição de bytes para uma flag trava botão
		TEMPORIZADOR DB 0x00			; definição de bytes para temporizador
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
;---------------------------------------------------------------------------------------------------; Declaração de variáveis
;---------------------------------------------------------------------------------------------------
		delay_val db 0x00 ; variável auxiliar
		delay_x50 db 0x00 ; variável auxiliar
		delay_x200 db 0x00 ; variável auxiliar
;---------------------------------------------------------------------------------------------------; Rotina principal
;---------------------------------------------------------------------------------------------------

		org 0x1000 ; endereço inicial do programa
		
		clrf PORTB ; limpa a porta B
		clrf PORTD ; limpa a porta D
		clrf PORTE ; limpa a porta E
		clrf PORTC ; limpa a porta C

		movlw b'00000000' ; configura os pinos da porta B
		movwf TRISB
		movlw b'00000000' ; configura os pinos da porta C
		movwf TRISC
		movlw b'00000000' ; configura os pinos da porta D
		movwf TRISD
		movlw b'11111111' ; configura os pinos da porta E
		movwf TRISE
		movlw b'00001111' ; desativa as entradas analógicas
		movwf ADCON1

		movlw b'00000000'
		movwf DIGIT_R;
		movlw b'00000000'
		movwf DIGIT_L;
		movlw b'00000000'
		movwf TRAVA_BOTAO;
		movlw b'00000000'
		movwf TEMPORIZADOR;


INICIO
	
		movlw 10; carrega W com o delay desejado (0,5s)
		call DELAY ; chama a sub-rotina DELAY
		
		call MOSTRA_DISPLAY		

		;Botao Reset	
		btfsc BOTAO2 ;
		goto RESETAR_CONTADOR ;
		
		btfsc BOTAO1 ; verifica se botão1 está pressionado
		goto INICIA_CONTADOR ; desvia para INICIO se não estiver pressionado
		goto INICIO

INICIA_CONTADOR
		btfss BOTAO1	
		goto CONTADOR ; desvia para o início do programa
		goto INICIA_CONTADOR;

CONTADOR
		
		movlw 10; carrega W com o delay desejado (0,5s)
		call DELAY ; chama a sub-rotina DELAY
		

		btfsc BOTAO1 ; verifica se botão1 está pressionado
		goto PARAR_CONTADOR ; desvia para PARAR_CONTADOR se  estiver pressionado


		movlw b'00000001'
		addwf TEMPORIZADOR;
	
		movlw b'00001111'			
		subwf TEMPORIZADOR,w
		btfsc STATUS,2
		goto CONTADOR_UNIDADE
		goto CONTADOR

CONTADOR_UNIDADE

		movlw b'00000000'
		movwf TEMPORIZADOR;

		movlw b'00000001'
		addwf DIGIT_R;

		movlw b'00001010'			
		subwf DIGIT_R,w
		btfsc STATUS,2
		call CONTADOR_DEZENA

		;Zerar dezena
		movlw b'00000110'			
		subwf DIGIT_L,w
		btfsc STATUS,2
		call ZERAR	
		

		call MOSTRA_DISPLAY
		
		goto CONTADOR

CONTADOR_DEZENA
		movlw b'00000000'
		movwf DIGIT_R;
		movlw b'00000001'       
		addwf DIGIT_L;
		return

PARAR_CONTADOR

		bsf BUZZER ; liga o buzzer
		movlw 5 ; carrega W com o delay desejado (2s)
		call DELAY ; chama a sub-rotina DELAY
		bcf BUZZER ; desliga o buzzer
	
PARAR_CONTADOR2
		btfss BOTAO1	
		goto INICIO ; desvia para o início do programa
		goto PARAR_CONTADOR2

RESETAR_CONTADOR
		call ZERAR
		bsf BUZZER ; liga o buzzer
		movlw 0xC8 ; carrega W com o delay desejado (2s)
		call DELAY ; chama a sub-rotina DELAY
		bcf BUZZER ; desliga o buzzer
		goto INICIO ; desvia para o início do programa
	
ZERAR
		movlw b'00000000'
		movwf DIGIT_R;
		movlw b'00000000'
		movwf DIGIT_L;
		return;

DESTRAVA_BOTAO
		movlw b'00000000'
		movwf TRAVA_BOTAO;
		return

;---------------------------------------------------------------------------------------------------;
; Sub-rotina DELAY
; Gera um delay entre 10ms e 2,55s aproximadamente
; O valor do delay é passado pelo registrador W (1 a 255)
; A base de tempo da sub-rotina é 0,2 us (período do clock de 20MHz/4)
;---------------------------------------------------------------------------------------------------

DELAY
		movwf delay_val  ; carrega o valor do delay desejado
Del_10ms  ; delay de 10 mS
		movlw 0x32  ; fator de multiplicação por 50
		movwf delay_x50  ; variável auxiliar
Del_200us   ; delay de 200 us
		movlw 0xC8  ; fator de multiplicação por 200
		movwf delay_x200  ; variável auxiliar
Loop   ; início do loop
		nop  ; não faz nada
		nop ; não faz nada
		decfsz delay_x200,f  ; decrementa delay_x200 e desvia se for 0
		goto Loop ; se não for zero, desvia para Loop
		decfsz delay_x50,f  ; decrementa delay_x50 e desvia se for 0
		goto Del_200us  ; se não for zero, desvia para Del_200us
		decfsz delay_val,f  ; decrementa delay_val e desvia se for 0
		goto Del_10ms  ; se não for zero, desvia para Del_10ms
	

		return ; retorno da sub-rotina
	
MOSTRA_DISPLAY

; DISPLAY RIGTH
	movlw b'00000000'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_0

	movlw b'00000001'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_1


	movlw b'00000010'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_2

	movlw b'00000011'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_3
	
	movlw b'00000100'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_4


	movlw b'00000101'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_5

	movlw b'00000110'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_6

	movlw b'00000111'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_7


	movlw b'00001000'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_8

	movlw b'00001001'
	subwf DIGIT_R,w
	btfsc STATUS,2
	call DISPLAY_9


; DISPLAY LEFT
	movlw b'00000000'
	subwf DIGIT_L,w
	btfsc STATUS,2
	call DISPLAY_0L

	movlw b'00000001'
	subwf DIGIT_L,w
	btfsc STATUS,2
	call DISPLAY_1L

	movlw b'00000010'
	subwf DIGIT_L,w
	btfsc STATUS,2
	call DISPLAY_2L

	movlw b'00000011'
	subwf DIGIT_L,w
	btfsc STATUS,2
	call DISPLAY_3L
	
	movlw b'00000100'
	subwf DIGIT_L,w
	btfsc STATUS,2
	call DISPLAY_4L

	movlw b'00000101'
	subwf DIGIT_L,w
	btfsc STATUS,2
	call DISPLAY_5L

	return;	


;Mostra os numeros do display de 7 segmentos. 
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


DISPLAY_0L	

	bcf SEGMENT_A1
	bcf SEGMENT_B1
	bcf SEGMENT_C1
	bcf SEGMENT_D1
	bcf SEGMENT_E1
	bcf SEGMENT_F1

	bsf SEGMENT_G1
	
	RETURN

DISPLAY_1L

	bcf SEGMENT_B1
	bcf SEGMENT_C1

	bsf SEGMENT_A1
	bsf SEGMENT_D1
	bsf SEGMENT_E1
	bsf SEGMENT_F1
	bsf SEGMENT_G1
	
	RETURN;

DISPLAY_2L

	bcf SEGMENT_A1
	bcf SEGMENT_B1
	bcf SEGMENT_D1
	bcf SEGMENT_E1
	bcf SEGMENT_G1

	bsf SEGMENT_C1
	bsf SEGMENT_F1
	
	RETURN;

DISPLAY_3L
	bcf SEGMENT_A1
	bcf SEGMENT_B1
	bcf SEGMENT_C1
	bcf SEGMENT_D1
	bsf SEGMENT_E1
	bsf SEGMENT_F1
	bcf SEGMENT_G1
	RETURN;


DISPLAY_4L
	bsf SEGMENT_A1
	bcf SEGMENT_B1
	bcf SEGMENT_C1
	bsf SEGMENT_D1
	bsf SEGMENT_E1
	bcf SEGMENT_F1
	bcf SEGMENT_G1
	RETURN;


DISPLAY_5L
	bcf SEGMENT_A1
	bsf SEGMENT_B1
	bcf SEGMENT_C1
	bcf SEGMENT_D1
	bsf SEGMENT_E1
	bcf SEGMENT_F1
	bcf SEGMENT_G1
	RETURN;

	end

//--------------------------------------------------------------------------------
// Arquivos de cabe�alho
//--------------------------------------------------------------------------------
#include <p18cxxx.h> // inclui um arquivo cabe�alho ref. ao microcontrolador
#include "my_xlcd.h" // inclui um arquivo cabe�alho ref. ao display LCD
#include <timers.h> // inclui um arquivo cabe�alho ref. aos m�dulos TIMERs
#include <stdio.h> // inclui um arquivo cabe�alho ref. as fun��es de I/O
//#include<conio.h>

//--------------------------------------------------------------------------------
// Configura��o do microcontrolador
//--------------------------------------------------------------------------------
#pragma config WDT = OFF // desabilita o Watchdog Timer
#pragma config MCLRE = ON // define o estado do pino MCLEAR
#pragma config DEBUG = ON // habilita o Debug Mode
#pragma config LVP = OFF // desabilita o modo Low-Voltage Programming
#pragma config FOSC = INTOSC_HS// define o oscilador interno (48MHz)
#pragma config XINST = OFF // desabilita o Extended CPU Mode

//--------------------------------------------------------------------------------
// Defini��o de r�tulos
//--------------------------------------------------------------------------------
#define LEDVERMELHO PORTDbits.RD1 // pino do Led Vermelho
#define BOTAO1 PORTEbits.RE1 // pino do BOTAO 1
#define BOTAO2 PORTEbits.RE2 // pino do Led Vermelho
#define INICIO_TMR0 (65536 - 59536) // valor inicial do Timer0

//--------------------------------------------------------------------------------
// Vari�veis globais
//--------------------------------------------------------------------------------
int mil = 0;
int seg= 0;
int min= 0;

// Rotina de tratamento das interrup��es de alta prioridade
#pragma interrupt Tratamento_High_Interrupt
void Tratamento_High_Interrupt(void)
{
	// Verifica se � interrup��o do Timer0
	if(INTCONbits.TMR0IE && INTCONbits.TMR0IF)
		{
		mil = mil + 1; // incrimenta vari�vel
		if(mil >= 100) // verifica limite
		{
			mil = 0;
			seg=seg+1;
			
			if(seg >= 60) // verifica limite
			{
				seg=0;
				min=min+1;
				if(min == 60) // verifica limite
					{
						min=0;
					}

			}

		}

		
		WriteTimer0(INICIO_TMR0); // carrega o Timer0
		INTCONbits.TMR0IF = 0; // zera o flag do timer0
		}
	}
	// Rotina de tratamento das interrup��es de baixa prioridade
	#pragma interruptlow Tratamento_Low_Interrupt
	void Tratamento_Low_Interrupt(void)
	{
	// c�digo de tratamento da interrup��o de baixa prioridade
}

//********************************************************************************
// VECTOR REMAPPING
//********************************************************************************

// Rotina necess�ria para todo projeto que utilize o BOOTLOADER no PIC.
extern void _startup (void);
#pragma code REMAPPED_RESET_VECTOR = 0x001000
void _reset (void)
{
	_asm goto _startup _endasm
}

// Rotina necess�ria para de tratamento das interrup��es de ALTA prioridade
#pragma code REMAPPED_HIGH_INTERRUPT_VECTOR = 0x001008
void _high_ISR (void)

{
	_asm goto Tratamento_High_Interrupt _endasm
}

// Rotina necess�ria para de tratamento das interrup��es de BAIXA prioridade
#pragma code REMAPPED_LOW_INTERRUPT_VECTOR = 0x001018
void _low_ISR (void)
{
	_asm goto Tratamento_Low_Interrupt _endasm
}

#pragma code
//--------------------------------------------------------------------------------
// Fun��o principal
//--------------------------------------------------------------------------------
void main(void)
{
	char str[25]; // string
	int flag=0;

	// Configura��o das portas
	TRISD = 0x00; // configura todos pinos da porta D como sa�da
	ADCON1 |= 0x0F; // desabilita as entradas anal�gicas
	
	// Configura porta E como entrada
	TRISE = 0xFF;
	
	// Configura��o dos pinos que s�o usados pelo LCD
	OpenXLCD();
	
	// Desativa o Led Vermelho
	LEDVERMELHO = 0;
	

	// Configura��o da interrup��o
	RCONbits.IPEN = 1; // habilita prioridade de interrup��o
	INTCONbits.GIE = 1; // habilita TODAS as interrup��es
	INTCONbits.TMR0IF = 0; // zera o flag do Timer0
	INTCON2bits.TMR0IP = 1; // define alta prioridade
	// Carrega o Timer0
	WriteTimer0(INICIO_TMR0);
	// Configura��o e habilita��o do Timer0
	OpenTimer0(TIMER_INT_ON & T0_16BIT & T0_SOURCE_INT & T0_PS_1_2);   // PS_1_256 pq = 1/12MHz * 2 * 6000(diferen�a na linha 24) valo obtido por testes
	// Loop infinito
	for(;;)
	{
		// Exbibe vari�veis
		
		if(BOTAO2){
			min=seg=mil=0;
			flag=1;
			OpenTimer0(TIMER_INT_OFF & T0_16BIT & T0_SOURCE_INT & T0_PS_1_2);   // PS_1_256 pq = 1/12MHz * 2 * 6000(diferen�a na linha 24) valo obtido por testes
		}
	
		if(BOTAO1){ // Inverte o status do contador, com o clique do bot�o.
			if(flag){
				flag = 0;
				OpenTimer0(TIMER_INT_ON & T0_16BIT & T0_SOURCE_INT & T0_PS_1_2);   // PS_1_256 pq = 1/12MHz * 2 * 6000(diferen�a na linha 24) valo obtido por testes
			}else{
				flag=1;
				OpenTimer0(TIMER_INT_OFF & T0_16BIT & T0_SOURCE_INT & T0_PS_1_2);   // PS_1_256 pq = 1/12MHz * 2 * 6000(diferen�a na linha 24) valo obtido por testes
			}
		}


			
		sprintf (str, "%2d:%2d.%2d ", min,seg,mil);
		SetDDRamAddr(0x00);
		putsXLCD(str);
	}

}


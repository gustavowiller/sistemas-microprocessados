//--------------------------------------------------------------------------------
// Arquivos de cabeçalho
//--------------------------------------------------------------------------------
#include <p18cxxx.h> // inclui um arquivo cabeçalho ref. ao microcontrolador
#include "my_xlcd.h" // inclui um arquivo cabeçalho ref. ao display LCD
#include <timers.h> // inclui um arquivo cabeçalho ref. aos módulos TIMERs
#include <stdio.h> // inclui um arquivo cabeçalho ref. as funções de I/O

//--------------------------------------------------------------------------------
// Configuração do microcontrolador
//--------------------------------------------------------------------------------
#pragma config WDT = OFF // desabilita o Watchdog Timer
#pragma config MCLRE = ON // define o estado do pino MCLEAR
#pragma config DEBUG = ON // habilita o Debug Mode
#pragma config LVP = OFF // desabilita o modo Low-Voltage Programming
#pragma config FOSC = INTOSC_HS// define o oscilador interno (48MHz)
#pragma config XINST = OFF // desabilita o Extended CPU Mode

//--------------------------------------------------------------------------------
// Definição de rótulos
//--------------------------------------------------------------------------------
#define LEDVERMELHO PORTDbits.RD1 // pino do Led Vermelho
#define INICIO_TMR0 (65536 - 46875) // valor inicial do Timer0

//--------------------------------------------------------------------------------
// Variáveis globais
//--------------------------------------------------------------------------------
int cont = 0;

// Rotina de tratamento das interrupções de alta prioridade
#pragma interrupt Tratamento_High_Interrupt
void Tratamento_High_Interrupt(void)
{
	// Verifica se é interrupção do Timer0
	if(INTCONbits.TMR0IE && INTCONbits.TMR0IF)
		{
		LEDVERMELHO = ~LEDVERMELHO; // inverte estado do Led Vermelho
		cont = cont + 1; // incrimenta variável
		if(cont == 1000) // verifica limite
		{
			cont = 0;
		}
		WriteTimer0(INICIO_TMR0); // carrega o Timer0
		INTCONbits.TMR0IF = 0; // zera o flag do timer0
		}
	}
	// Rotina de tratamento das interrupções de baixa prioridade
	#pragma interruptlow Tratamento_Low_Interrupt
	void Tratamento_Low_Interrupt(void)
	{
	// código de tratamento da interrupção de baixa prioridade
}

//********************************************************************************
// VECTOR REMAPPING
//********************************************************************************

// Rotina necessária para todo projeto que utilize o BOOTLOADER no PIC.
extern void _startup (void);
#pragma code REMAPPED_RESET_VECTOR = 0x001000
void _reset (void)
{
	_asm goto _startup _endasm
}

// Rotina necessária para de tratamento das interrupções de ALTA prioridade
#pragma code REMAPPED_HIGH_INTERRUPT_VECTOR = 0x001008
void _high_ISR (void)

{
	_asm goto Tratamento_High_Interrupt _endasm
}

// Rotina necessária para de tratamento das interrupções de BAIXA prioridade
#pragma code REMAPPED_LOW_INTERRUPT_VECTOR = 0x001018
void _low_ISR (void)
{
	_asm goto Tratamento_Low_Interrupt _endasm
}

#pragma code
//--------------------------------------------------------------------------------
// Função principal
//--------------------------------------------------------------------------------
void main(void)
{
	char str[17]; // string
	
	// Configuração das portas
	TRISD = 0x00; // configura todos pinos da porta D como saída
	ADCON1 |= 0x0F; // desabilita as entradas analógicas
	
	// Configuração dos pinos que são usados pelo LCD
	OpenXLCD();
	
	// Desativa o Led Vermelho
	LEDVERMELHO = 0;

	// Configuração da interrupção
	RCONbits.IPEN = 1; // habilita prioridade de interrupção
	INTCONbits.GIE = 1; // habilita TODAS as interrupções
	INTCONbits.TMR0IF = 0; // zera o flag do Timer0
	INTCON2bits.TMR0IP = 1; // define alta prioridade
	// Carrega o Timer0
	WriteTimer0(INICIO_TMR0);
	// Configuração e habilitação do Timer0
	OpenTimer0(TIMER_INT_ON & T0_16BIT & T0_SOURCE_INT & T0_PS_1_128);
	// Loop infinito
	for(;;)
	{
		// Exbibe variáveis
		sprintf (str, "CONT = %3d ", cont);
		SetDDRamAddr(0x00);
		putsXLCD(str);
	}
}
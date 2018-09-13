//--------------------------------------------------------------------------------
// Arquivos de cabeçalho
//--------------------------------------------------------------------------------
#include <p18cxxx.h> // inclui um arquivo cabeçalho ref. ao microcontrolador
#include <stdio.h> // inclui um arquivo cabeçalho ref. às funções de string
#include <adc.h> // inclui um arquivo cabeçalho ref. ao conversor AD
#include "my_xlcd.h" // inclui um arquivo cabeçalho ref. ao display LCD
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
#define VDD 5
#define resolucao VDD/1023.0
#define RELE PORTCbits.RC0 // pino do Led Vermelho
//--------------------------------------------------------------------------------
// Variáveis globais
//--------------------------------------------------------------------------------
//********************************************************************************
// VECTOR REMAPPING
//********************************************************************************
// Rotina necessária para todo projeto que utilize o BOOTLOADER no PIC.
extern void _startup (void);
#pragma code REMAPPED_RESET_VECTOR = 0x001000
void _reset (void){
	_asm goto _startup _endasm
}
#pragma code
//--------------------------------------------------------------------------------
// Função principal
//--------------------------------------------------------------------------------
main(void){


	// Declaração de variáveis
	char str[17];
	int i, valorDigital;
	float valorAnalog;
	float Xf = 0;
	
	// Configuração das portas
	TRISA = 0xFF; // configura todos pinos da porta A como entrada
	TRISD = 0x00; // configura todos pinos da porta D como saída
	TRISE = 0xFF; // configura todos pinos da porta E como entrada
	TRISC = 0x00; // pino de saída 

	
	//Configuração do conversor AD
	OpenADC(
	ADC_FOSC_64 & // define a fonte de clock para o conversor A/D
	ADC_RIGHT_JUST & // define o modo de justificação
	ADC_2_TAD, // define o tempo de aquisição
	ADC_CH0 & // define o canal analógico
	ADC_INT_OFF & // desabilita a interrupção do conversor A/D
	ADC_REF_VDD_VSS, // define a fonte de tensão de referência
	ADC_8ANA ); // define a configuração dos canais analógicos
	OpenXLCD(); // inicializa o LCD
	// Exibe mensagem inicial
	SetDDRamAddr(0x00);
	putrsXLCD("Medindo Temp");
	SetDDRamAddr(0x40);
	putrsXLCD(" Ambiente ");
	// Aguarda ~ 1s
	for(i = 0; i < 10; i++){
		Delay10KTCYx(120);
	}
	// Apaga mensagem inicial
	SetDDRamAddr(0x00);
	putrsXLCD(" ");
	SetDDRamAddr(0x40);
	putrsXLCD(" ");
	for(;;){// Leitura da tensão no potenciômetro
		valorDigital= 0;
		for(i = 0; i < 10; i++){
			ConvertADC(); // inicia o processo de conversão
			while(BusyADC()); // aguarda o término da conversão
			valorDigital = valorDigital + ReadADC(); // lê o valor convertido
			Delay100TCYx(12); // aguarda ~ 100us
		}
		
		valorDigital = valorDigital / 10; // média do valor convertido
		valorAnalog = valorDigital * resolucao; // valor convertido para tensão
		

		// Exibição dos valores no display LCD
		Xf = (valorAnalog*1000 - 500)/10;
		sprintf(str, "Analog. = %d.%dV",(int)valorAnalog,(int)(valorAnalog*10)%10);
		SetDDRamAddr(0x00);
		putsXLCD(str);

		RELE = (Xf > 31) ? 1 : 0;

		sprintf(str, "Temp. = %d.%doC",(int)Xf,(int)(Xf*10)%10);
		SetDDRamAddr(0x40);
		putsXLCD(str);
	}//end for
}//end main

//--------------------------------------------------------------------------------
// Arquivos de cabeçalho
//--------------------------------------------------------------------------------
#include <p18cxxx.h> // inclui um arquivo cabeçalho ref. ao microcontrolador
#include "my_xlcd.h" // inclui um arquivo cabeçalho ref. ao display LCD
#include <delays.h> 
#include <stdio.h>

#define PORT_7_SEGMENT PORTB
//--------------------------------------------------------------------------------
// Configuração do microcontrolador
//--------------------------------------------------------------------------------
#pragma config WDT=OFF // desabilita o Watchdog Timer
#pragma config MCLRE = ON // define o estado do pino MCLEAR
#pragma config DEBUG = ON // habilita o Debug Mode
#pragma config LVP = OFF // desabilita o modo Low-Voltage Programming
#pragma config FOSC = HS // define o oscilador externo tipo HS

//********************************************************************************
// VECTOR REMAPPING
//********************************************************************************
// Rotina necessária para todo projeto que utilize o bootloader no PIC.
extern void _startup (void);
#pragma code REMAPPED_RESET_VECTOR = 0x001000
void _reset (void)
{
	_asm goto _startup _endasm
}
#pragma code

//--------------------------------------------------------------------------------
// Definição de rótulos
//--------------------------------------------------------------------------------
#define BOOT PORTBbits.RB4
#define BOTAO1 PORTEbits.RE1
#define BOTAO2 PORTEbits.RE2
#define LEDVERDE PORTCbits.RC2
#define BUZZER PORTCbits.RC1
#define RELE PORTCbits.RC0


//--------------------------------------------------------------------------------
// Função principal
//--------------------------------------------------------------------------------

 void PutFloatXLCD (float f)
 {
  char buf[16];
  float frac_float;
  long frac_long;
  float work_str;
  long num;
  num = f;
  frac_float = modf(f,&work_str);
  frac_long = frac_float * 100000;
  ltoa(num, buf);
  putsXLCD(buf);
  putrsXLCD(".");   // possible source of the problem
  ltoa(frac_long, buf);
  putsXLCD(buf);
 }



void main(void)
{

	int  i = 0;
	int t = 0; 
	char s[20];

  	char buf[16];
 	char buf2[16];

	
	// Configuração das portas
	TRISB = 0xFF; // configura todos pinos da porta B como entrada
	TRISC = 0x00; // configura todos pinos da porta C como saída
	ADCON1 |= 0x0F; // desabilita as entradas analógicas
	// Configuração dos pinos que são usados pelo LCD
	OpenXLCD();
	// Desativa os dispositivos
	LEDVERDE = 0;
	BUZZER = 0;
	RELE = 0;
	// Seleciona a linha 1 do display LCD
	SetDDRamAddr(0x00);
	// Escreve a string no display LCD
	// Seleciona a linha 2 do display LCD
	SetDDRamAddr(0x40);
	// Escreve a string no display LCD
	// Loop

	//Aqui uma função que escolhe o tempo para para
	i = 0;

	putrsXLCD("Pressione botao2"); 
	
	while(1){
		if(BOTAO1==1){
			if(i==0)
				continue;
			break;
					}

		if (BOTAO2 == 1){
			i = i + 1;
			if(i>=6)
				i = 1; 

			SetDDRamAddr(0x00);
			putrsXLCD("            ");
		  	SetDDRamAddr(0x00);	
	
			switch(i){
				case 1: 
					t = 1;
					putrsXLCD("1 minuto"); 
					break;
				case 2: t = 5;
					putrsXLCD("5 minutos"); 
					break;
				case 3: t = 10;
					putrsXLCD("10 minutos"); 
					break;
				case 4: t = 20;
					putrsXLCD("20 minutos"); 
					break;
				case 5: t = 30;
					putrsXLCD("30 minutos"); 
					break;
		
					}
		}

		}


	i = t*60;

	while(1)
	{
		Delay10KTCYx(255); // wait 1/2 second
		Delay10KTCYx(255); // wait 1/2 second
		Delay10KTCYx(255); // wait 1/2 second
		Delay10KTCYx(10); // wait 1/2 second
	
		SetDDRamAddr(0x00);
		putrsXLCD("            ");
		SetDDRamAddr(0x00);
		putsXLCD(ltoa(i, buf));
		i = i - 1;		

	if(i==0){///Executa a acao
			SetDDRamAddr(0x00);
			putrsXLCD("LED VERDE ");
			SetDDRamAddr(0x40);
			putrsXLCD("ATIVADO ");
			LEDVERDE = !LEDVERDE;
		
			while(1){ // Iniciar novamente
				if(BOTAO1 == 1 || BOTAO2 == 1)
					break;
			}
			break;
	}

	
	if (BOTAO2 == 1) //cANCELAR A QUALQUE MONMENTO
		break;
	
	}

}




	

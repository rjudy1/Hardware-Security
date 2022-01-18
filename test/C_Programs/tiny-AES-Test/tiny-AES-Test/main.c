#include <xc.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/pgmspace.h>

#define F_CPU 8000000 //telling controller crystal frequency attached

#define ECB 1				//Enable ECB mode
#include "aes.h"

uint8_t uart_putc(uint8_t cc)	{
	while ((UCSRA & (1 << UDRE)) == 0);
	UDR = cc;
	return 1;
}

uint8_t uart_putcHex(uint8_t cc) {
	char hex[] = "0123456789ABCDEF";
	char firstChar  = hex[cc / 16];
	char secondChar = hex[cc % 16];
	while ((UCSRA & (1 << UDRE)) == 0);
	UDR = firstChar;
	while ((UCSRA & (1 << UDRE)) == 0);
	UDR = secondChar;
	return 1;
}


uint16_t uart_puts(const char * s)	{
	const char * from = s;
	uint8_t cc;
	while (cc = pgm_read_byte(s++))
	{
		uart_putc(cc);
	}
	return s - from - 1;
}

initializeIO(){
	DDRB = 0b11111111; //seven seg
	DDRC = 0b11110000; //seven seg select
	DDRD = 0b00000000; // button inputs
	
	int UBBRValue = 51;		//Set baud rate to 9600 (8 MHz) 
	UBRRH = (unsigned char) (UBBRValue >> 8);		//Upper bits (11 to 8) of UBBRValue
	UBRRL = (unsigned char) UBBRValue;				//Lower bits (7 to 0) of UBBRValue
	UCSRB = (1 << RXEN) | (1 << TXEN);				//Enable receiver and transmitter
	UCSRC = (1<<URSEL) | (1 << USBS) | (3 << UCSZ0);	//2 Stop bits, 8-bit data length
	return 0;
}

int main(void)
{
	uint8_t key[] = {'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y'};
	uint8_t input[] = {'h','e','l','l','o', ',' , ' ', 'w','o','r','l','d','0','0','0','0'};
	
	initializeIO();
	uart_puts(PSTR("\r\nProgram start\r\n"));
	uart_puts(PSTR(__TIMESTAMP__"\r\n"));		//Print timestamp of time file last modified
	
	struct AES_ctx ctx;
	
	uart_puts(PSTR("Text to Encrypt: "));
	for(char i = 0; i < 16; i++)
	{
		uart_putc(input[i]);
	}
	uart_puts(PSTR("\r\n"));
	
	AES_init_ctx(&ctx, key);
	AES_ECB_encrypt(&ctx, input);
	
	uart_puts(PSTR("Encrypted Text: "));
	for(char i = 0; i < 16; i++)
	{
		uart_putcHex(input[i]);
	}
	uart_puts(PSTR("\r\n"));
	
	uart_puts(PSTR("\r\nBrute Start\r\n"));
	unsigned char guess = 0;

	while(1)
	{
		uart_puts(PSTR("Guess: "));
		uart_putcHex(guess);
		uart_puts(PSTR("    : "));
		
		int8_t input2[] = {'h','e','l','l','o', ',' , ' ', 'w','o','r','l','d','0','0','0','0'};
		input2[15] = guess;
		
		AES_ECB_encrypt(&ctx, input2);
		for(char i = 0; i < 16; i++)
		{
			uart_putcHex(input2[i]);
		}
		uart_puts(PSTR("\r\n"));
		
		guess++;
		if(guess == 0)
		{
			while(1);
		}
	}
	
	while(1);		//Stop program
}
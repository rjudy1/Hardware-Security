#include <avr/pgmspace.h>
#include <avr/io.h>
#undef F_CPU

// from https://atmega32-avr.com/establish-uart-communication-atmega8-arduino-uno/
// two way: https://circuitdigest.com/microcontroller-projects/uart-communication-between-two-atmega8-microcontrollers

// would write function to do this stuff
#include <xc.h>
#include <stdio.h>
#include <stdint.h>
#include <avr/pgmspace.h>
//header to enable data flow control over pins

#define F_CPU 25000000 //telling controller crystal frequency attached

#include <util/delay.h> //header to enable delay function in program
#include "aes.h"
#include <stdint-gcc.h>

int convert_to_byte(int a) {
	switch (a) {
		case 0:
		return 0b0111111;
		case 1:
		return 0b00000110;
		case 2:
		return 0b01011011;
		case 3:
		return 0b01001111;
		case 4:
		return 0b01100110;
		case 5:
		return 0b01101101;
		case 6:
		return 0b01111101;
		case 7:
		return 0b00000111;
		case 8:
		return 0b01111111;
		case 9:
		return 0b01101111;
		default:
		return 0b11001100;
	}
}

uint8_t uart_putc(uint8_t cc)	{
	while ((UCSRA & (1 << UDRE)) == 0)		;
	UDR = cc;
	return 1;
}


uint16_t uart_puts(const char * s)	{
	const char * from = s;
	uint8_t cc;
	while ((cc = pgm_read_byte(s++)))	
		uart_putc(cc);
	return s - from - 1;
 }
//volatile char output;
//uint8_t const aes_key[240] PROGMEM = { 0x61,0x65,0x73,0x45,0x6E,'c','r','y','p','t','i','o','n','K','e','y' };
//uint8_t aes_text[16];

int main(void)

{
		
	unsigned char receiveData;

	uint8_t response = '8';
	uint8_t aes_key[160] = { 'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y' };
	uint8_t aes_unencrypted[16] = 	{'h', 'e', 'l', 'l', 'o', ',',' ', 'w','o','r','l','d', '0', '0', '0', '0' };
	uint8_t aes_encrypted[16] = {0};

	
	DDRB = 0b11111111; //seven seg
	DDRC = 0b11110000; //seven seg select
	DDRD = 0b00000000; // button inputs
	//	DDRB =0;//PORTB is set as INPUT // needs to be D for buttons unless that's taken, then switch buttons onto A?
	//	DDRD |= 1 << PIND1;//pin1 of portD as OUTPUT
	//	DDRD &= ~(1 << PIND0);//pin0 of portD as INPUT
	//	PORTD |= 1 << PIND0;

	int UBBRValue = 51;//AS described before setting baud rate 9600 at 8Mhz 
	//Put the upper part of the baud number here (bits 8 to 11)
	UBRRH = (unsigned char) (UBBRValue >> 8);
	//Put the remaining part of the baud number here
	UBRRL = (unsigned char) UBBRValue;
	//Enable the receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
	//Set 2 stop bits and data bit length is 8-bit
	UCSRC = (1<<URSEL) | (1 << USBS) | (3 << UCSZ0);		//Different (added URSEL part)

	uart_puts(PSTR("\r\nProgram start\r\n"));
	
	uart_puts(PSTR("AES Encryption key: "));
	aes_init(aes_key);
	for (int8_t i = 0; i < 32; i++) {
		uart_putc(aes_key[i]);
	}
	uart_puts(PSTR("\r\n"));

	while(true) {
		uart_puts(PSTR("Main loop start\r\n"));
		
		if (PORTD == 0x08) {
			
			uart_puts(PSTR("Text to encrypt: "));
			for (int8_t i = 0; i < 16; i++) {
				DDRB = aes_unencrypted[i];			//This line doesn't make sense
				uart_putc(aes_unencrypted[i]);
			}
			uart_puts(PSTR("\r\n"));

			aes_cipher(aes_unencrypted, aes_encrypted);
			
			uart_puts(PSTR("Encrypted text: "));
			for (int8_t i = 0; i < 16; i++) {
				DDRB = aes_encrypted[i];
				uart_putc(aes_encrypted[i]);
			}
			uart_puts(PSTR("\r\n"));
			
//			for (int8_t i = 0; i < 16; i++) {
//				uint8_t x = aes_text[i];
//				DDRB = x;
//				uart_putc(x);
//			}
		}

		receiveData = UDR;
		 
		if (PORTD == 0x04){
			 PORTC = 0xF0;
			 PORTB = receiveData;
//			 aes_key[3] = receiveData;
		}
		
		uart_puts(PSTR("Main loop end\r\n"));
		while(true);		//Stop after one iteration. This line can be removed if looping needs to happen
		_delay_ms(200);
	}
}
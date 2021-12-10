#include <avr/pgmspace.h>
#include <avr/io.h>
#undef F_CPU

// from https://atmega32-avr.com/establish-uart-communication-atmega8-arduino-uno/
// two way: https://circuitdigest.com/microcontroller-projects/uart-communication-between-two-atmega8-microcontrollers

// would write function to do this stuff
#include <xc.h>
#include <stdio.h>
#include <stdint.h>

//header to enable data flow control over pins

#define F_CPU 25000000 //telling controller crystal frequency attached

#include <util/delay.h> //header to enable delay function in program
#include "aes.h"

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
 


int main(void)

{
		
	unsigned char receiveData;

	uint8_t response = '0';
	//uint8_t aes_key[16] = { 'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y' };
	
	DDRB = 0b11111111; //seven seg
	DDRC = 0b11110000; //seven seg select
	DDRD = 0b00000000; // button inputs
	//	DDRB =0;//PORTB is set as INPUT // needs to be D for buttons unless that's taken, then switch buttons onto A?
	//	DDRD |= 1 << PIND1;//pin1 of portD as OUTPUT
	//	DDRD &= ~(1 << PIND0);//pin0 of portD as INPUT
	//	PORTD |= 1 << PIND0;

//	int UBBRValue = 25;//AS described before setting baud rate 38400baud(BPS)
	//Put the upper part of the baud number here (bits 8 to 11)
//	UBRRH = (unsigned char) (UBBRValue >> 8);
	//Put the remaining part of the baud number here
//	UBRRL = (unsigned char) UBBRValue;
	//Enable the receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
	//Set 2 stop bits and data bit length is 8-bit
	UCSRC = (1 << USBS) | (3 << UCSZ0);

//	uint8_t aes_key[16] = { 0x61,0x65,0x73,0x45,'n','c','r','y','p','t','i','o','n','K','e','y' };

	//uint8_t aes_text[] = {'h', 'e', 'l', 'l', 'o', ',',' ', 'w','o','r','l','d', '0', '0', '0', '0' };

	for (;;) {
		if (PORTD == 0x08) {
			uart_putc(response);

			uart_puts(PSTR("Hello, World!\r\n"));
	
			for (int8_t i = 0x6A; i < 0x70; i++) {
			//	uart_putc(aes_key[i]);
			}
	//		}
		}
		receiveData = UDR;
		 
		if (PORTD == 0x04){
			 PORTC = 0xF0;
			 PORTB = receiveData;
		}
		
		_delay_ms(200);
	}
}
/*
 * main.c
 *
 * Created: 10/30/2021 11:20:20 AM
 *  Author: rjudy
 *	  Note: due to nature of memory allocation, need to pad
*			to multiple of 16 bytes to match outputs
 */ 

#undef F_CPU
#define F_CPU 25000000


#include <xc.h>
#include <util/delay.h>
//#include <iostream>
//#include <cstdlib>
#include "aes.h"


int main(void)
{
	DDRD = 0b11110000;					// PORTD is set as input for buttons
	uint8_t response = 'a';
	uint8_t aes_key[16] = { 'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y' };
	uint8_t aes_text[] = {'h', 'e', 'l', 'l', 'o', ',',' ', 'w','o','r','l','d', '0', '0', '0', '0' };
/*
	// options for output - iterate through each of these when button push or something like this?
	char strings[3][16] = { "testencryption00", "loremipsum012345", "ahgreat cstrings" };

*/	
	
	uint8_t intermediate_output[sizeof(aes_text) / sizeof(aes_text[0])];
	DDRB = 0b00000000;
	DDRC = 0b00000000;
	
	aes_init(aes_key);
	/*
	int UBBRValue = 25;//AS described before setting baud rate 38400baud(BPS)
	//Put the upper part of the baud number here (bits 8 to 11)
	UBRRH = (unsigned char) (UBBRValue >> 8);
	//Put the remaining part of the baud number here
	UBRRL = (unsigned char) UBBRValue;
	//Enable the receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
	//Set 2 stop bits and data bit length is 8-bit
	UCSRC = (1 << USBS) | (3 << UCSZ0);	
	*/
	
	while(1)
	{
		if (PORTD != 0x00) // top button
		{
			
			aes_cipher(aes_text, intermediate_output);
			
			for (int i = 0; i < sizeof(aes_text)/sizeof(aes_text[0]); i++) {
//				while (! (UCSRA & (1 << UDRE)) );		
				UDR = intermediate_output[i];//once transmitter is ready sent eight bit data // b4
				PORTB = 0x10000000;
				PORTC = intermediate_output[i];
				_delay_ms(200);
			}
			
			response = UDR;
			PORTB = 0x11000000;
			PORTC = response;
			_delay_ms(200);
			
		}
		_delay_ms(100);					//Pause for 40 ms
	}
}

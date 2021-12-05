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


int main(void)
{
	DDRB = 0b00000000;
	DDRC = 0b00000000;
	DDRD = 0b00001111;					// PORTD is set as input for buttons
	
	// 	int UBBRValue = 25;//AS described before setting baud rate 38400baud(BPS)
	// 	//Put the upper part of the baud number here (bits 8 to 11)
	// 	UBRRH = (unsigned char) (UBBRValue >> 8);
	// 	//Put the remaining part of the baud number here
	// 	UBRRL = (unsigned char) UBBRValue;
	//Enable the receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
	//Set 2 stop bits and data bit length is 8-bit
	UCSRC = (1 << USBS) | (3 << UCSZ0);
	
	uint8_t response = 'a';
	uint8_t aes_key[16] = { 'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y' };
	uint8_t aes_text[] = {'h', 'e', 'l', 'l', 'o', ',',' ', 'w','o','r','l','d', '0', '0', '0', '0' };

	while (1) {
		if (PORTD != 0)
		for (int i = 0; i < sizeof(aes_text) / sizeof(aes_text[0]); i++) {
			UDR = aes_text[i];
			
			PORTB = 0x10000000;
			PORTC = convert_to_byte(aes_text[i]&0xF0);
			_delay_ms(100);
			PORTB = 0x01000000;
			PORTC = convert_to_byte(aes_text[i]&0x0F);
			_delay_ms(200);
		}
	}
	/*
	DDRB = 0b00000000;
	DDRC = 0b00000000;
	DDRD = 0b00001111;					// PORTD is set as input for buttons
	uint8_t response = 'a';
	uint8_t aes_key[16] = { 'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y' };
	uint8_t aes_text[] = {'h', 'e', 'l', 'l', 'o', ',',' ', 'w','o','r','l','d', '0', '0', '0', '0' };

//	// options for output - iterate through each of these when button push or something like this?
//	char strings[3][16] = { "testencryption00", "loremipsum012345", "ahgreat cstrings" };

	
	
	uint8_t intermediate_output[16];//[sizeof(aes_text) / sizeof(aes_text[0])];

	
	aes_init(aes_key);
	
// 	int UBBRValue = 25;//AS described before setting baud rate 38400baud(BPS)
// 	//Put the upper part of the baud number here (bits 8 to 11)
// 	UBRRH = (unsigned char) (UBBRValue >> 8);
// 	//Put the remaining part of the baud number here
// 	UBRRL = (unsigned char) UBBRValue;
// 	//Enable the receiver and transmitter
// 	UCSRB = (1 << RXEN) | (1 << TXEN);
// 	//Set 2 stop bits and data bit length is 8-bit
// 	UCSRC = (1 << USBS) | (3 << UCSZ0);	
	
	while(1)
	{
		if (PORTD != 0x00) // press button to go
		{
			aes_cipher(aes_text, intermediate_output);
			PORTB = 0x11000000;
			PORTC = 0x01011010; // use as start flag
			intermediate_output[0] = 0x4a;
			intermediate_output[1] = 0x4b;
			for (int i = 0; i < 16; i++) {
//				while (! (UCSRA & (1 << UDRE)) );		
				PORTB = 0x10000000;
				PORTC = convert_to_byte(intermediate_output[i]&0xF0);
				_delay_ms(200);
				PORTB = 0x01000000;
				PORTC = convert_to_byte(intermediate_output[i]&0x0F);
				_delay_ms(200);
				UDR = intermediate_output[i];//once transmitter is ready sent eight bit data // b4
			}
			
//			response = UDR;

			_delay_ms(200);
			
		}
		_delay_ms(100);					//Pause for 40 ms
	}
	*/
}

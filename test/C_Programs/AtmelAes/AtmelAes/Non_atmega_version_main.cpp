/*
 * main.c
 *
 * Created: 10/30/2021 11:20:20 AM
 *  Author: rjudy
 *	  Note: due to nature of memory allocation, need to pad
*			to multiple of 16 bytes to match outputs
 */ 

#undef F_CPU
#define F_CPU 16000000


//#include <xc.h>
//#include <util/delay.h>
#include <iostream>
#include <cstdlib>
#include "aes.h"


int main(void)
{
//	DDRB = 0b11111111;					//PORTB is set to write (set as output)
//	DDRC = 0b11110000;					// PORTB is set as input
	uint8_t aes_key[16] = { 'a','e','s','E','n','c','r','y','p','t','i','o','n','K','e','y' };
	uint8_t aes_text[] = {'h', 'e', 'l', 'l', 'o', ',',' ', 'w','o','r','l','d', '0', '0', '0', '0' };
	uint8_t intermediate_output[sizeof(aes_text) / sizeof(aes_text[0])];

	aes_init(aes_key);
	while(1)
	{
		int x = 0;
		std::cin >> x;
		if (x == 5)
		{
			//PORTB = 0b10001000;				//PORTB is all low
			////			_delay_ms(40);					//Pause for 40 ms
			////			PORTB = 0b11111111;				//PORTB is all high
			////			_delay_ms(40);					//Pause for 40 ms
			//} else {
			//PORTB = 0b1111111;
			aes_cipher(aes_text, intermediate_output);
			std::cout << intermediate_output;
		}
//		_delay_ms(100);					//Pause for 40 ms

	}
}

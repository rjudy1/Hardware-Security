/*
 * main.c
 *
 * Created: 10/30/2021 11:20:20 AM
 *  Author: rjudy
 */ 

#undef F_CPU
#define F_CPU 16000000


#include <xc.h>
#include "util/delay.h"
#include "aes.h"


int main(void)
{
	DDRB = 0b11111111;					//PORTB is set to write (set as output)
	DDRC = 0b11110000;					// PORTB is set as input
	uint8_t aes_key, status;
	uint8_t aes_text[] = {0, 3, 4, 6};
	aes_key = 5;
	
	aes_init(&aes_key);
	while(1)
	{
		if (PORTC != (0x0F & 0b00000000))
		{
			PORTB = 0b10001000;				//PORTB is all low
			//			_delay_ms(40);					//Pause for 40 ms
			//			PORTB = 0b11111111;				//PORTB is all high
			//			_delay_ms(40);					//Pause for 40 ms
			} else {
			PORTB = 0b1111111;
			aes_cipher(aes_text, &status);
		}
		_delay_ms(100);					//Pause for 40 ms

	}
}

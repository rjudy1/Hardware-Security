#undef F_CPU
#define F_CPU 25000000


#include <xc.h>
#include "util/delay.h"
#include <stdio.h>


int main(void)
{
	DDRB = 0b11111111;					//PORTB is set to write (set as output)
	DDRC = 0b11110000;					// PORTC is set as input
	while(1)
	{
		if (PORTC !=  0b00000000)
		{
			PORTC = (PORTC&0b00001111) | 0b10000000;
			PORTB = 0b10001000;
			_delay_ms(400);					//Pause for 400 ms
			PORTC = (PORTC & 0b00001111) | 0b01000000;
			PORTB = 0b01000100;
			_delay_ms(400);					//Pause for 400 ms
			PORTC = (PORTC & 0b00001111) | 0b00100000;
			PORTB = 0b00100010;
			_delay_ms(400);					//Pause for 400 ms			
			PORTC = (PORTC & 0b00001111) | 0b00010000;
			PORTB = 0b00010001;
			_delay_ms(400);					//Pause for 400 ms
//			PORTB = 0b11111111;				//PORTB is all high
//			_delay_ms(40);					//Pause for 400 ms
			printf("test");
		} else {
			PORTB = 0b1111111;
		}
		_delay_ms(100);					//Pause for 40 ms

	}
}
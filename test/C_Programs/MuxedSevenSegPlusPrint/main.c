#undef F_CPU
#define F_CPU 16000000


#include <xc.h>
#include "util/delay.h"
#include <stdio.h>

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
	DDRB = 0b11111111;					//PORTB is set to write (set as output)
	DDRC = 0b11110000;					// PORTC is set as input
	int go = 1;
	while(1)
	{
		if (PORTC & 0b00001111 !=  0b00000000)
			go = 1;
			
		if (go)
		{
			PORTC = (PORTC&0b00001111) | 0b10000000;
			PORTB = convert_to_byte(0);
			_delay_ms(400);					//Pause for 400 ms
			PORTC = (PORTC & 0b00001111) | 0b01000000;
			PORTB = convert_to_byte(3);
			_delay_ms(400);					//Pause for 400 ms
			PORTC = (PORTC & 0b00001111) | 0b00100000;
			PORTB = convert_to_byte(6);
			_delay_ms(400);					//Pause for 400 ms			
			PORTC = (PORTC & 0b00001111) | 0b00010000;
			PORTB = convert_to_byte(7);
			_delay_ms(400);					//Pause for 400 ms
			printf("test");
		} else {
			PORTC = (PORTC & 0b00001111) | 0b01100000;
			PORTB = 0b1111111;
			_delay_ms(400);					//Pause for 400 ms
		}
		_delay_ms(100);					//Pause for 100 ms

	}
}
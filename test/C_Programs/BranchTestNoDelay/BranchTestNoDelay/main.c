#undef F_CPU
#define F_CPU 16000000


#include <xc.h>
#include "util/delay.h"
#include <stdio.h>


int main(void)
{
	DDRB = 0b11111111;					//PORTB is set to write (set as output)
	DDRC = 0b11110000;					// PORTC is set as output (top four for select)
	DDRD = 0b00000000;					// PORT D for buttons
	int x = 0;
	int y = 8;
	while(1)
	{
		if (x == y) {
			x = 0;
			PORTC = 0b10000000;
			PORTB = 0b01111111;
		}
		else if (x >= 5) {
			x = x + 1;
			PORTC = 0b10000000;
			PORTB = 0b01101101;
		} 
		else if (x < 5) {
			x = x + 1;
			PORTC = 0b10000000;
			PORTB = 0b01000000;			//Show a dash
		}
	}
}

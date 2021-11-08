/*
 * main.c
 *
 * Created: 9/30/2021 3:32:48 PM
 *  Author: Andrew Smith
 */ 
#undef F_CPU
#define F_CPU 25000000


#include <xc.h>
#include "util/delay.h"



int main(void)
{
	DDRB = 0b11111111;					//PORTB is set to write (set as output)
	DDRC = 0b11110000;
	while(1)
    {
		PORTC = 0b11110000;
		PORTB = 0b00000000;				//PORTB is all low
		_delay_ms(40);					//Pause for 40 ms
		PORTB = 0b11111111;				//PORTB is all high
		_delay_ms(40);					//Pause for 40 ms
    }
}

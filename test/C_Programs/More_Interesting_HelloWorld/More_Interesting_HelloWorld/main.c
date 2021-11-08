/*
 * main.c
 *
 * Created: 10/21/2021 2:31:54 PM
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
		for(int i = 1; i <= 128; i=i*2)
		{
					PORTB = i;				//PORTB is all low
					_delay_ms(60);					//Pause for 60 ms
		}
    }
}

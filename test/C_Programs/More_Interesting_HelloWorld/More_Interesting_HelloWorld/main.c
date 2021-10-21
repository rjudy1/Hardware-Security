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
	while(1)
    {
		for(int i = 0; i <= 128; i=i*2)
		{
					PORTB = i;				//PORTB is all low
					_delay_ms(60);					//Pause for 40 ms
		}
    }
}
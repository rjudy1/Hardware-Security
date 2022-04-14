/*
 * main.c
 *
 * Created: 2/19/2022 8:56:44 PM
 *  Author: andrewsmith
 */ 

#include <xc.h>
#include <avr/interrupt.h>

//#define RAND_MAX 255

char interruptFlagTriggered = 0;
char flipFlop = 0;

// TIMER2 with prescaler clkT2S/1024
#define TIMER2_PRESCALER      (1 << CS21)

// TIMER2 output compare value
// --> value 98 is 25.088ms (4MHz@1024 prescale factor)


void main()
{
	// ... do something ...

	// init Timer2
	TIMSK |= (1 << OCIE2);                    // set output compare interrupt enable
	TCCR2 |= (1 << WGM21) | TIMER2_PRESCALER; // set CTC mode
	OCR2   = 0;            // set compare value for interrupt

	// ... do something ...
	char count = 0;
	while (1)
	{
		sei();
		/*TCCR2 = count + 8;
		count = rand();*/
		if(interruptFlagTriggered == 1)
		{
			interruptFlagTriggered = 0;
			if(flipFlop == 1)
			{
				PORTB = PORTB | 0b00000001;
				flipFlop = 0;
			}
			else
			{
				PORTB = PORTB & 0b11111110;
				flipFlop = 1;
			}
		}
	} /* end of while(1)  */
}

	// *** Interrupt Service Routine *****************************************

	// Timer2 compare match interrupt handler
	// --> set as 25ms
ISR(TIMER2_COMP_vect)
{
	interruptFlagTriggered = 1;
	OCR2 = rand() % 255;      //Ideally, would be some random value between 0 and 255
}
#include <avr/io.h>
#undef F_CPU

// from https://atmega32-avr.com/establish-uart-communication-atmega8-arduino-uno/
// two way: https://circuitdigest.com/microcontroller-projects/uart-communication-between-two-atmega8-microcontrollers

// would write function to do this stuff
#include <xc.h>
#include <stdio.h>

//header to enable data flow control over pins

#define F_CPU 8000000 //telling controller crystal frequency attached

#include <util/delay.h> //header to enable delay function in program

int main(void)

{
	//	DDRB =0;//PORTB is set as INPUT // needs to be D for buttons unless that's taken, then switch buttons onto A?
	//	DDRD |= 1 << PIND1;//pin1 of portD as OUTPUT
	//	DDRD &= ~(1 << PIND0);//pin0 of portD as INPUT
	//	PORTD |= 1 << PIND0;

	// https://cache.amobbs.com/bbs_upload782111/files_22/ourdev_508497.html
	unsigned int ubbrValue = 51;//AS described before setting baud rate 9600baud(BPS)
	//Put the upper part of the baud number here (bits 8 to 11)
	UBRRH = (unsigned char) (ubbrValue >> 8);
	//Put the remaining part of the baud number here
	UBRRL = (unsigned char) ubbrValue;
	//Enable the receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
	//Set 2 stop bits and data bit length is 8-bit
	UCSRC = (1<<URSEL) | (1 << USBS) | (3 << UCSZ0);		//Different (added URSEL part)

	while (1)	{
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 0b10110100;//once transmitter is ready sent eight bit data // b4
			_delay_ms(100);
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 0b00011100; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 's'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'e'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'n'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'i'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'o'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'r'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = ' '; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'd'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'e'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 's'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'i'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'g'; // 1C
			while (! (UCSRA & (1 << UDRE)) );
			UDR = 'n'; // 1C
			while(1);
	}
}
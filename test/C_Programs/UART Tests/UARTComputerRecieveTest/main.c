//Nov 13, 2021

#include <avr/io.h>
#undef F_CPU

// from https://atmega32-avr.com/establish-uart-communication-atmega8-arduino-uno/
// two way: https://circuitdigest.com/microcontroller-projects/uart-communication-between-two-atmega8-microcontrollers

// would write function to do this stuff
#include <xc.h>
#include <stdio.h>

//header to enable data flow control over pins

#define F_CPU 25000000 //telling controller crystal frequency attached

#include <util/delay.h> //header to enable delay function in program

int main(void)

{
	DDRD = 0b00000000; // button inputs
	//	DDRB =0;//PORTB is set as INPUT // needs to be D for buttons unless that's taken, then switch buttons onto A?
	//	DDRD |= 1 << PIND1;//pin1 of portD as OUTPUT
	//	DDRD &= ~(1 << PIND0);//pin0 of portD as INPUT
	//	PORTD |= 1 << PIND0;

	int UBBRValue = 25;//AS described before setting baud rate 38400baud(BPS)
	//Put the upper part of the baud number here (bits 8 to 11)
	UBRRH = (unsigned char) (UBBRValue >> 8);
	//Put the remaining part of the baud number here
	UBRRL = (unsigned char) UBBRValue;
	//Enable the receiver and transmitter
	UCSRB = (1 << RXEN) | (1 << TXEN);
	//Set 2 stop bits and data bit length is 8-bit
	UCSRC = (1 << USBS) | (3 << UCSZ0);
	
	int letter = 0x61;

	while (1)	{
		
		
		if (!(PORTD == 0x00)) {//once button is pressed, transmit, for highest button
			while (! (UCSRA & (1 << UDRE)) );
			UDR = letter;
			letter = letter + 1;
			_delay_ms(150);
			//UDR = 0b00011100; // 1C
		}
		
		if (letter == 0x7b){
			letter = 0x30;
		}
		else if (letter == 0x3a){
			letter = 0x41;
		}

		_delay_ms(220);

	}
}
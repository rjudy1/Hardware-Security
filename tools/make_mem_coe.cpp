#include "assert.h"
#include "stdio.h"
#include <stdint.h>
#include <string.h>
#include <iostream>

const char* hex_file = 0;
const char* vhdl_file = 0;

uint8_t buffer[0x10000];

//-----------------------------------------------------------------------------
uint32_t
get_byte(const char* cp)
{
	uint32_t value;
	const char cc[3] = { cp[0], cp[1], 0 };
	const int cnt = sscanf(cc, "%X", &value);
	assert(cnt == 1);
	return value;
}

//-----------------------------------------------------------------------------
void read_file(FILE* in)
{
	memset(buffer, 0xFF, sizeof(buffer));
	char line[200];
	while (true)
	{
		const char* s = fgets(line, sizeof(line) - 2, in);
		if (s == 0)
		{
			return;
		}
		assert(*s++ == ':' && "Hint: check for empty lines in hex file");
		const uint32_t len = get_byte(s);
		const uint32_t ah = get_byte(s + 2);
		const uint32_t al = get_byte(s + 4);
		const uint32_t rectype = get_byte(s + 6);
		const char* d = s + 8;
		const uint32_t addr = ah << 8 | al;

		uint32_t csum = len + ah + al + rectype;
		assert((addr + len) <= 0x10000);
		for (uint32_t l = 0; l < len; ++l)
		{
			const uint32_t byte = get_byte(d);
			d += 2;
			buffer[addr + l] = byte;
			csum += byte;
		}
		csum = 0xFF & -csum;
		const uint32_t sum = get_byte(d);
		assert(sum == csum);
	}
}

//-----------------------------------------------------------------------------
void  write_vector(FILE* out, bool odd, uint32_t mem)
{
	const uint8_t* base = buffer;
	// total memory is 2 even bytes, 2 odd bytes, 2 even bytes, ...
	//
	if (odd)
	{
		base += 2;// go over two bytes in the buffer from start
	}

	// step over every other two byte word for odd/even memories
	for (int d = 0; d < 1024; d++) {
		uint32_t q = base[4*d+1]; // high byte
		fprintf(out, "%X", q >> 4); // high nibble
		fprintf(out, "%X", q & 0x0F); //low nibble
		q = base[4 * d]; // low byte
		fprintf(out, "%X", q >> 4); // high nibble
		fprintf(out, "%X ", q & 0x0F); //low nibble
	}


	// total memory is 4 kByte organized into 8 memories.
	// thus each of the 16 vectors covers 256 bytes.
	//


	//base += v * 256;// go over to the next memory block

	//// memories 0 and 1 are the low byte of the opcode while
	//// memories 2 and 3 are the high byte.
	////
	//if (mem >= 2)
	//{
	//	++base; // go over to the high byte of greater than or equal to 2
	//}

	////const char* px = odd ? "po" : "pe";
	////fprintf(out, "constant %s_%u_%2.2X : BIT_VECTOR := X\"", px, mem, v);
	//for (int32_t d = 63; d >= 0; --d)
	//{
	//	uint32_t q = base[4 * d];
	//	if (mem & 1)   q >>= 4;     // high nibble
	//	else           q &= 0x0F;   // low nibble
	//	fprintf(out, "%X", q);
	//}
//	fprintf(out, "\";\r\n");
}

//-----------------------------------------------------------------------------
void write_mem(FILE* out, bool odd, uint32_t mem)
{
	//const char* px = odd ? "po" : "pe";
	//fprintf(out, "-- content of %s_%u --------------------------------------"
	//	"--------------------------------------------\r\n", px, mem);

	//for (uint32_t v = 0; v < 16; ++v)
	//{
		write_vector(out, odd, mem);
	//}

//	fprintf(out, "\r\n");
}

//-----------------------------------------------------------------------------
void write_file(FILE* out1, bool odd)
{
	fprintf(out1,
		"memory_initialization_radix = 16;\r\n"
		"memory_initialization_vector = \r\n"
	);


	//for (uint32_t m = 0; m < 4; ++m)
	//{
		write_mem(out1, odd, 0);
	//}

	//for (uint32_t m = 0; m < 4; ++m)
	//{
//		write_mem(out2, true, 0);
	//}

	fprintf(out1,
		";\r\n");
}
//-----------------------------------------------------------------------------
int	main(int argc, char* argv[])
{
	if (argc <= 1)
	{
		std::cout << "Usage: <hex_file.hex> [vhdl_output.vhd]" << std::endl;
		return 1;
	}

	if (argc > 1)
	{
		hex_file = argv[1];
	}

	if (argc > 2)
	{
		vhdl_file = argv[2];
	}

	FILE* in = stdin;
	if (hex_file)
	{
		in = fopen(hex_file, "r");
	}

	assert(in);
	read_file(in);
	fclose(in);

	FILE* out1 = stdout;
	if (vhdl_file)
	{
		out1 = fopen("mem_even.coe", "w");
	}
	write_file(out1, false);
	assert(out1);

	FILE* out2 = stdout;
	if (vhdl_file)
	{
		out2 = fopen("mem_odd.coe", "w");
	}
	write_file(out2, true);
	assert(out2);
}
CC = gcc
#For older gcc, use -O3 or -O2 instead of -Ofast
CFLAGS = -lm -pthread -O3 -march=native -funroll-loops -Wno-unused-result

all: randwalk

randwalk : randwalk.c
	$(CC) randwalk.c -o randwalk $(CFLAGS)

clean:
	rm -rf randwalk 
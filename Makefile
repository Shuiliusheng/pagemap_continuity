# Makefile for pagemap

CC = gcc
CFLAGS = -std=c99

.PHONY: all
all: pagemap 

pagemap: pagemap.c
	$(CC) $(CFLAGS) $^ -o $@

.PHONY: clean
clean:
	-rm pagemap 

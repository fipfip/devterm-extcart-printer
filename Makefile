CC = gcc

CFLAGS  = -O0 -g -Wall
LDFLAGS = 
INCLUDES =  -I /usr/include/freetype2
LIBS = -lwiringPi -lm -lcrypt -lpthread -lfreetype -lrt -lgpiod

MAIN = devterm_printer_cartridge.elf

SRCS = printer.c  devterm_thermal_printer.c  utils.c ftype.c utf8-utils.c hal_gpio.c
OBJS = $(SRCS:.c=.o)

BINDIR ?= /usr/local/bin

.PHONY: depend clean install

install:
	@echo "Installing binary..."
	@install -m 557 $(MAIN) $(BINDIR)
	@echo "Installing systemd services"
	@install -m 644 ./usr/local/etc/printer-cartridge /usr/local/etc/
	@install -m 644 ./etc/systemd/system/printer-cartridge.service /etc/systemd/system/
	@install -m 557 ./usr/local/bin/printer_cartridge_socat.sh /usr/local/bin/
	@install -m 644 ./etc/systemd/system/printer-cartridge-socat.service /etc/systemd/system/
	@echo "Installing cartridge description file"
	@mkdir -p /etc/cartridged/cartdb/
	@install -m 644 ./etc/cartridged/cartdb/0001-thermal-printer.cart /etc/cartridged/cartdb/
	@echo "Reloading systemd"
	@systemctl daemon-reload
	
	
	

all:    $(MAIN)
	@echo compile $(MAIN)

$(MAIN): $(OBJS) 
	$(CC) $(CFLAGS) $(INCLUDES) -o $(MAIN) $(OBJS) $(LFLAGS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<  -o $@

clean:
	$(RM) *.o *~ $(MAIN)
        


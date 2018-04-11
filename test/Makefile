ifneq ($(_PREFIX_INN_),)
PREFIX := $(_PREFIX_INN_)
else
PREFIX := arm-elf-
endif

TARGET := hello

CCFLAGS := -g -O0
LDFLAGS :=

.PHONY: all clean prompt

all: prompt $(TARGET).elf

$(TARGET).elf: hello.c
	$(PREFIX)gcc $(CCFLAGS) -c hello.c -o $(TARGET).o
	$(PREFIX)gcc $(CCFLAGS) hello.c -o $(TARGET).elf
	$(PREFIX)objdump -d $(TARGET).o > $(TARGET).src
	$(PREFIX)run $(TARGET).elf
	@echo "==============================================================="
	@cat $(TARGET).src

clean:
	rm -rf *.o $(TARGET).elf $(TARGET).src

prompt:
	$(PREFIX)objdump -v
	$(PREFIX)gcc -v
	$(PREFIX)gdb -v
	@echo "==============================================================="

ifndef TOPDIR
TOPDIR := ..
endif

include $(TOPDIR)/Config.mk

SUBDIRS     := kernel
TARGET      := target.o

OBJS        += $(patsubst %.S, %.o, $(wildcard *.S))
OBJS        += $(patsubst %.c, %.o, $(wildcard *.c))
OBJS        += kernel.bin.o

all : compile $(OBJS)
	$(LD) $(LDFLAGS) $(LDSCRIPT) -N $(OBJS) $(LIBGCC) -o $(TARGET)

compile:
	@for dir in $(SUBDIRS); do \
	make -C $$dir || exit $?; \
	done

clean:
	@for dir in $(SUBDIRS); do \
	make -C $$dir clean; \
	done
	rm -rf *.o *.i *.s $(TARGET)

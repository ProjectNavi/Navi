ifndef TOPDIR
TOPDIR := ..
endif

include $(TOPDIR)/Config.mk

TARGET      := target.o

OBJS        += $(patsubst %.S, %.o, $(wildcard *.S))
OBJS        += $(patsubst %.c, %.o, $(wildcard *.c))


all : compile $(OBJS)
	$(LD) $(LDFLAGS) $(LDRELOC) $(OBJS) -o $(TARGET)

compile:
	@for dir in $(SUBDIRS); do \
	make -C $$dir || exit $?; \
	done

clean:
	@for dir in $(SUBDIRS); do \
	make -C $$dir clean; \
	done
	rm -rf *.o *.i *.s $(TARGET)

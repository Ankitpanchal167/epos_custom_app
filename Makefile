-include DIRS
-include ../../Rules.make

all: release

debug:
	@for dir in $(DIRS); do \
		make -C $$dir debug; \
	done

release:
	@for dir in $(DIRS); do \
                make -C $$dir ; \
	done

clean:
	@for dir in $(DIRS); do \
                make -C $$dir clean; \
	done

install:
	@for dir in $(DIRS); do \
                make -C $$dir install; \
	done

install_debug:
	@for dir in $(DIRS); do \
                make -C $$dir install_debug; \
	done







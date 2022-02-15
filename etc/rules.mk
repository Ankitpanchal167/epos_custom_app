#
# $BASE/etc/rules.mk
#
# Copyright (C) 2013 Texas Instruments Incorporated - http://www.ti.com/
#
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#    Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#    Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the
#    distribution.
#
#    Neither the name of Texas Instruments Incorporated nor the names of
#    its contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#


#
# Set default goal
#
.DEFAULT_GOAL	:= all

#
# Select level of verbosity
# (Silent by default)
#
Q := @
H := @

ifeq ($(V),1)
Q :=
endif

ifeq ($(V),2)
Q :=
H :=
endif

#
# Files extentions
#
EXT_C		:= c
EXT_S		:= s
EXT_O		:= o
EXT_LIB		:= a
EXT_LDS		:= lds
EXT_EXE		:= out
EXT_BIN		:= bin
EXT_MAP		:= map

#
# Commonly used variables
#
CC		:= $(TOOLCHAIN_PREFIX)-gcc
LD		:= $(TOOLCHAIN_PREFIX)-gcc
AS		:= $(TOOLCHAIN_PREFIX)-as
AR		:= $(TOOLCHAIN_PREFIX)-ar
OBJCOPY		:= $(TOOLCHAIN_PREFIX)-objcopy

#
# Common flags for the compiler
#
CFLAGS	:= -march=armv7-a -mlittle-endian -mfpu=vfpv3 -mfloat-abi=hard
CFLAGS	+= --sysroot=$(TOOLCHAIN_DIR)/$(TOOLCHAIN_PREFIX)/libc
CFLAGS	+= -g -O2
CFLAGS	+= -Wall -Wno-missing-braces
CFLAGS	+= -isystem $(TOOLCHAIN_DIR)/$(TOOLCHAIN_PREFIX)/usr/include
CFLAGS	+= -I$(LINUX_HEADERS)
CFLAGS	+= -I$(BASE_DIR)/inc

#
# Common flags for the linker
#
LDFLAGS	:= -isystem $(TOOLCHAIN_DIR)/$(TOOLCHAIN_PREFIX)/lib
LDFLAGS	+= -lc -lgcc

#
# Common flags for the archiver
#
ARFLAGS	:= cr


# ------------------------------------------------------------------------------
# Include processor specific definitions
# ------------------------------------------------------------------------------

ifeq ($(PROC),AM43XX)
include $(BASE_DIR)/etc/proc-am43xx.mk
endif

# ------------------------------------------------------------------------------
# Definitions derived from project specific definitions
# ------------------------------------------------------------------------------

#
# Name of executable
#
PROJ_OUT	:= $(PROJ_NAME)

#
# Name of map file
#
PROJ_MAP	:= $(PROJ_NAME).$(EXT_MAP)

#
# Name of library archive
#
PROJ_LIB	:= lib$(PROJ_NAME).$(EXT_LIB)

#
# Objects from C sources
#
OBJS_C		:= $(SRCS_C:.c=.o)

#
# Objects from ASM sources
#
OBJS_S		:= $(SRCS_S:.s=.o)

#
# Flags for include path
#
FLAGS_INCPATH	:= $(addprefix -I,$(PROJ_INCPATH))

#
# Flags for library path
#
FLAGS_LIBPATH	:= $(addprefix -L,$(PROJ_LIBPATH))

#
# Flags for each library name
#
FLAGS_LIBS	:= $(addprefix -l,$(PROJ_LIBS))


# ------------------------------------------------------------------------------
# Update tool specific flags
# ------------------------------------------------------------------------------

CFLAGS	+= $(FLAGS_INCPATH)

LDFLAGS	+= $(FLAGS_LIBPATH)

# ------------------------------------------------------------------------------
# Canned command sequences
# ------------------------------------------------------------------------------

#
# Show banner for building
#
define show-banner
$(H)echo ""
$(H)echo "::"
$(H)echo ":: Building project \"$(PROJ_NAME)\" ..."
$(H)echo "::"
endef

#
# Show banner for cleaning
#
define show-banner-clean
endef

#
# Compile a C source file
#
define do-cc
$(H)echo "::"
$(H)echo ":: Compiling $(<) ..."
$(H)echo "::"
$(Q)$(TOOLCHAIN_DIR)/bin/$(CC) $(CFLAGS) -c $(<) -o $(@)
endef

#
# Assemble source file
#
define do-as
$(H)echo "::"
$(H)echo ":: Assembling $(<) ..."
$(H)echo "::"
$(Q)$(TOOLCHAIN_DIR)/bin/$(AS) $(ASFLAGS) $(<) -o $(@)
endef

#
# Create executable
#
define do-ld
$(H)echo "::"
$(H)echo ":: Linking ..."
$(H)echo "::"
$(Q)$(TOOLCHAIN_DIR)/bin/$(LD) $(LDFLAGS) $(^) $(FLAGS_LIBS) -o $(@)
endef

#
# Create library archive
#
define do-ar
$(H)echo "::"
$(H)echo ":: Creating archive "$(@)" ..."
$(H)echo "::"
$(Q)$(TOOLCHAIN_DIR)/bin/$(AR) $(ARFLAGS) $(@) $(^)
endef

#
# Clean executable, binary and intermediate files
#
define do-clean
$(H)echo ""
$(H)echo "::"
$(H)echo ":: Cleaning project \"$(PROJ_NAME)\" ..."
$(H)echo "::"
$(H)for f in $(wildcard *.$(EXT_O)); do echo " : Delete $${f}"; rm -f $${f} ; done;
$(H)if test -f $(PROJ_MAP); then echo " : Delete $(PROJ_MAP)"; rm -f $(PROJ_MAP); fi;
$(H)if test -f $(PROJ_OUT); then echo " : Delete $(PROJ_OUT)"; rm -f $(PROJ_OUT); fi;
endef

#
# Show name of generated target.
#
define show-target
$(H)test -f $(@) && echo " : \"$(@)\" is ready." || echo " : \"$(@)\" is not ready."
$(H)echo ""
endef

# ------------------------------------------------------------------------------
# Common rules
# ------------------------------------------------------------------------------

#
# Delete default suffixes
#
.SUFFIXES:            # Delete the default suffixes

#
# Define our list of suffixes
#
.SUFFIXES: $(EXT_S) $(EXT_C) $(EXT_O)

#
# Rule - Show banner for building
#
.PHONY: banner
banner:
	$(show-banner)

#
# Rule - Show banner for cleaning
#
.PHONY: banner-clean
banner-clean:
	$(show-banner-clean)

#
# Rule - assemble source
#
%.$(EXT_O) : %.$(EXT_S)
	$(do-as)
#
# Rule - assemble source
#
%.$(EXT_O) : %.$(EXT_C)
	$(do-cc)

#
# Rule - Create archive
#
$(PROJ_LIB): $(OBJS_C) $(OBJS_S)
	$(do-ar)
	$(show-target)

#
# Rule - Create executable
#
$(PROJ_OUT): $(OBJS_C) $(OBJS_S)
	$(do-ld)
	$(show-target)

#
# Default rule (build binary)
#
ifeq ($(PROJ_TYPE),LIB)
all: banner $(PROJ_LIB)
else
all: banner $(PROJ_OUT)
endif

#
# Default rule (build library archive)
#
lib: banner $(PROJ_LIB)

#
# Clean
#
clean:
	$(do-clean)

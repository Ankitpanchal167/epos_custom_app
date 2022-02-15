#
# $BASE/src/keypad/Makefile
#
# Rules to build the application.
#
#
# Copyright (C) 2017 Texas Instruments Incorporated - http://www.ti.com/
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
# Get path to base directory
#
BASE_DIR	:= $(realpath $(realpath .)/..)

#
# Name of the project
#
PROJ_NAME	:= fingerprint_app

#
# List of C sources
#
SRCS_C		:= test_fp_a365_biosec_int.c fingerprint.c fingerprintA.c fingerprintC.c SPI.c

#
# List of ASM sources
#
SRCS_S		:=

#
# Project specific path for headers
#
PROJ_INCPATH	:=

#
# Project specific path for libraries
#
PROJ_LIBPATH	:=

#
# Project specific libraries
#
PROJ_LIBS	:=

install:
	@if [ ! -d $(DESTDIR) ] ; then \
                echo "The extracted target filesystem directory doesn't exist."; \
                echo "Please run setup.sh in the SDK's root directory and then try again."; \
                exit 1; \
        fi
	@install -d $(DESTDIR)/usr/bin
	@if [ -e $(PROJ_NAME) ] ; then \
                install $(PROJ_NAME) $(DESTDIR)/usr/bin/ ; \
                echo "$(PROJ_NAME) Release version installed.in $(DESTDIR)/usr/bin"; \
        else \
                echo "$(PROJ_NAME) Release version not built - nothing to install!"; \
        fi



#
# Include generic rules for build targets
#
include $(BASE_DIR)/etc/local.mk
include $(BASE_DIR)/etc/rules.mk

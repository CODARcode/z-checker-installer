## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
##   Makefile to test SZ library.

##   PLEASE SET THIS VARIABLE BEFORE COMPILING
ADIOS2PATH	= $(abspath /home/sdi/Softwares/ADIOS2/build/install)
ZCPATH		= $(abspath ../Z-checker/zc-install)
##   COMPILERS
CC		= mpic++

##   FLAGS
# Compiling using shared library
#SZFLAG 	= -I$(SZPATH)/include -L$(SZPATH)/lib -lSZ
# Compiling using static library
ADIOS2FLAG 	= -fPIC -I$(ADIOS2PATH)/include -L$(ADIOS2PATH)/lib64 -ladios2 -Wl,-rpath,"$(ADIOS2PATH)/lib"
ZCFLAG  = -I$(ZCPATH)/include -L$(ZCPATH)/lib -lzc -Wl,-rpath,"$(ZCPATH)/lib"


##   TARGETS
all:	testAdios2

testAdios2:	testAdios2.cpp
	$(CC)  -g -O0 -o testAdios2 testAdios2.cpp $(ADIOS2FLAG) $(ZCFLAG)

clean:
	rm -f testAdios2


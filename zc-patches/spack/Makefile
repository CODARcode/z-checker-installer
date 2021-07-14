ZC_HOME=/home/sdi/Development/Z-checker/z-checker-0.6/zc-install
CFLAGS=-g -O0 $(shell pkg-config --cflags libpressio) -I$(ZC_HOME)/include -L$(ZC_HOME)/lib -lzc -Wl,-rpath,$(ZC_HOME)/lib
CXXFLAGS=${CFLAGS} -std=c++17
LDFLAGS=$(shell pkg-config --libs libpressio)

ALL=pressio_json pressio_manageCompressor pressio_query libzcheckerapi.so pressio_compdecomp pressio_compdecomp_zc
all: $(ALL)
libzcheckerapi.so: zcheckerapi.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -fPIC -shared $^ -o $@
pressio_manageCompressor: LDFLAGS+=-lzcheckerapi -L.
pressio_manageCompressor: libzcheckerapi.so
pressio_compdecomp: LDFLAGS+=-lzcheckerapi -L.
pressio_compdecomp: libzcheckerapi.so
pressio_compdecomp_zc: LDFLAGS+=-lzcheckerapi -L.
pressio_compdecomp_zc: libzcheckerapi.so
pressio_json:
pressio_query:
check: all
	./pressio_json
clean:
	$(RM) $(ALL)


SRCDIR := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

GRAPHVIZ_DIR := $(SRCDIR)/third_party/graphviz-8.0.3
GRAPHVIZ_COPY_DIR := $(SRCDIR)/build/graphviz

GRAPHVIZ_INCLUDE_DIR := $(SRCDIR)/build/include
GRAPHVIZ_LIB_DIR := $(SRCDIR)/build/lib
JSON_INCLUDE_DIR := $(SRCDIR)/third_party/json
OPTS := -std=c++20 -I$(GRAPHVIZ_INCLUDE_DIR) -I$(JSON_INCLUDE_DIR) -L$(GRAPHVIZ_LIB_DIR) -lgvc -lcgraph
LIBGVC := $(SRCDIR)/build/lib/libgvc.so
LIBCGRAPH := $(SRCDIR)/build/lib/libcgraph.so

all: cupgraphlayout

clean:
	rm -rf $(SRCDIR)/build

cupgraphlayout: libs
	$(CXX) $(OPTS) $(SRCDIR)/main.cpp -o $(SRCDIR)/build/CUPGraphLayout

libs: $(LIBGVC) $(LIBCGRAPH)

$(LIBGVC): deps

$(LIBCGRAPH): deps

builddir:
	mkdir -p $(SRCDIR)/build

confdeps: copydeps
	cd $(GRAPHVIZ_COPY_DIR) && ./configure --prefix=$(SRCDIR)/build

deps: confdeps | builddir
	cd $(GRAPHVIZ_COPY_DIR) && $(MAKE) -j$(shell nproc) && $(MAKE) install

copydeps:
	mkdir -p $(GRAPHVIZ_COPY_DIR)
	cp -r $(GRAPHVIZ_DIR)/* $(GRAPHVIZ_COPY_DIR)/

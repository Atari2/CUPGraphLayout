SRCDIR := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
BUILDDIR := $(SRCDIR)/build

GRAPHVIZ_DIR := $(SRCDIR)/third_party/graphviz-8.0.3
GRAPHVIZ_COPY_DIR := $(BUILDDIR)/graphviz-8.0.3

GRAPHVIZ_INCLUDE_DIR := $(BUILDDIR)/include
GRAPHVIZ_LIB_DIR := $(BUILDDIR)/lib
JSON_INCLUDE_DIR := $(SRCDIR)/third_party/json
OPTS := -std=c++20 -I$(GRAPHVIZ_INCLUDE_DIR) -I$(JSON_INCLUDE_DIR) -L$(GRAPHVIZ_LIB_DIR) -lgvc -lcgraph

all: cupgraphlayout

clean:
	rm -rf $(BUILDDIR)

cupgraphlayout: builddeps
	$(CXX) $(OPTS) $(SRCDIR)/main.cpp -o $(BUILDDIR)/CUPGraphLayout

builddeps: confdeps
	cd $(GRAPHVIZ_COPY_DIR) && $(MAKE) -j$(shell nproc) && $(MAKE) install

confdeps: copydeps
	cd $(GRAPHVIZ_COPY_DIR) && ./configure --prefix=$(BUILDDIR)

copydeps: | builddir
	cp -r $(GRAPHVIZ_DIR) $(BUILDDIR)

builddir:
	mkdir -p $(BUILDDIR)

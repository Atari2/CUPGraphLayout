SRCDIR := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
BUILDDIR := $(SRCDIR)/build

GRAPHVIZ_DIR := $(SRCDIR)/third_party/graphviz-8.0.3
GRAPHVIZ_COPY_DIR := $(BUILDDIR)/graphviz-8.0.3

GRAPHVIZ_INCLUDE_DIR := $(BUILDDIR)/include
GRAPHVIZ_LIB_DIR := $(BUILDDIR)/lib
JSON_INCLUDE_DIR := $(SRCDIR)/third_party/json
OPTS := -std=c++20 -I$(GRAPHVIZ_INCLUDE_DIR) -I$(JSON_INCLUDE_DIR) -L$(GRAPHVIZ_LIB_DIR) -lgvc -lcgraph
GRAPHLIB := $(GRAPHVIZ_LIB_DIR)/libcgraph.so
CONFDEPS := $(GRAPHVIZ_COPY_DIR)/Makefile
MAINEXE := $(BUILDDIR)/CUPGraphLayout
SOURCES := $(wildcard $(SRCDIR)/*.cpp)

all: $(MAINEXE)

deps: $(GRAPHLIB)

clean:
	rm -rf $(BUILDDIR)

cleandeps: 
	cd $(GRAPHVIZ_COPY_DIR) && $(MAKE) clean

distcleandeps:
	cd $(GRAPHVIZ_COPY_DIR) && $(MAKE) distclean

$(MAINEXE): $(GRAPHLIB) $(SOURCES)
	$(CXX) $(OPTS) $(SOURCES) -o $(MAINEXE)

$(GRAPHLIB): $(CONFDEPS)
	cd $(GRAPHVIZ_COPY_DIR) && $(MAKE) -j$(shell nproc) && $(MAKE) install

$(CONFDEPS): | $(GRAPHVIZ_COPY_DIR)
	cd $(GRAPHVIZ_COPY_DIR) && ./configure --prefix=$(BUILDDIR)

$(GRAPHVIZ_COPY_DIR): | $(BUILDDIR)
	cp -r $(GRAPHVIZ_DIR) $(BUILDDIR)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

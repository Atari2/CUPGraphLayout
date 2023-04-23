SRCDIR := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
BUILDDIR := $(SRCDIR)/build
DEPSCHECK := $(BUILDDIR)/depscheck

JSON_INCLUDE_DIR := $(SRCDIR)/third_party/json
CXXFLAGS ?= 
CXXFLAGS += -std=c++20 -I$(JSON_INCLUDE_DIR)

GRAPHVIZ_CXX_FLAGS ?= $(shell pkg-config libgvc --cflags)
GRAPHVIZ_LD_FLAGS ?= $(shell pkg-config libgvc --libs)

CXXFLAGS += $(GRAPHVIZ_CXX_FLAGS)
LDFLAGS += $(GRAPHVIZ_LD_FLAGS)
TARGET = $(BUILDDIR)/CUPGraphLayout
OBJ = $(BUILDDIR)/CUPGraphLayout.o
SOURCES := $(wildcard $(SRCDIR)/*.cpp)

all: $(TARGET)

clean:
	rm -rf $(BUILDDIR)

$(TARGET): $(OBJ)
	$(CXX) -o $(TARGET) $(OBJ) $(LDFLAGS)

$(OBJ): $(SOURCES) $(DEPSCHECK)
	$(CXX) $(CXXFLAGS) -c $(SOURCES) -o $(OBJ)

$(DEPSCHECK): | $(BUILDDIR)
ifeq ($(GRAPHVIZ_CXX_FLAGS),)
		$(warning pkg-config can't find graphviz libraries, or pkg-config itself can't be found)
		$(warning please install pkg-config and the requires libraries)
		$(warning on Ubuntu and derivatives, the package is named `graphviz-dev`)
		$(error Terminating makefile build)
endif
ifeq ($(GRAPHVIZ_LD_FLAGS),)
		$(warning pkg-config can't find graphviz libraries, or pkg-config itself can't be found)
		$(warning please install pkg-config and the requires libraries)
		$(warning on Ubuntu and derivatives, the package is named `graphviz-dev`)
		$(error Terminating makefile build)
endif
	touch $(DEPSCHECK)

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

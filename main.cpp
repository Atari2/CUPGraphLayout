#include <graphviz/types.h>
#include <fstream>
#include <graphviz/cgraph.h>
#include <graphviz/gvc.h>
#include <nlohmann/json.hpp>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <iostream>

using json = nlohmann::json;

struct Node {
  std::string name;
  bool is_terminal;
};

struct Edge {
  std::string source;
  std::string target;
};

struct Graph {
  std::vector<Node> nodes;
  std::vector<Edge> edges;

  static Graph fromJson(const json& j) {
    Graph g;
    for (auto &node : j["nodes"]) {
      g.nodes.push_back({node["name"], node["terminal"]});
    }
    for (auto &edge : j["edges"]) {
      g.edges.push_back({edge["source"], edge["dest"]});
    }
    return g;
  }
};

std::string trim_numbers(const std::string& s) {
    size_t end_pos = s.find_last_not_of("0123456789");
    if (end_pos == std::string::npos)
        return s;
    return s.substr(0, end_pos + 1);
}

int main(int argc, char **argv) {
  // assume last arg is input json filename
  if (argc < 2) {
    std::cerr << "Usage: " << argv[0] << " [graphviz args] <json file>\n";
    std::cerr << "Example: " << argv[0] << " -Kdot -Tsvg -o graph.svg graph.json \n";
    return 1;
  }
  std::string filename = argv[argc - 1];
  argc--;
  std::ifstream i(filename);
  json j;
  i >> j;
  Graph jg = Graph::fromJson(j);
  // set up a graphviz context
  GVC_t *gvc = gvContext();

  // parse command line args - minimally argv[0] sets layout engine
  gvParseArgs(gvc, argc, argv);

  std::string color = "color";
  std::string label = "label";
  std::string fillcolor = "fillcolor";
  std::string style = "style";
  std::string graphName = "";

  Agraph_t *g = agopen(graphName.data(), Agundirected, 0);
  for (auto &node : jg.nodes) {
    if (!node.is_terminal)
        continue;
    auto* n = agnode(g, node.name.data(), 1);
    agsafeset(n, fillcolor.data(), "pink", "");
    agsafeset(n, style.data(), "filled", "");
  }
  for (auto &edge : jg.edges) {
    auto* source = agfindnode(g, edge.source.data());
    auto* target = agfindnode(g, edge.target.data());
    if (source == NULL) {
        source = agnode(g, edge.source.data(), 1);
    }
    if (target == NULL) {
        target = agnode(g, edge.target.data(), 1);
    }
    agedge(g, source, target, 0, 1);
    std::string trimmed_src = trim_numbers(agnameof(source));
    std::string trimmed_trg = trim_numbers(agnameof(target));
    agsafeset(source, label.data(), trimmed_src.data(), "");
    agsafeset(target, label.data(), trimmed_trg.data(), "");
  }

  // Set an attribute - in this case one that affects the visible rendering

  // Compute a layout using layout engine from command line args
  gvLayoutJobs(gvc, g);

  // Write the graph according to -T and -o options
  gvRenderJobs(gvc, g);

  // Free layout data
  gvFreeLayout(gvc, g);

  // Free graph structures
  agclose(g);

  // close output file, free context, and return number of errors
  return gvFreeContext(gvc);
}

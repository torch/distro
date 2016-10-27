package = "graph"
version = "scm-1"

source = {
   url = "git://github.com/torch/graph",
   tag = "master"
}

description = {
   summary = "Graph package for Torch",
   homepage = "https://github.com/torch/graph",
   license = "UNKNOWN"
}

dependencies = {
   "torch >= 7.0"
}

build = {
   type = "builtin",
   modules = {
    ['graph.init'] = 'init.lua',
    ['graph.graphviz'] = 'graphviz.lua',
    ['graph.Node'] = 'Node.lua',
    ['graph.Edge'] = 'Edge.lua'
   }
}

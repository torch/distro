package = "trepl"
version = "scm-1"

source = {
   url = "git://github.com/torch/trepl",
   branch = "master",
}

description = {
   summary = "An embedabble, Lua-only REPL for Torch.",
   detailed = [[
An embedabble, Lua-only REPL for Torch.
   ]],
   homepage = "https://github.com/torch/trepl",
   license = "BSD"
}

dependencies = {
   "torch >= 7.0",
   "penlight >= 1.1.0",
}

build = {
   type = "builtin",
   modules = {
      ['trepl.init'] = 'init.lua',
      ['trepl.colors'] = 'colors.lua',
      ['trepl.colorize'] = 'colorize.lua',
      ['readline'] = {
         sources = {'readline.c'},
         libraries = {'readline'}
      },
      ['treplutils'] = {
         sources = {'utils.c'},
      }
   },
   platforms = {
      windows = {
	     modules = {
		    ['readline'] = {
               sources = {'readline.c'},
			   defines = {"EDITLINE"},
               incdirs = {"../../install/include"},
               libdirs = {"../../install/lib"},
               libraries = {'libedit_static', 'User32'}
			}
		 }
	  }
   },
   install = {
      bin = {
         'th'
      }
   }
}

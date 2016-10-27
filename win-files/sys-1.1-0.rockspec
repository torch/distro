package = "sys"
version = "1.1-0"

source = {
   url = "git://github.com/torch/sys"
}

description = {
   summary = "A system library for Torch",
   detailed = [[
Provides system functionalities for Torch.
   ]],
   homepage = "https://github.com/torch/sys",
   license = "BSD"
}

dependencies = {
   "torch >= 7.0",
}

build = {
   type = "builtin",
   modules = {
      ['sys.init'] = 'init.lua',
      ['sys.fpath'] = 'fpath.lua',
      ['sys.colors'] = 'colors.lua',
      libsys = {
         sources = {
            "sys.c"
         }
      }
   }
}

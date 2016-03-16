s_//\([^$]*\)\$_(\1)$_g  # replace all C++ style comments (even nested ones)
:b                       # while loop
                         # remove nested comment blocks:
                         #   (foo(bar)baz) --> (foobarbaz)
s/(\([^()]*\)(\([^()]*\))\([^()]*\))/(\1\2\3)/
tb                       # EOF loop
s_(_/*_g                 # reverse the steps done by the preparation phase
s_)_*/_g                 # ...
s/\$/\n/g                # split lines that were previously joined
s/\\S/$/g                # replace escaped special characters
s/\\o/(/g                # ...
s/\\c/)/g                # ...
s/\\\(.\)/\1/g           # ...
s/CUDNNWINAPI/           /g         # remove API decl
s/^\#[^\n]*\n//g          # remove preprocessing
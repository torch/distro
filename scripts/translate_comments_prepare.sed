s/\\/\\\\/g  # escape current escape characters
s/\$/\\S/g   # write all occurrences of $ as \S
s/(/\\o/g    # replace open braces with \o
s/)/\\c/g    # replace closing braces with \c
s/$/$/       # add a $ sign to the end of each line
s_/\*_(_g    # replace the start of comments with (
s_\*/_)_g    # replace the end of comments with )

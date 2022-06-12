all

# Extend line length, since each sentence should be on a separate line.
rule 'MD013', :line_length => 99999

# Lists should be surrounded by blank lines - problematic in frontmatter
exclude_rule 'MD032'

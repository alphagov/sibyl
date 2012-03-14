:syntax region String   start=+"+  skip=+\\"+  end=+"+
:syntax region Comment  start="--" end="\n"
:syntax keyword Conditional if otherwise
:syntax keyword Keyword metadata step set go option reject outcome
:syntax include @Ruby syntax/ruby.vim
:syntax region rubySnip matchgroup=Snip start="{" end="}" contains=@Ruby

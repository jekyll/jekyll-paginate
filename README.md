# Jekyll::Paginate

Default pagination generator for Jekyll.

[![Build Status](https://secure.travis-ci.org/jekyll/jekyll-paginate.svg?branch=master)](https://travis-ci.org/jekyll/jekyll-paginate)

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-paginate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-paginate

## Usage

Once the gem is installed on your system, Jekyll will auto-require it. Just set the following configuration

    # this enables pagination
    paginate: 5
    
    # set the url pattern for pagination
    # if not set, the default is **/page:num**
    paginate_path: "blog/page:num/"

    # this removes a category from pagination
    # eg: any post with *category: 'toto'* or * categories: ['toto']
    # in front matter
    
    not_paginated_categories:
      - 'toto'

    # for multiple categories
    
    not_paginated_categories:
      - 'toto'
      - 'titi'

See also [Pagination documentation on Jekyll site](http://jekyllrb.com/docs/pagination/) for use in templates.

## Contributing

1. Fork it ( http://github.com/jekyll/jekyll-paginate/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

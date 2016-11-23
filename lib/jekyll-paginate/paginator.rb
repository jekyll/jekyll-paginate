module Jekyll
  module Paginate
    class Paginator

      attr_reader :type, :config, :payload, :site
      attr_reader :per_page, :template, :permalink

      def initialize(type, config, payload, site)
        @type    = type
        @config  = config
        @payload = payload
        @site    = site

        @per_page  = config['per_page'] || 10
        @template  = config['template'] || "_#{type}/index.html"
        @permalink = config['permalink'] || "#{type}/:num/"
      end

      def calculate_pages(documents)
        (documents.size.to_f / per_page.to_i).ceil
      end

      def template_source
        @template_source ||= if type.eql?('posts')
                               site.pages.find {|page| }
                             else
                               site.documents.find {|doc| }
                             end
      end

      def paginate
        # Read in the template page
        # Generate the Pages for each page based on per_page
        # Write to the permalink specified
      end

    end
  end
end

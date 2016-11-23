module Jekyll
  module Paginate
    class Pagination < Generator
      # This generator is safe from arbitrary code execution.
      safe true

      # This generator should be passive with regard to its execution
      priority :low

      DEFAULT_CONFIGURATION = {
        'posts' => {
          'per_page' => 10,
          'template' => 'index.html',
          'permalink' => '/page:num'
        }
      }

      # Generate paginated pages if necessary.
      #
      # site - The Site.
      #
      # Returns nothing.
      def generate(site)
        if pagination_enabled?(site)
          paginators(site).each do |paginator|
            paginator.paginate
          end
            Jekyll.logger.warn "Pagination:", "Pagination is enabled, but I couldn't find " +
            "an index.html page to use as the pagination template. Skipping pagination."
        end
      end

      # Upgrade the configuration from the old to the new.
      #
      # config - the configuration Hash to upgrade
      #
      # Example:
      #   paginate: 1
      #   paginate_path: /blog/:num
      #
      #     ... becomes:
      #
      #   pagination:
      #     posts:
      #       per_page: 1
      #       permalink:
      def with_upgraded_configuration(config)
        if config['paginate']
          Jekyll.logger.warn "Deprecation:", "The 'paginate' configuration is no longer used."
          config['pagination'] ||= {}
          config['pagination']['posts'] ||= {}
          config['pagination']['posts']['per_page'] ||= config.delete('paginate')
          config['pagination']['posts']['permalink'] ||= config.delete('paginate_path')
          config['pagination']['posts']['template'] ||= config.delete('paginate_path') !!!
        elsif config['pagination']
          config['pagination'] = Jekyll::Utils.deep_merge_hashes(
            DEFAULT_CONFIGURATION,
            config['pagination']
          )
        end
        config
      end

      def pagination_enabled?(site)
        site.config['paginate'] || site.config['pagination']
      end

      def paginators(site)
        payload = site.site_payload
        site.config['pagination'].map do |type, config|
          Paginator.new(type, config, payload, site)
        end
      end

      # Paginates the blog's posts. Renders the index.html file into paginated
      # directories, e.g.: page2/index.html, page3/index.html, etc and adds more
      # site-wide data.
      #
      # site - The Site.
      # page - The index.html Page that requires pagination.
      #
      # {"paginator" => { "page" => <Number>,
      #                   "per_page" => <Number>,
      #                   "posts" => [<Post>],
      #                   "total_posts" => <Number>,
      #                   "total_pages" => <Number>,
      #                   "previous_page" => <Number>,
      #                   "next_page" => <Number> }}
      def paginate(site, page)
        all_posts = site.site_payload['site']['posts'].reject { |post| post['hidden'] }
        pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)
        (1..pages).each do |num_page|
          pager = Pager.new(site, num_page, all_posts, pages)
          if num_page > 1
            newpage = Page.new(site, site.source, page.dir, page.name)
            newpage.pager = pager
            newpage.dir = Pager.paginate_path(site, num_page)
            site.pages << newpage
          else
            page.pager = pager
          end
        end
      end

      # Static: Fetch the URL of the template page. Used to determine the
      #         path to the first pager in the series.
      #
      # site - the Jekyll::Site object
      #
      # Returns the url of the template page
      def self.first_page_url(site)
        if page = Pagination.template_page(site)
          page.url
        else
          nil
        end
      end

      # Public: Find the Jekyll::Page which will act as the pager template
      #
      # site - the Jekyll::Site object
      #
      # Returns the Jekyll::Page which will act as the pager template
      def self.template_page(site)
        site.pages.select do |page|
          Pager.pagination_candidate?(site.config, page)
        end.sort do |one, two|
          two.path.size <=> one.path.size
        end.first
      end

    end
  end
end

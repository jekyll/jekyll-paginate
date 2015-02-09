require 'spec_helper'

RSpec.describe(Jekyll::Paginate::Pagination) do

  context "with absoulte permalink in index file" do
    before(:each) do
      @original_index_string = File.read(File.join(source_dir, 'index.html'))
    end
    after(:each) do
      File.open(File.join(source_dir, 'index.html'), 'w') { |f| f.write(@original_index_string) }
    end

    def rewrite_index(frontmatter_string)
      File.open(File.join(source_dir, 'index.html'), 'w') { |f| f.write("---\n#{frontmatter_string}\n---\nbody") }
    end

    let(:site) { build_site }

    it "paginated pages should not use absoulte permalink from index file" do
      rewrite_index("permalink: /")
      expect(site.pages.select {|page| page.url == "/"}.length).to eql(1)
    end
  end
end

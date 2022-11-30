require 'spec_helper'

RSpec.describe(Jekyll::Paginate::Pagination) do

  context "with the default posts filtering behavior **hidden: true** variable in front matter" do
    let(:site) { build_site }

    # this test needs a post with **hidden: true** in front matter
    it "filters posts with **hidden: false** in front matter" do
      expect(pagination_contains_hidden_post?(site)).to eql(false)
    end
  end

  context "with posts filtering by categories disabled" do
    let(:site) { build_site }

    # this test needs a post with **category: 'toto'** in front matter
    it "doesn't filter posts with **category: 'toto'** in front matter" do
      expect(pagination_contains_category_post?(site, 'toto')).to eql(true)
    end
  end

  context "with posts filtering by categories enabled for toto" do
    let(:site) { build_site({'not_paginated_categories' => ['toto']}) }

    # this test needs a post with **category: 'toto'** in front matter
    it "filters posts with **category: 'toto'** in front matter" do
      expect(pagination_contains_category_post?(site, 'toto')).to eql(false)
    end
  end

  context "with posts filtering by categories enabled for toto and titi" do
    let(:site) { build_site({'not_paginated_categories' => ['toto', 'titi']}) }

    # this test needs a post with **category: 'toto'** in front matter
    # this test needs a post with **category: 'titi'** in front matter
    it "filters posts with **category: 'toto'** and **category: 'titi'** in front matter" do
      expect(pagination_contains_category_post?(site, 'toto')).to eql(false)
      expect(pagination_contains_category_post?(site, 'titi')).to eql(false)
    end
  end


end

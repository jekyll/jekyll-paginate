require File.expand_path("../lib/jekyll/paginate", File.dirname(__FILE__))

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  def build_site(config = {})
    base = build_configs({
      'source'      => source_dir,
      'destination' => dest_dir,
      'paginate'    => 1
    })
    site = Jekyll::Site.new(site_configuration(
      {"paginate" => 1}.merge(config)
    ))
    site.process
    site
  end
end

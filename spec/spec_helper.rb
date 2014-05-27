require 'jekyll'
require File.expand_path("../lib/jekyll-paginate", File.dirname(__FILE__))

module JekyllTurnipSteps

  def source_dir(*files)
    File.join(TEST_DIR, *files)
  end

  def jekyll_output_file
    JEKYLL_COMMAND_OUTPUT_FILE
  end

  def jekyll_run_output
    File.read(jekyll_output_file)
  end

  def run_jekyll(args)
    system "#{JEKYLL_PATH} #{args} --trace > #{jekyll_output_file} 2>&1"
  end

  def slug(title)
    if title
      title.downcase.gsub(/[^\w]/, " ").strip.gsub(/\s+/, '-')
    else
      Time.now.strftime("%s%9N") # nanoseconds since the Epoch
    end
  end

  def location(folder, direction)
    if folder
      before = folder if direction == "in"
      after = folder if direction == "under"
    end
    [before || '.', after || '.']
  end

  def file_contents(path)
    File.open(path) do |file|
      file.readlines.join # avoid differences with \n and \r\n line endings
    end
  end

  def seconds_agnostic_datetime(datetime = Time.now)
    date, time, zone = datetime.to_s.split(" ")
    time = seconds_agnostic_time(time)
    [
      Regexp.escape(date),
      "#{time}:\\d{2}",
      Regexp.escape(zone)
    ].join("\\ ")
  end

  def seconds_agnostic_time(time)
    if time.is_a? Time
      time = time.strftime("%H:%M:%S")
    end
    hour, minutes, _ = time.split(":")
    "#{hour}:#{minutes}"
  end

  def file_content_from_hash(input_hash)
    matter_hash = input_hash.reject { |k, v| k == "content" }
    matter = matter_hash.map { |k, v| "#{k}: #{v}\n" }.join.chomp

    content = if input_hash['input'] && input_hash['filter']
      "{{ #{input_hash['input']} | #{input_hash['filter']} }}"
    else
      input_hash['content']
    end

    <<EOF
  ---
  #{matter}
  ---
  #{content}
EOF
  end

  step 'I have a blank site in ":path"' do |path|
    FileUtils.mkdir_p(path) unless File.exist?(path)
  end

  step 'I do not have a :path directory' do |path|
    File.directory?("#{TEST_DIR}/#{path}")
  end

  step 'I have an? :dir directory' do |dir|
    FileUtils.mkdir_p(dir)
  end

  # Like "I have a foo file" but gives a yaml front matter so jekyll actually processes it
  step 'I have an? ":file" page(?: with :key ":value")? that contains ":text"' do |file, key, value, text|
    File.open(file, 'w') do |f|
      f.write <<EOF
  ---
  #{key || 'layout'}: #{value || 'nil'}
  ---
  #{text}
EOF
    end
  end

  step 'I have an? ":file" file that contains ":text"' do |file, text|
    File.open(file, 'w') do |f|
      f.write(text)
    end
  end

  step 'I have an? :name :type that contains ":text"' do |name, type, text|
    folder = if type == 'layout'
      '_layouts'
    else
      '_theme'
    end
    destination_file = File.join(folder, name + '.html')
    destination_path = File.dirname(destination_file)
    unless File.exist?(destination_path)
      FileUtils.mkdir_p(destination_path)
    end
    File.open(destination_file, 'w') do |f|
      f.write(text)
    end
  end

  step 'I have an? ":file" file with content:' do |file, text|
    File.open(file, 'w') do |f|
      f.write(text)
    end
  end

  step 'I have the following (draft|page|post)s?(?: (in|under) ":folder")?:' do |status, direction, folder, table|
    table.hashes.each do |input_hash|
      title = slug(input_hash['title'])
      ext = input_hash['type'] || 'textile'
      before, after = location(folder, direction)

      case status
      when "draft"
        dest_folder = '_drafts'
        filename = "#{title}.#{ext}"
      when "page"
        dest_folder = ''
        filename = "#{title}.#{ext}"
      when "post"
        parsed_date = Time.xmlschema(input_hash['date']) rescue Time.parse(input_hash['date'])
        dest_folder = '_posts'
        filename = "#{parsed_date.strftime('%Y-%m-%d')}-#{title}.#{ext}"
      end

      path = File.join(before, dest_folder, after, filename)
      File.open(path, 'w') do |f|
        f.write file_content_from_hash(input_hash)
      end
    end
  end

  step 'I have a configuration file with "(.*)" set to "(.*)"' do |key, value|
    File.open('_config.yml', 'w') do |f|
      f.write("#{key}: #{value}\n")
    end
  end

  step 'I have a configuration file with:' do |table|
    File.open('_config.yml', 'w') do |f|
      table.hashes.each do |row|
        f.write("#{row["key"]}: #{row["value"]}\n")
      end
    end
  end

  step 'I have a configuration file with "([^\"]*)" set to:' do |key, table|
    File.open('_config.yml', 'w') do |f|
      f.write("#{key}:\n")
      table.hashes.each do |row|
        f.write("- #{row["value"]}\n")
      end
    end
  end

  step 'I have fixture collections' do
    FileUtils.cp_r File.join(JEKYLL_SOURCE_DIR, "test", "source", "_methods"), source_dir
  end

  ##################
  #
  # Changing stuff
  #
  ##################

  step 'I run jekyll(.*)' do |args|
    status = run_jekyll(args)
    if args.include?("--verbose") || ENV['DEBUG']
      puts jekyll_run_output
    end
  end

  step 'I change "(.*)" to contain "(.*)"' do |file, text|
    File.open(file, 'a') do |f|
      f.write(text)
    end
  end

  step 'I delete the file "(.*)"' do |file|
    File.delete(file)
  end

  step 'the (.*) directory should +exist' do |dir|
    assert File.directory?(dir), "The directory \"#{dir}\" does not exist"
  end

  step 'the (.*) directory should not exist' do |dir|
    assert !File.directory?(dir), "The directory \"#{dir}\" exists"
  end

  step 'I should see "(.*)" in "(.*)"' do |text, file|
    assert_match Regexp.new(text, Regexp::MULTILINE), file_contents(file)
  end

  step 'I should see exactly "(.*)" in "(.*)"' do |text, file|
    assert_equal text, file_contents(file).strip
  end

  step 'I should not see "(.*)" in "(.*)"' do |text, file|
    assert_no_match Regexp.new(text, Regexp::MULTILINE), file_contents(file)
  end

  step 'I should see escaped ":text" in ":file"' do |text, file|
    assert_match Regexp.new(Regexp.escape(text)), file_contents(file)
  end

  step 'the ":file" file should exist' do |file|
    assert File.file?(file), "The file \"#{file}\" does not exist"
  end

  step 'the ":file" file should not exist' do |file|
    assert !File.exist?(file), "The file \"#{file}\" exists"
  end

  step 'I should see today\'s time in ":file"' do |file|
    assert_match Regexp.new(seconds_agnostic_time(Time.now)), file_contents(file)
  end

  step 'I should see today\'s date in ":file"' do |file|
    assert_match Regexp.new(Date.today.to_s), file_contents(file)
  end

  step 'I should see ":text" in the build output' do |text|
    assert_match Regexp.new(text), jekyll_run_output
  end
end

TMP_DIR = File.expand_path(File.join('..', '..', 'tmp', 'jekyll'), File.dirname(__FILE__))
JEKYLL_COMMAND_OUTPUT_FILE = File.join(File.dirname(TMP_DIR), 'jekyll_output.txt')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include JekyllTurnipSteps
  config.before(:type => :feature) do
    FileUtils.mkdir_p(TMP_DIR) unless File.exist?(TMP_DIR)
    Dir.chdir(TMP_DIR)
  end
  config.after(:type => :feature) do
    FileUtils.rm_rf(TMP_DIR)   if File.exists?(TMP_DIR)
    FileUtils.rm(JEKYLL_COMMAND_OUTPUT_FILE) if File.exists?(JEKYLL_COMMAND_OUTPUT_FILE)
  end

  def test_dir(*subdirs)
    File.join(File.dirname(__FILE__), *subdirs)
  end

  def dest_dir(*subdirs)
    test_dir('dest', *subdirs)
  end

  def source_dir(*subdirs)
    test_dir('source', *subdirs)
  end

  def build_configs(overrides, base_hash = Jekyll::Configuration::DEFAULTS)
    Jekyll::Utils.deep_merge_hashes(base_hash, overrides)
  end

  def site_configuration(overrides = {})
    build_configs({
      "source"      => source_dir,
      "destination" => dest_dir
    }, build_configs(overrides))
  end

  def build_site(config = {})
    site = Jekyll::Site.new(site_configuration(
      {"paginate" => 1}.merge(config)
    ))
    site.process
    site
  end
end

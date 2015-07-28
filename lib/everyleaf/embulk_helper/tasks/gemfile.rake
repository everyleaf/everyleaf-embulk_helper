desc "Generate gemfiles to test this plugin with released Embulk versions (since MIN_VERSION)"
task :gemfiles do
  min_version = Gem::Version.new(ENV["MIN_VERSION"] || "0.6.12")
  puts "Generate Embulk gemfiles from #{min_version} to latest"

  embulk_tags = JSON.parse(open("https://api.github.com/repos/embulk/embulk/tags").read)
  embulk_versions = embulk_tags.map{|tag| Gem::Version.new(tag["name"][/v(.*)/, 1])}
  latest_version = embulk_versions.max

  root_dir = Pathname.new(File.expand_path("../", $0))
  gemfiles_dir = root_dir.join("gemfiles")
  Dir[gemfiles_dir.join("embulk-*")].each{|f| File.unlink(f)}
  erb_gemfile = ERB.new(gemfiles_dir.join("template.erb").read)

  embulk_versions.sort.each do |version|
    next if version < min_version
    File.open(gemfiles_dir.join("embulk-#{version}"), "w") do |f|
      f.puts erb_gemfile.result(binding())
    end
  end
  File.open(gemfiles_dir.join("embulk-latest"), "w") do |f|
    version = "> #{min_version}"
    f.puts erb_gemfile.result(binding())
  end
  puts "Updated Gemfiles #{min_version} to #{latest_version}"

  versions = Pathname.glob(gemfiles_dir.join("embulk-*")).map(&:basename)
  erb_travis = ERB.new(root_dir.join(".travis.yml.erb").read, nil, "-")
  File.open(root_dir.join(".travis.yml"), "w") do |f|
    f.puts erb_travis.result(binding())
  end
  puts "Updated .travis.yml"
end


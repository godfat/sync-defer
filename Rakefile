
require "#{dir = File.dirname(__FILE__)}/task/gemgem"
Gemgem.dir = dir

($LOAD_PATH << File.expand_path("#{Gemgem.dir}/lib")).uniq!

desc 'Generate gemspec'
task 'gem:spec' do
  Gemgem.spec = Gemgem.create do |s|
    s.name    = 'sync-defer'
    s.version = '0.9.3'

    %w[].each{ |g| s.add_runtime_dependency(g) }
  end

  Gemgem.write
end

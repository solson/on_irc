require 'rake'

$LOAD_PATH.unshift('lib')

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "on_irc"
    gemspec.summary = "An event driven IRC library with an easy to use DSL"
    gemspec.description = "An event driven IRC library with an easy to use DSL"
    gemspec.email = "scott@solson.me"
    gemspec.homepage = "http://github.com/tsion/on_irc"
    gemspec.authors = ["Scott Olson"]
    gemspec.files = FileList["[A-Z]*", "lib/**/*"]

    gemspec.add_dependency "eventmachine"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

Jeweler::GemcutterTasks.new


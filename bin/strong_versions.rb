require 'optparse'

require 'strong_versions'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: strong_versions [options]"

  opts.on("-a", "--auto-correct", "Auto-correct (use with caution)") do |v|
    options[:auto_correct] = true
  end
end.parse!

def dependencies
  StrongVersions::DependencyFinder.new.dependencies
end

config_path = Bundler.root.join('.strong_versions.yml')
config = StrongVersions::Config.new(config_path)
validated = StrongVersions::Dependencies.new(dependencies).validate!(
  except: config.exceptions,
  on_failure: 'warn',
  auto_correct: options[:auto_correct]
)

revalidated = false
revalidated = StrongVersions::Dependencies.new(dependencies).validate!(
  except: config.exceptions,
  on_failure: 'warn',
  auto_correct: false
) if options[:auto_correct]

exit 0 if validated or revalidated
exit 1


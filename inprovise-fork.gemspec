require File.join(File.dirname(__FILE__), 'lib/inprovise/fork/version')

Gem::Specification.new do |gem|
  gem.authors       = ["Martin Corino"]
  gem.email         = ["mcorino@remedy.nl"]
  gem.description   = %q{Fork extension for Inprovise scripts}
  gem.summary       = %q{Simple, easy and intuitive virtual machine provisioning}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "inprovise-fork"
  gem.require_paths = ["lib"]
  gem.version       = Inprovise::Fork::VERSION
  gem.add_dependency('inprovise')
  gem.post_install_message = ''
end

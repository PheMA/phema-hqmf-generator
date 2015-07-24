#require "bundler/gem_tasks"
require 'rake/testtask'

import 'lib/tasks/phema.rake'

Rake::TestTask.new(:test_unit) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*-test.rb']
  t.verbose = true
end

task :test => [:test_unit] do
  system("open coverage/index.html")
end

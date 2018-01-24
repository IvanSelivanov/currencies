require 'resque/tasks'

task "resque:setup" => :environment do
  puts 'in setup'
end
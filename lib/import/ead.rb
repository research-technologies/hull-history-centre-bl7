# Load the concerns first
concerns_dir = File.join(File.dirname(__FILE__), 'concerns')
Dir[File.join(concerns_dir, '**', '*.rb')].each do |file|
  require file
end

Dir[File.join(File.dirname(__FILE__), '**', '*.rb')].each do |file|
  require file
end

module Ead
end

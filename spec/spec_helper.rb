# Load support files
RSpec.configure do |_config|
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
end

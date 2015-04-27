RSpec.configure do |c|
  c.filter_run_including :focus => true
  c.run_all_when_everything_filtered = true
end

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end


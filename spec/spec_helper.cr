require "spec"
require "webmock"
require "../src/packlink"

def read_fixture(file : String)
  path = "#{__DIR__}/fixtures/#{file}.json"
  if File.exists?(path)
    File.read(path)
  else
    raise Exception.new("Fixture #{file} does not exist.")
  end
end

Spec.after_each do
  WebMock.reset
  Packlink::Config.api_key = nil
  Packlink::Config.open_timeout = 60
  Packlink::Config.read_timeout = 60
  Packlink::Config.environment = "sandbox"
end

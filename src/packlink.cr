require "json"
require "json_mapping"
require "big"
require "big/json"
require "http/client"
require "wordsmith"
require "./packlink/aliases"
require "./packlink/mixins/**"
require "./packlink/base"
require "./packlink/path"
require "./packlink/**"

struct Packlink
  def self.configure
    yield(Packlink::Config)
  end
end

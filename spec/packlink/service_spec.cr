require "../spec_helper"

def test_service
  Packlink::Service.from_json(read_fixture("services/all-response"))
end

describe Packlink::Service do
  before_each do
    configure_test_api_key
  end
end

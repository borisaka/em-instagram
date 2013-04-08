require File.expand_path('../spec_helper', __FILE__)

describe EventMachine::Instagram::Request do

  before :each do

  end

  it "should call the succeed callback passing the data as an argument with a valid request" do
    body = "{\"data\":{\"mykey\":\"myvalue\"}}"
    conn = double("connection")
    conn.stub(:errback)
    conn.stub(:callback)
    response_header = double('rheader')
    response_header.stub(:status => 200)
    response = double('response')
    response.stub(:response_header => response_header)
    response.stub(:response => body)
    req = EventMachine::Instagram::Request.new(conn)
    req.should_receive(:succeed).with({"mykey" => "myvalue"})
    req.send(:process_instagram_response, response)
  end

  it "should call the fail callback if it receives invalid JSON" do
    body = "<html><body>There was an error</body></html>"
    conn = double("connection")
    conn.stub(:errback)
    conn.stub(:callback)
    response_header = double('rheader')
    response_header.stub(:status => 500)
    response = double('response')
    response.stub(:response_header => response_header)
    response.stub(:response => body)
    req = EventMachine::Instagram::Request.new(conn)
    req.should_receive(:fail).with("Invalid JSON returned")
    req.send(:process_instagram_response, response)
  end
end
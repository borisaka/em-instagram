require File.expand_path('../spec_helper', __FILE__)

describe EventMachine::Instagram::Server do

  before :all do
    module EventMachine
      class ServerStub
        include Instagram::Server
        attr_accessor :http_request_method, :http_query_string, :updates, :http_post_content
      end
    end
  end

  before :each do
    @response = double("response")
    EventMachine::DelegatedHttpResponse.stub(:new => @response)
  end

  it "should create a delayed response to be able to keep processing" do
    @response.should_receive :send_response
    @response.should_receive :status=
    @response.should_receive :content=
    EventMachine::ServerStub.new.process_http_request
  end

  it "should respond with a 200 okay to a get request and set the hub challenge parameter as the contents" do
    @response.should_receive :send_response
    @response.should_receive(:status=).with(200)
    @response.should_receive(:content=).with(["banana"])
    server = EventMachine::ServerStub.new
    server.http_request_method = "GET"
    server.http_query_string = "hub.challenge=banana"
    server.process_http_request
  end

  it "should respond with a 200 okay to a get request and set the content as blank if no challenge is provided" do
    @response.should_receive :send_response
    @response.should_receive(:status=).with(200)
    @response.should_receive(:content=).with([])
    server = EventMachine::ServerStub.new
    server.http_request_method = "GET"
    server.http_query_string = ''
    server.process_http_request
  end

  it "should respond with a 202 and push the json to the update queue when receiving a post" do
    json = [{'banana' => "fun"}, {'apple' => "also fun"} ]
    @response.should_receive :send_response
    @response.should_receive(:status=).with(202)
    @response.should_receive(:content=).with("Accepted")
    server = EventMachine::ServerStub.new
    server.stub(:valid_instagram_response? => true)
    server.http_request_method = "POST"
    server.http_post_content = json.to_json
    server.updates = []
    server.process_http_request
    server.updates.should eql(json)
  end

  it "should respond with a 405 to a request type it doesn't recognise" do
    @response.should_receive :send_response
    @response.should_receive(:status=).with(405)
    @response.should_receive(:content=).with('Method Not Allowed')
    server = EventMachine::ServerStub.new
    server.http_request_method = "DELETE"
    server.process_http_request
  end
end


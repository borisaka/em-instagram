require File.expand_path('../../spec_helper', __FILE__)

describe EventMachine::Instagram::Subscriptions do
  before :each do
    @instagram_url = "https://api.instagram.com/v1/subscriptions"
    logger = Logger.new("/dev/null") # OS dependent here!
    client_id = "11111111"
    client_secret = "22222222"
    @callback_url = "myserver.vm/instagram_handler"
    @instagram = EventMachine::Instagram.new(:logger => logger, :client_id => client_id, :client_secret => client_secret, :callback_url => @callback_url)
    @expected_body = {:client_id=>client_id, :client_secret=>client_secret}
    @http_stub = double("http_stub")
    @request = double("request")
    @request.stub(:errback => double("errback"))
    @request.stub(:callback => double("callback"))
    EventMachine::HttpRequest.stub(:new => @http_stub)
  end

  it "should send a media subscription when asked to subscribe to a topic" do
    args = {:banana => "fun"}
    media_args = {:aspect => 'media', :callback_url => @callback_url}
    EventMachine::HttpRequest.should_receive(:new).with(@instagram_url).and_return(@http_stub)
    @http_stub.should_receive(:post).with(:body=> @expected_body.merge(args).merge(media_args)).and_return(@request)
    @instagram.subscribe_to(args)
  end

  it "should be able to get a list of subscriptions" do
    args = {:banana => "fun"}
    EventMachine::HttpRequest.should_receive(:new).with(@instagram_url).and_return(@http_stub)
    @http_stub.should_receive(:get).with(:query=> @expected_body.merge(args)).and_return(@request)
    @instagram.subscriptions(args)
  end

  it "should be able to unsubscribe from a subscription" do
    args = {:banana => "fun"}
    EventMachine::HttpRequest.should_receive(:new).with(@instagram_url).and_return(@http_stub)
    @http_stub.should_receive(:delete).with(:query=> @expected_body.merge(args)).and_return(@request)
    @instagram.unsubscribe(args)
  end

  it "should push subscriptions onto a queue and then trigger the queue" do
    queue = []
    @instagram.send(:instance_variable_set, :@subscription_queue, queue)
    @instagram.should_receive(:subscribe_next)
    @instagram.subscribe(:random => "json")
    queue.should include(:random => "json")
  end

  it "should pop items off the queue until there are none left" do
    queue = [{:first_json => "1"}, {:second => 2}, {3 => :four}]
    @instagram.should_receive(:subscribe_to).with(*queue).ordered
    @instagram.subscribe_to(*queue)
  end
end
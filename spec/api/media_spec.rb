require File.expand_path('../../spec_helper', __FILE__)

describe EventMachine::Instagram::Media do
  before :each do
    @instagram_url = "https://api.instagram.com/v1/"
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

  it "should post basic media" do
    media_object = 2
    EventMachine::HttpRequest.should_receive(:new).with(@instagram_url + "media/#{media_object}").and_return(@http_stub)
    @http_stub.should_receive(:get).and_return(@request)
    @instagram.media(media_object)
  end

  it "should be able to search on tags" do
    tag = "banana"
    EventMachine::HttpRequest.should_receive(:new).with(@instagram_url + "tags/#{tag}/media/recent").and_return(@http_stub)
    @http_stub.should_receive(:get).and_return(@request)
    @instagram.media_by_tag(tag)
  end

  it "should be able to search on geographies" do
    geo = "banana_tree"
    EventMachine::HttpRequest.should_receive(:new).with(@instagram_url + "geographies/#{geo}/media/recent").and_return(@http_stub)
    @http_stub.should_receive(:get).and_return(@request)
    @instagram.media_by_geography(geo)
  end

  it "should use the correct callbacks with the fetch geography method" do
    geo = "banana_tree"
    @instagram.should_receive(:media_by_geography).and_return(@request)
    @request.should_receive(:callback) do |&callback_args|
      queue = double("queue")
      @instagram.send(:instance_variable_set, :@update_queue, queue)
      queue.should_receive(:push).with({:data => "geo"})
      callback_args.call([{:data => "geo"}])
    end
    @instagram.fetch_geography("banana_tree")
  end

  it "should use the correct callbacks with the fetch tags method" do
    geo = "banana_tree"
    @instagram.should_receive(:media_by_tag).and_return(@request)
    @request.should_receive(:callback) do |&callback_args|
      queue = double("queue")
      @instagram.send(:instance_variable_set, :@update_queue, queue)
      queue.should_receive(:push).with({:data => "geo"})
      callback_args.call([{:data => "geo"}])
    end
    @instagram.fetch_tag("banana_tree")
  end
end
require File.expand_path('../spec_helper', __FILE__)

describe EventMachine::Instagram do

  before :each do
    logger = Logger.new("/dev/null") # OS dependent here!
    client_id = "11111111"
    client_secret = "22222222"
    @callback_url = "myserver.vm/instagram_handler"
    @instagram = EventMachine::Instagram.new(:logger => logger, :client_id => client_id, :client_secret => client_secret, :callback_url => @callback_url)
  end

  it "should dispatch a fetch request to the geography API when asked for a geo" do
    object = {'object' => "geography", "object_id" => 'banana'}
    @instagram.should_receive(:fetch_geography).with("banana")
    @instagram.fetch(object)
  end

  it "should dispatch a fetch request to the tags API when asked for a tag" do
    object = {'object' => "tag", "object_id" => 'banana'}
    @instagram.should_receive(:fetch_tag).with("banana")
    @instagram.fetch(object)
  end

  it "should execute the provided stream block to all streams when it recieves a new notification of content" do
    call_check = double("checker")
    call_check_two = double("checker")
    call_check.should_receive(:called).with("banana")
    call_check_two.should_receive(:called).with("banana")
    @instagram.stream{|note| call_check.called(note)}
    @instagram.stream{|note| call_check_two.called(note)}
    @instagram.receive_notification("banana")
  end

  it "should execute anything put onto the update queue and keep the pop waiting for more data" do
    call_check = double("checker")
    call_check.should_receive(:called).with("banana").twice
    @instagram.on_update{|u| call_check.called(u)}
    EventMachine.run do
      @instagram.update("banana")
      @instagram.update("banana")
      EventMachine.next_tick{EventMachine.stop_event_loop}
    end
  end

  it "should not throw exceptions if the logger is not present" do
    @instagram = EventMachine::Instagram.new(:client_id => '1', :client_secret => '2', :callback_url => @callback_url)
    expect{ @instagram.subscribe_next}.to_not raise_error
  end
end
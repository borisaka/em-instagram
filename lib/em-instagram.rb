require File.expand_path('../em-instagram/request', __FILE__)
require File.expand_path('../em-instagram/server', __FILE__)
require File.expand_path('../em-instagram/api/subscriptions', __FILE__)
require File.expand_path('../em-instagram/api/media', __FILE__)
require File.expand_path('../em-instagram/proxy_logger', __FILE__)

module EventMachine
  class Instagram
    include Subscriptions
    include Media

    BASE_URI = 'https://api.instagram.com'
    PORT = 443

    attr_reader :default_params, :host, :port, :server, :logger, :subscription_queue, :update_callback, :callback_url

    def initialize(options = nil)
      @host, @port, @server = [options[:host], options[:port], options[:server]]
      @subscription_queue = EventMachine::Queue.new
      @update_queue = EventMachine::Queue.new
      @callback_url = options[:callback_url]
      @default_stream = Proc.new{|update| self.fetch update}
      self.logger = options[:logger]
      @default_params = {:client_id => options[:client_id], :client_secret => options[:client_secret]}
      update

    end

    def fetch(update)
      case update['object']
      when 'geography'
        fetch_geography update['object_id']
      when 'tag'
        fetch_tag update['object_id']
      end
    end

    def logger
      return @logger if @logger
      ProxyLogger.new
    end

    def logger=(logger)
      @logger = logger
    end

    def stream(&block)
      @streams ||= []
      @streams << block
    end

    def on_update(&block)
      @update_callback = block
    end

    def update(data = nil)
      @update_queue << data if data
      @update_queue.pop do |item|
        if @update_callback
          @update_callback.call(item)
        else
          self.logger.debug(item)
        end
        EventMachine::next_tick { update }
      end
    end

    def receive_notification(data)
      stream_set = @streams.nil? ? [@default_stream] : @streams
      stream_set.each { |stream| stream.call(data) }
    end

    def request(method, path, options = {})
      url = URI.join(BASE_URI, path).to_s
      Request.new EventMachine::HttpRequest.new(url).send(method, options)
    end

    def start_server(&block)
      @host ||= '0.0.0.0'
      @port ||= 8080
      @server ||= Server
      EventMachine.start_server(host, port, server) do |connection|
        connection.subscriber = self
      end
    end
  end
end

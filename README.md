# Eventmachine Instagram

This gem provides an interface to the Instagram API which uses EventMachine to interface with it. It is designed for use inside a larger EventMachine based application, and to make the API requests without blocking your reactor.

## Installation

If using Bundler, add it to your Gemfile

    gem 'em-instagram'

If not, just install the gem and require it in your source.

## Usage

By default, em-instagram ships with a basic EventMachine web server with it. This allows you to process the callbacks from the API when you subscribe. We recommend that you replace the 'default' server with one of your own as soon as possible, as this is only provided to make initial development easier.

To set it up, instantiate an EventMachine::Instagram instance

    instagram_args = {
      :client_id => 'xxxxx',
      :client_secret => "xxxxx",
      :callback_url => "www.example.com"
    }
    instagram_connection = EventMachine::Instagram.new(instagram_args)
    instagram_connection.on_update{|media| puts media.inspect}

    EventMachine.run do
      instagram_connection.start_server
    end

The basic arguments that the connection requires is the :client_id, :client_secret and :callback_url. The callback_url is the url of the server that this client is running on. By default, the provided server will just intercept any request aimed at the route, but if you define your own server (more on that later), you can alter how it behaves to different url's.

You also need to define an update block. This block is called whenever new media is returned by Instagram, with the serialized JSON from the Instagram API.

Finally, we wrap the server in an EventMachine run block, and boot it up. If your app is already running inside a reactor, there's no need to wrap this code in EM.run.

## Configuration

### Logging

You can pass a logger into the instagram args. This logger must expect a method called "debug", and will be passed debugging information. For an example of how to add a logger to the basic handler, using the Ruby default logger

    require 'logger'
    logger = Logger.new('log/instagram.log')
    instagram_args = {
      :logger => logger,
      :client_id => 'xxxxx',
      :client_secret => "xxxxx",
      :callback_url => "www.example.com"
    }
    instagram_connection = EventMachine::Instagram.new(instagram_args)

###  Custom notification behaviour

The way the Instagram streaming API works is that it will post you notifications of new content. The default behaviour of em-instagram is to immediately 'fetch' that content and pass it into the update block provided by you. You can change this by calling stream on the connection object, and passing a block. This can be called multiple times, and each time, it will push a new block onto the stack. Whenever a notification comes in, every block in the stack will be called with that notification as an argument.

    instagram_connection = EventMachine::Instagram.new(instagram_args)
    instagram_connection.stream {|notification| instagram_connection.fetch notification } #preserve original functionality
    instagram_connection.stream {|notification| my_outside_instance.notify(notification)}
    instagram_connection.on_update{|media| puts media.inspect}

### Altering the default server listening addresses

By default, the provided server listens to 0.0.0.0 at port 8080. To change this, you can pass :port and :host to the initializer.

    instagram_args = {
      :port => 80,
      :host => "myserver.vm",
      :client_id => 'xxxxx',
      :client_secret => "xxxxx",
      :callback_url => "www.example.com"
    }
    instagram_connection = EventMachine::Instagram.new(instagram_args)

# Altering the default server

The server provided is deliberately very sparse. It assumes that all requests incoming are instagram requests and treats them accordingly. It is not designed to be used in a production environment, only to allow you to start developing until you know enough about your architecture to develop your own server. For my use of this gem, I wrote a server based off [evma_httpserver](https://github.com/eventmachine/evma_httpserver). Pass it in with the :server argument to the initializer.

    class MyHttpServer < EM::Connection
      include EM::HttpServer

      def process_http_request
        puts "Got a request to #{@http_request_uri}
      end
    end

    instagram_args = {
      :server => MyHttpServer,
      :port => 80,
      :host => "myserver.vm",
      :client_id => 'xxxxx',
      :client_secret => "xxxxx",
      :callback_url => "www.example.com"
    }
    instagram_connection = EventMachine::Instagram.new(instagram_args)
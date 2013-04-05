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

The basic arguments that the instagram connection requires is the client_id, client_secret and callback_url. The callback_url is the url of the server that this client is running on. By default, the provided server will just intercept any request aimed at the route, but if you define your own server (more on that later), you can alter how it behaves to different url's.

You also need to define an update block. This block is called whenever new media is returned by Instagram, with the serialized JSON from the Instagram API.

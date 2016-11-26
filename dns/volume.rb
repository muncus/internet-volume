#!/usr/bin/env ruby2.0

require 'rubygems'
require 'bundler/setup'

require 'adafruit/io'
require 'optparse'
require 'rubydns'
require 'yaml'

$UPSTREAM = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 53], [:tcp, "8.8.8.8", 53]])
Name = Resolv::DNS::Name
IN = Resolv::DNS::Resource::IN

# NB: the meat here is all in celluloid/dns/server, can probably use that instead.
class VolumeControlledDnsServer < RubyDNS::RuleBasedServer
  # Dns resolution is controlled by an external 'volume' concept.
  # noisy sites are dropped sooner.

  # TODO: this hash needs some restructuring.
  # need a way to glob everything for opt in.
  # split to explicit allow/deny lists?
  @@SITES = {
    10 => ['facebook.com', 'instagram.com', 'twitter.com'],
     9 => ['pinterest.com', 'tumblr.com'],
     1 => ['wikipedia.org'],
  }
  @@SITES.default = []

  attr_accessor :aio_feed_key
  attr_reader :check_interval
  attr_reader :aio_key

  def aio_key=(new_key)
    @aio_client = Adafruit::IO::Client.new(key: new_key)
    @aio_key = new_key
  end

  def check_interval=(new_val)
    @check_interval = new_val
    @timer = self.every(new_val) { self.fire(:check_volume) }
  end

  def initialize(options = {})
    super(options)
    @aio_client = nil
    @current_volume = 10
    self.check_interval = (5 * 60)
    self.aio_feed_key = 'internet-volume'

    on(:check_volume) do 
      @logger.info("checking volume.")
      @current_volume = Integer(
          @aio_client.feeds.retrieve(self.aio_feed_key).last_value)
      @logger.info("volume: %s" % [@current_volume])
    end
  end

  # Should we answer this query, or squelch it?
  def squelch?(query)
    for i in @current_volume+1..11
      for site in @@SITES[i]
        if query.to_s.include?(site)
          return true
        end
      end
    end
    return false
  end

  def process(name, resource_class, transaction)
    if squelch?(transaction.question)
      transaction.fail!(:NXDomain)
    else
      transaction.passthrough!($UPSTREAM)
    end
  end
end


s = VolumeControlledDnsServer.new(listen: [[:udp, "0.0.0.0", 5300]])

# parse some opts, call accessors.
OptionParser.new do |opts|
  opts.on('-k', '--aio-key [KEY]', String,
          "AdafruitIO key, for accessing data feeds.") do |v|
    s.aio_key = v
  end
  opts.on('-f', '--feed-key [STR]', String,
          "AdafruitIO feed key.") do |v|
    s.aio_feed_key = v
  end
  opts.on('-i', '--interval [SECS]', Integer,
          "Interval to check for volume level updates, in seconds.") do |v|
    s.check_interval = v
  end
end.parse!

s.run
sleep

#!/usr/bin/env ruby2.0
# Server side of muni display. Serves simple number of mins to next train.
# Configuration file maps a url path to a set of nextbus query options. 
# see the full nextbus api spec linked from README.md for available options.
require 'rubygems'
require 'bundler/setup'

require 'sinatra'

set :bind, '0.0.0.0'
disable :show_exceptions

get '*' do |p|
  status 451
  headers \
    'X-filtered-by' => "Internet Volume Control 1.0"
  return
  #body "This url has been filtered by Internet Volume Control."
end

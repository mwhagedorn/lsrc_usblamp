#!/usr/bin/env ruby
require "rubygems"
require "#{File.dirname(__FILE__)}/usb_lamp"


lamp = UsbLamp.new
#assumes red, blue, or green
lamp.send(ARGV[0].to_sym)

# Include files
require File.dirname(__FILE__) + '/clockworkd/cronline'
require File.dirname(__FILE__) + '/clockworkd/event'
require File.dirname(__FILE__) + '/clockworkd/worker'
require File.dirname(__FILE__) + '/clockworkd/command'

unless 1.respond_to?(:seconds) 
  class Numeric
  	def seconds; self; end
  	alias :second :seconds

  	def minutes; self * 60; end
  	alias :minute :minutes

  	def hours; self * 3600; end
  	alias :hour :hours

  	def days; self * 86400; end
  	alias :day :days
  end
end
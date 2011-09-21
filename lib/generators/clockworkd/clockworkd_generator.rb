require 'rails/generators'
require 'rails/generators/migration'

class ClockworkdGenerator < Rails::Generators::Base

  include Rails::Generators::Migration
  
  def self.source_root
     @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end

  def create_script_file
    template 'script', 'script/clockworkd'
    chmod 'script/clockworkd', 0755
  end

  def create_clockworkd_file
    template 'clockworkd.yml', 'config/clockworkd.yml'
  end

end

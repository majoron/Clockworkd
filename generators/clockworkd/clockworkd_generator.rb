class ClockworkdGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  
  def manifest
    record do |m|
      m.template 'script', 'script/clockworkd', :chmod => 0755
      m.template 'clockworkd.yml', 'config/clockworkd.yml'
    end
  end
  
  
end

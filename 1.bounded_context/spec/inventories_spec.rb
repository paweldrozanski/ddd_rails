require 'spec_helper'

path = Rails.root.join('inventories/spec')
Dir.glob("#{path}/**/*_spec.rb") do |file|
  require file
end

module I19
  def self.gem_path
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end

require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'term/ansicolor'

require "i19/version"
require "i19/logging"
require "i19/commands"
require "i19/scanners/pattern_scanner"
require "i19/scanners/pattern_with_default_scanner"

module I19
  def self.config
    # https://github.com/glebm/i18n-tasks/blob/master/config/i18n-tasks.yml
    # HashWithIndifferentAccess.new({
    #   search:{
    #     paths: ['app/', 'lib/'],
    #     relative_roots: ['app/views'],
    #     exclude: ["*.jpg", "*.png", "*.gif", "*.svg", "*.ico", "*.eot", "*.ttf", "*.woff", "*.pdf"],
    #     include: ["*.rb", "*.html.slim"],
    #     ignore_lines: ["^\\s*[#/](?!\\si18n-tasks-use)"]
    #   }
    # })
    #
    #this is the place where we can read yml files and merge them with the defaults, etc, etc
    @@config ||= HashWithIndifferentAccess.new({
      path: './app',
      locales_path: 'config/locales',
      i19_yaml_file_name: 'i19',
    })
  end

  def self.gem_path
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
end

require 'fileutils'
require 'yaml'
# require 'yaml/encoding'
require 'terminal-table'
require 'term/ansicolor'

require 'active_model'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'

require "i19/version"
require "i19/logging"
require "i19/commands"
require "i19/key"
require "i19/locales"
require "i19/merger"
require "i19/scanners/pattern_scanner"
require "i19/scanners/pattern_with_default_scanner"

# coding: utf-8
module I19::Logging
  class Event
    LEVEL = {
      info:    Term::ANSIColor.green("info"),
      warn:    Term::ANSIColor.yellow("warn"),
      error:   Term::ANSIColor.red("error"),
      success: Term::ANSIColor.green("success"),
    }.freeze

    attr_accessor :type, :level, :data, :message
    def initialize(args = {})
      @type    = args[:type]
      @level   = args[:level]
      @data    = args[:data]
      @message = args[:message]
    end

    def to_row
      _data = data.try(:to_log) || data.to_s
      [level, message, _data]
    end
  end

  extend self

  def event_log
    @event_log ||= []
  end

  def print_event_log
    event_log.group_by(&:type).each do |type, group|
      puts ::Terminal::Table.new(title: type, rows: group.map(&:to_row))
    end
  end

  def warn_deprecated(message)
    log_stderr Term::ANSIColor.yellow Term::ANSIColor.bold "i19: [DEPRECATED] #{message}"
  end

  def log_success(message)
    log_stderr Term::ANSIColor.green "i19: #{message}"
  end
  def log_verbose(message)
    if ENV['VERBOSE']
      log_success(message)
    end
  end

  def log_warn(message)
    log_stderr Term::ANSIColor.yellow "i19: [WARN] #{message}"
  end

  def log_error(message)
    log_stderr Term::ANSIColor.red Term::ANSIColor.bold "i19: #{message}"
  end

  def log_stderr(*args)
    $stderr.puts(*args)
  end
end

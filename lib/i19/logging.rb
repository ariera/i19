# coding: utf-8
module I19::Logging
  extend self

  def warn_deprecated(message)
    log_stderr Term::ANSIColor.yellow Term::ANSIColor.bold "i19: [DEPRECATED] #{message}"
  end

  def log_verbose(message)
    if ENV['VERBOSE']
      log_stderr Term::ANSIColor.green "i19: #{message}"
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

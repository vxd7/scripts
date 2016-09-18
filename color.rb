#!/usr/bin/env ruby
# Text colorization script
# https://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red;				colorize(31) end
  def green;			colorize(32) end
  def yellow;			colorize(33) end
  def blue;				colorize(34) end
  def magenta;			colorize(35) end
  def cyan;				colorize(36) end

  def light_gray;		colorize(37) end
  def dark_gray;		colorize(90) end
  def light_red;		colorize(91) end
  def light_green;		colorize(92) end
  def light_yellow;		colorize(93) end
  def light_blue;		colorize(36) end
  def light_cyan;		colorize(96) end

  def bold;				colorize(1)  end
  def dim;				colorize(2)  end
  def underlined;		colorize(4)  end


  alias_method			:pink,			:magenta
  alias_method 			:lgray,			:light_gray
  alias_method 			:dgray,			:dark_gray
  alias_method 			:lred,			:light_red
  alias_method 			:lgreen,		:light_green
  alias_method 			:lyellow,		:light_yellow
  alias_method 			:lblue,			:light_blue
  alias_method 			:lcyan,			:light_cyan
end

def formLogMessage(msg_type = "info", msg_string)
	case msg_type
	when "info", "INFO"
		puts "[" + "INFO".lcyan + "] #{msg_string}"

	when "error", "ERROR"
		puts "[" + "ERROR".red + "] #{msg_string}"

	when "critical_error", "CRITICAL_ERROR", "critical", "CRITICAL"
		puts "[" + "CRITICAL ERROR".lred.bold + "] " + msg_string.lred

	when "debug", "DEBUG"
		puts "[".dim + "DEBUG".green.dim + "] #{msg_string}".dim

	end
end

info_string = "Information about something goes here"
formLogMessage("INFO", info_string)

error_string = "No such file or directory!"
formLogMessage("ERROR", error_string)

crit_error_string = "Bad data in module ModuleName! Exiting now."
formLogMessage("CRITICAL", crit_error_string)

formLogMessage("DEBUG", "Value is 255.334")

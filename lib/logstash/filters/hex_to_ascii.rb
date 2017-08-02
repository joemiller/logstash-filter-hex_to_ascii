# encoding: utf-8

# Convert hex-encoded strings to their ASCII representations.
#
# This plugin was originally intended to assist with auditd logs which sometimes
# log certain values as hex-encoded pieces of data. It may be useful for other
# situations where you need to convert hex-encoded strings back to ASCII.
#
# The plugin will look for one or more strings in the specified field ('message' by default)
# and attempt to convert them to Encoding::ASCII_8BIT format. Any string
# prefixed with `0x` will be considered hex-encoded. The match prefix can be
# changed with the `prefix` config option.
#
# Quick demo:
#
#   echo '0x6364202F6F70742F' | logstash -e 'input{stdin{}} filter{hex_to_ascii{}} output{stdout{codec => rubydebug}}'
#   {
#       "@timestamp" => 2017-08-02T20:01:52.179Z,
#       "message" => "cd /opt/"
#   }
#
# Example decoding the 'cmd=' string emitted by auditd:
#
#   $ echo '<audit-1123> pid=13334 uid=987 auid=4294967295 ses=4294967295 msg=cwd="/" cmd=2F62696E2F66696E64 terminal=? res=success'  \
#       | logstash -e 'input{stdin{}} filter{hex_to_ascii{prefix => "cmd="}} output{stdout{codec => rubydebug}}'
#
#       {
#          "@timestamp" => 2017-08-02T20:14:02.267Z,
#          "message" => "<audit-1123> pid=13334 uid=987 auid=4294967295 ses=4294967295 msg=cwd=\"/\" /bin/find terminal=? res=success"
#      }
#
# Example decoding the 'data=' string emitted by auditd + pam_tty_audit:
#
#   $ echo 'tty pid=8106 uid=5520 auid=5520 ses=38 major=136 minor=0 comm="bash" data=6364202F6F70742F' \
#       | logstash -e 'input{stdin{}} filter{hex_to_ascii{prefix => "data="}} output{stdout{codec => rubydebug}}'
#
#

require 'logstash/filters/base'

class LogStash::Filters::HexToAscii < LogStash::Filters::Base
  config_name 'hex_to_ascii'

  # The field to operate on
  config :field, :validate => :string, :default => 'message'

  # A hex value may be embedded with other values, some of which may appear to be
  # hex values but should not be decoded. In order to limit the scope of the search,
  # set a prefix. The default prefix is `0x`. Other possibilities are `data=` which
  # is useful for some type of auditd log messages that encode data eg:
  # `data=654FBAC98C`, which would be converted to `data=df ; ls`
  config :prefix, :validate => :string, :default => '0x'

  # remove the prefix after successful conversion. default `true`
  # eg: when true:  `0x6466` => `df`
  #     when false: `0x6466` => `0xdf`
  config :remove_prefix, :validate => :boolean, :default => true

  public
  def register
    # Nothing to do
  end #def register

  public
  def filter(event)
    return unless filter?(event)

    event.set(@field, hex_to_ascii(event.get(@field), @prefix, @remove_prefix))
    filter_matched(event)
  end # def filter

  # unhexlify a hex value. Some values may not convert to printable UTF-8 characters
  # in which case ruby will return an ASCII-8BIT (binary) encoded value. In this case
  # we will use .inspect to return an escaped version of the string
  # in UTF-8 format otherwise Logstash will throw exceptions.
  private
  def unhexlify(msg)
    string = msg.scan(/../).collect { |c| c.to_i(16).chr }.join
    (string.encoding == Encoding::ASCII_8BIT) ? string.inspect : string
  end # def unhexlify

  # find all hex values with the given prefix and attempt to convert to ascii
  private
  def hex_to_ascii(value, prefix, strip_prefix)
    value.gsub(/#{prefix}([0-9A-Fa-f]+)/) do |m|
      strip_prefix ? unhexlify($1) : prefix + unhexlify($1)
    end
  end # def hex_to_ascii
end # class LogStash::Filters::HexToAscii

# encoding: utf-8

require 'logstash/devutils/rspec/spec_helper'
require 'logstash/filters/hex_to_ascii'

describe 'LogStash::Filters::HexToAscii' do

  describe 'should convert a single hex value to ascii and remove the hex prefix' do
    config <<-CONFIG
      filter {
        hex_to_ascii {
          field => 'message'
          prefix => '0x'
          remove_prefix => 'true'
        }
      }
    CONFIG

    sample '0x666F6F626172' do
      insist { subject.get('message') } == 'foobar'
    end
  end

  describe 'should return an unchanged string if no hex digits found' do
    config <<-CONFIG
      filter { hex_to_ascii {} }
    CONFIG

    sample 'a string with no hex' do
      insist { subject.get('message') } == 'a string with no hex'
    end
  end

  describe 'converts a hex value while leaving the prefix' do
    config <<-CONFIG
      filter {
        hex_to_ascii {
          prefix => 'data='
          remove_prefix => 'false'
        }
      }
    CONFIG

    sample 'data=666F6F' do
      insist { subject.get('message') } == 'data=foo'
    end
  end

  describe 'converts multiple hex values' do
    config <<-CONFIG
      filter {
        hex_to_ascii {
          prefix => 'data='
          remove_prefix => 'false'
        }
      }
    CONFIG

    sample 'data=666F6F and data=626172' do
      insist { subject.get('message') } == 'data=foo and data=bar'
    end
  end

  describe 'converts unprintable binary characters to printable' do
    config <<-CONFIG
    filter { hex_to_ascii {} }
    CONFIG

    sample '0x66F6F' do
      insist { subject.get('message') } == '"f\\xF6"'
    end
  end
end

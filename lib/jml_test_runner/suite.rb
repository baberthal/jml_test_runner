require 'active_support/core_ext/hash/conversions'
require 'date'
require 'jml_test_runner/test_case'

module JmlTestRunner
  class Suite
    attr_reader :raw_input, :tests, :timestamp, :title
    def initialize(raw)
      @raw_input = Hash.from_xml(raw)
      @tests = []
      return unless @raw_input['testsuites']
      parse_raw_xml
    end

    def failure_count
      @tests.count { |t| t.result == :failure }
    end

    def pass_count
      @tests.count { |t| t.result == :success }
    end

    def error_count
      @tests.count { |t| t.result == :error }
    end

    def count
      @tests.count
    end

    private

    def parse_raw_xml
      hash = @raw_input['testsuites']
      @timestamp = DateTime.parse(hash['datetime'])
      suite = hash['suite']
      parse_suite_xml(suite)
    end

    def parse_suite_xml(suite_hash)
      @title = suite_hash['title']
      @duration = suite_hash['duration']
      suite_hash['test'].each do |test|
        next unless test.is_a?(Hash)
        @tests.push(TestCase.new(test))
      end
    end
  end
end

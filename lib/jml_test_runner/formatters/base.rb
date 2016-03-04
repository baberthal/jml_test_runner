require 'colorize'

module JmlTestRunner
  module Formatters
    class Base
      attr_accessor :suites
      def initialize(runner)
        @suites = runner.suites_run
      end
    end
  end
end

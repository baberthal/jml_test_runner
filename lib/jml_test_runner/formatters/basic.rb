require 'jml_test_runner/formatters/base'
require 'terminal-table'

module JmlTestRunner
  module Formatters
    class Basic < Base
      def print_formatted_output
        @suites.each do |suite|
          format_suite_summary(suite)
          format_suite_test_cases(suite)
          format_suite_summary_summary(suite)
        end
      end

      def separator
        msg = '=' * term_width
        puts msg.colorize(:white).bold
      end

      def format_suite_summary(suite)
        puts
        separator
        puts suite.title.colorize(:blue).bold
        puts suite.timestamp.strftime('%D -- %H:%M:%S').colorize(:yellow)
      end

      def format_suite_summary_summary(suite)
        full = "#{suite.count} Test(s) Run".colorize(:white)
        passes = "#{suite.pass_count} Pass(es)".colorize(:green)
        failures = "#{suite.failure_count} Failure(s)".colorize(:red)
        errors = "#{suite.error_count} Error(s)".colorize(:yellow)
        puts
        puts "#{full} (#{passes} #{failures} #{errors})"
        puts
      end

      # rubocop:disable Metrics/MethodLength
      def format_suite_test_cases(suite) # rubocop:disable Metrics/AbcSize
        table_rows = []
        suite.tests.each do |test|
          if test.success?
            table_rows << [test.id, "\u2714".encode('utf-8').colorize(:green)]
          elsif test.error?
            table_rows << [test.id, "\u25C9".encode('utf-8').colorize(:yellow)]
            table_rows << ['', test.message.colorize(:yellow)]
          elsif test.failure?
            table_rows << [test.id, "\u2718".encode('utf-8').colorize(:red)]
            table_rows << ['', test.message.colorize(:red)]
          else
            table_rows << [test.id, 'UNKNOWN'.colorize(:red)]
            table_rows << ['', test.message.colorize(:red)]
          end
        end
        table = Terminal::Table.new(rows: table_rows)
        table.style = { border_x: '', border_i: '' }
        puts table
      end

      def term_width
        result = if ENV['COLUMNS']
                   ENV['COLUMNS'].to_i
                 else
                   unix? ? dynamic_width : 80
                 end
        result < 10 ? 80 : result
      end

      def unix?
        RUBY_PLATFORM =~ /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i # rubocop:disable Metrics/LineLength
      end

      def dynamic_width
        @dynamic_width ||= (dynamic_width_stty.nonzero? || dynamic_width_tput)
      end

      def dynamic_width_stty
        `stty size 2>/dev/null`.split[1].to_i
      end

      def dynamic_width_tput
        `tput cols 2>/dev/null`.to_i
      end
    end
  end
end

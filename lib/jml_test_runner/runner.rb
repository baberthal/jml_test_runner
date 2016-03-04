require 'open3'
require 'jml_test_runner/suite'
require 'jml_test_runner/formatters'

module JmlTestRunner
  class Runner
    attr_reader :dir, :exes, :suites_run
    def initialize(test_dir)
      @dir = File.expand_path(test_dir)
      @exes = Dir["#{@dir}/**/*"].select { |f| f =~ /(.+)_tests?$/ }
      @suites_run = []
    end

    def run(suite_name = nil)
      _check_for_suite(suite_name) if suite_name
      _do_run(suite_name)
      @formatter = JmlTestRunner::Formatters::Basic.new(self)
      @formatter.print_formatted_output
    end

    private

    def _check_for_suite(name)
      raise "#{name} not found!" unless @exes.include?(name)
    end

    def _do_run(suite_name = nil)
      return _run_single_test(suite_name) if suite_name
      @exes.each do |exe|
        _run_single_test(exe)
      end
    end

    def _run_single_test(test_exe)
      Open3.popen2(
        {
          'CK_XML_LOG_FILE_NAME' => '-',
          'CK_VERBOSITY' => 'silent'
        },
        "./#{File.basename(test_exe)}",
        chdir: @dir) do |_input, output, _th|
          _parse_xml_output(output)
        end
    end

    def _parse_xml_output(xml)
      @suites_run.push(Suite.new(xml))
    end
  end
end

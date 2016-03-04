require 'pry'

module JmlTestRunner
  class TestCase
    attr_reader :result, :path, :fn, :id, :iteration,
                :duration, :description, :message
    def initialize(hash = {})
      @result = hash['result'].to_sym
      @path = hash['path']
      @fn = hash['fn']
      @id = hash['id']
      @iteration = hash['iteration']
      @duration = hash['duration']
      @description = hash['description']
      @message = hash['message']
    end

    def success?
      @result == :success
    end

    def failure?
      @result == :failure
    end

    def error?
      @result == :error
    end
  end
end

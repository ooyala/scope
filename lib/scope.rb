require "minitest/unit"

module Scope
  class Context
    attr_reader :name
    attr_accessor :test_method_names
    def initialize(name)
      @name = name
      self.test_method_names = []
    end
    def add_setup(&block) @setup = block end
    def add_teardown(&block) @teardown = block end
    def setup() @setup.call if @setup end
    def teardown() @teardown.call if @teardown end
  end

  class ContextTestCase < MiniTest::Unit::TestCase
    def self.inherited(subclass)
      # Calling Unit::TestCase's inherited() method is important, as that's how it registers test suites.
      super
      subclass.instance_eval do
        @contexts = [Context.new("")]
        @test_methods = []
        @tests_to_contexts = {}

        # MiniTest::Unit::TestCase sorts these the test methods either randomly or alphabetically. Let's
        # instead run them in the order in which they were defined, as that's least surprising.
        def test_methods() @test_methods end
      end
    end

    def self.context(name, &block)
      @contexts << Context.new(name)
      block.call
      @contexts.pop
    end

    def self.should(name, &block)
      context_name = @contexts[1..-1].map(&:name).join(" ")
      context_name += " " unless context_name.empty?
      test_method_name = "#{context_name}should #{name}"
      define_method test_method_name, block
      @contexts.last.test_method_names << test_method_name
      @test_methods << test_method_name
      @tests_to_contexts[test_method_name] = @contexts.dup
    end

    def self.setup(&block) @contexts.last.add_setup(&block) end
    def self.teardown(&block) @contexts.last.add_teardown(&block) end
    def self.tests_to_contexts() @tests_to_contexts end

    def run(test_runner)
      test_name = self.__name__
      contexts = self.class.tests_to_contexts[test_name]
      contexts.each(&:setup)
      # Unit::TestCase's implementation of run() invokes the test method (test_name) with exception handling.
      result = super
      contexts.reverse.each(&:teardown)
      result
    end
  end
end
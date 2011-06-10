require "rubygems"
require File.expand_path(File.dirname(__FILE__) + "/../lib/scope.rb")

class ScopeTest < Scope::TestCase
  @@has_run = []

  def has_run(name) @@has_run.push(name) end
  def self.tests_executed() @@has_run end

  setup_once do
    has_run "setup_once"
  end

  setup do
    has_run "setup"
  end

  should "A" do
    has_run "A"
  end

  context "context" do
    setup_once do
      has_run "context:setup_once"
    end

    setup do
      has_run "context:setup"
    end

    should "Z" do
      has_run "context:Z"
    end

    should "A" do
      has_run "context:A"
    end

    teardown do
      has_run "context:teardown"
    end

    teardown_once do
      has_run "context:teardown_once"
    end
  end

  teardown do
    has_run "teardown"
  end

  teardown_once do
    has_run "teardown_once"
  end
end

#
# I know, I know -- it's not using scope to run itself. Meta-fail.
#

ScopeTest.test_methods.each do |test_name|
  # This simulates MiniTest's run() method.
  instance = ScopeTest.new(test_name)
  instance.run(nil)
end

expected = %W(
  setup_once
  setup A teardown
  context:setup_once
    setup context:setup context:Z context:teardown teardown
    setup context:setup context:A context:teardown teardown
  context:teardown_once
  teardown_once
)

if expected != ScopeTest.tests_executed
  puts "Expected\n#{expected.inspect}\n but was\n#{ScopeTest.tests_executed.inspect}"
  exit 1
else
  puts "Success."
end
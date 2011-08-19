require "rubygems"
require File.expand_path(File.dirname(__FILE__) + "/../lib/scope.rb")

$has_run = []

class ScopeTest < Scope::TestCase
  def has_run(name) $has_run.push(name) end

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

# Test when the instance method setup/teardown are run.
module Scope
  class TestCase
    alias_method :new_setup, :setup
    def new_setup
      $has_run.push "minitest_setup"
    end
    alias_method :setup, :new_setup

    alias_method :new_teardown, :teardown
    def new_teardown
      $has_run.push "minitest_teardown"
    end
    alias_method :teardown, :new_teardown
  end
end

ScopeTest.test_methods.each do |test_name|
  # This simulates MiniTest's run() method.
  instance = ScopeTest.new(test_name)
  instance.run(nil)
end

expected = %W(
  minitest_setup
  setup_once
  setup A minitest_teardown teardown
  minitest_setup
  setup context:setup_once context:setup context:Z minitest_teardown context:teardown teardown
  minitest_setup
  setup context:setup context:A minitest_teardown context:teardown context:teardown_once teardown
  teardown_once
)

if expected != $has_run
  puts "Expected\n#{expected.inspect}\n but was\n#{$has_run.inspect}"
  exit 1
else
  puts "Success."
end

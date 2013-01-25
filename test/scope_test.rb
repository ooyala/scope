# TODO(corey): This test has reached the size where some cleanup is required.
require "scope"
require "mocha/setup"

$has_run = []

class PassingTests < Scope::TestCase
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

begin
  PassingTests.test_methods.each do |test_name|
    include Mocha::API

    # Record is expected but no puke.
    test_runner = mock('test_runner') do
      expects(:record)
    end

    test_runner.mocha_setup

    # This simulates MiniTest's run() method.
    instance = PassingTests.new(test_name)
    # TODO(corey): I recall this working before exec "bundle install".
    instance.run(test_runner)

    test_runner.mocha_verify
  end
rescue
  puts "run did not call record on test_runner as expected"
  raise
end

puts "run called record on test_runner as expected"

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
  puts "Success"
end

$has_run = []

# TODO(corey): partition this out into a separate file.
class SetupFailureTest < Scope::TestCase
  setup do
    raise "failing"
  end

  should "A" do
    true
  end
end

# Runs the failing test and verifies both record and puke are called on the test runner.
# The standard minitest running calls both record and puke.
begin
  SetupFailureTest.test_methods.each do |test_name|
    include Mocha::API

    test_runner = mock('test_runner') do
      expects(:record)
      expects(:puke)
    end

    test_runner.mocha_setup

    instance = SetupFailureTest.new(test_name)
    instance.run(test_runner)

    test_runner.mocha_verify
  end
rescue
  puts "exception thrown during setup did not call record then puke as expected"
  raise
end

puts "exception thrown during setup did call record then puke as exepected"

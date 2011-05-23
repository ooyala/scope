Scope -- concise Ruby unit testing
=================================

Scope is a micro Ruby unit testing framework in the spirit of Shoulda and others. It gives you a tight syntax for writing terse, readable unit tests.

Features
--------
* Organize your tests into "contexts", where each context can have its own setup code (see example).
* 150 lines of code, so it's very easy to understand and enhance.
* Tests are run in the order you define them in, instead of alphabetically or randomly, which follows the principle of least surprise.
* setup\_once and teardown\_once, for writing integration tests (see below for details).
* The ability to call focus() before a test method to have only that method run. Very useful when writing and troubleshooting tests.
* Built on top of minitest, which is Ruby 1.9's official replacement for test/unit. Minitest is a gem and works in Ruby 1.8 as well.

Example usage
-------------

    require "scope"
    require "minitest/autorun"
    
    class MarioTest < Scope::TestCase
      context "super mario" do
        setup do
          @game = MarioGame.new
        end

        context "enemy interaction" do
          setup do
            @turtle = @game.add_enemy("turtle", :x => 10, :y => 0)
          end

          should "kill the turtle after jumping" do
            @game.mario.jump(:x => 10, :y => 0)
            assert_equal "dead", @turtle.state
          end

          should "end the game if mario walks into an enemy turtle" do
            @game.mario.move(:x => 10, :y => 0)
            assert.equal "game_over" @game.state
          end
        end

        ...

      end
    end

setup\_once and teardown\_once
----------------------------
Scope supports "setup\_once" and "teardown\_once" blocks, which are useful when writing integration tests. If you have some expensive setup code that you want to share across many of your integration tests (e.g. fetching a file, or making real API requests) then use setup_once:

    context "tests which require expensive setup" do
      setup_once do
        @@youtube_api = YouYubeApi.connect("my_username", "my_password")
        @@new_video = @@youtube_api.create_video(:name => "Never gonna give you up", :size => 12_282_831)
      end
  
      should "add video to a channel" do
        @@my_youtube_channel.add(@@new_video.id)
        assert_equal @@my_youtube_channel.lineup.include?(@@new_video.id)
      end

      should "allow setting a video to be private" do
        assert_equal true, @@youtube_api.set_sharing_status(@@new_video.id, :private => true)
      end

      ...
    end

You'll notice that variables created in setup_once blocks need to be class variables (e.g. @@youtube_api). This is because new instances of a testcase class are created every time a test is run. If you used simply instance variables, they would be lost when the next test is run.

focus
-----
You can use the `focus` method to indicate that only a single test should be run. When hacking on or troubleshooting tests, this is usually more convenient than running your test with command line parameters (-n). It's also super useful if you're using [watchr](https://github.com/mynyml/watchr) to run your tests.

    should "decrease file count when files are removed" do
      assert_equal 2, @directory.file_count
      @directory.delete("banana.txt")
      assert_equal 1, @directory.file_count
    end

    focus
    should "list files in alphabetical order" do
      assert_equal ["apricot.txt", "banana.txt"], @directory.list
    end

In this example, only the test called "list files in alphabetical order" will be run when you run this test file.

License
-------
Licensed under the [MIT license](http://www.opensource.org/licenses/mit-license.php)

Credits
-------
Phil Crosby (twitter @philcrosby)
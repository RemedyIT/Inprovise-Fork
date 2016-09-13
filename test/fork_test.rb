# Script tests for Inprovise::Fork
#
# Author::    Martin Corino
# License::   Distributes under the same license as Ruby

require_relative 'test_helper'

describe Inprovise::Fork do

  before :each do
    @node = Inprovise::Infrastructure::Node.new('myNode', {channel: 'test', helper: 'test'})
    @node2 = Inprovise::Infrastructure::Node.new('myNode2', {channel: 'test', helper: 'test'})
    @script = Inprovise::DSL.script('myScript') {}
  end

  after :each do
    reset_script_index!
    reset_infrastructure!
  end

  describe Inprovise::Fork::DSL do

    describe 'fork' do

      before :each do
        @fork_dsl = Inprovise::Fork::DSL.new(nil, :sync)
        @runner = Inprovise::ScriptRunner.new(@node, 'myScript')
      end

      it 'supports forking apply' do
        @fork_dsl.expects(:run_command).with(:apply, 'anotherScript', 'myNode2')
        @script.apply { fork.apply('anotherScript', 'myNode2') }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:apply)
        end
      end

      it 'supports forking revert' do
        @fork_dsl.expects(:run_command).with(:revert, 'anotherScript', 'myNode2')
        @script.revert { fork.revert('anotherScript', 'myNode2') }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:revert)
        end
      end

      it 'supports forking validate' do
        @fork_dsl.expects(:run_command).with(:validate, 'anotherScript', 'myNode2')
        @script.validate { fork.validate('anotherScript', 'myNode2'); true }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:validate)
        end
      end

      it 'supports forking trigger' do
        @fork_dsl.expects(:run_command).with(:trigger, 'anotherScript:action[arg]', 'myNode2')
        @script.apply { fork.trigger('anotherScript:action[arg]', 'myNode2') }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:apply)
        end
      end

      it 'executes a forked script' do
        @script2 = Inprovise::DSL.script('anotherScript') { apply { config[:myMockup].do_something('test') } }
        @script.apply { fork.apply('anotherScript', 'myNode2', {:myMockup => config[:myMockup]}) }
        @mockObj = mock
        @mockObj.expects(:do_something).with('test')
        @runner.execute(:apply, {:myMockup => @mockObj})
      end

    end

    describe 'fork block' do

      before :each do
        @fork_dsl = Inprovise::Fork::DSL.new(nil, :sync)
        @runner = Inprovise::ScriptRunner.new(@node, 'myScript')
      end

      it 'supports forking apply' do
        @fork_dsl.expects(:run_command).with(:apply, 'anotherScript', 'myNode2')
        @script.apply { fork { apply('anotherScript', 'myNode2') } }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:apply)
        end
      end

      it 'supports forking revert' do
        @fork_dsl.expects(:run_command).with(:revert, 'anotherScript', 'myNode2')
        @script.revert { fork { revert('anotherScript', 'myNode2') } }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:revert)
        end
      end

      it 'supports forking validate' do
        @fork_dsl.expects(:run_command).with(:validate, 'anotherScript', 'myNode2')
        @script.validate { fork { validate('anotherScript', 'myNode2') }; true }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:validate)
        end
      end

      it 'supports forking trigger' do
        @fork_dsl.expects(:run_command).with(:trigger, 'anotherScript:action[arg]', 'myNode2')
        @script.apply { fork { trigger('anotherScript:action[arg]', 'myNode2') } }
        Inprovise::Fork::DSL.stub(:new, @fork_dsl) do
          @runner.execute(:apply)
        end
      end

      it 'executes a forked script' do
        @script2 = Inprovise::DSL.script('anotherScript') { apply { config[:myMockup].do_something('test') } }
        @script.apply { fork { apply('anotherScript', 'myNode2', {:myMockup => config[:myMockup]}) } }
        @mockObj = mock
        @mockObj.expects(:do_something).with('test')
        @runner.execute(:apply, {:myMockup => @mockObj})
      end

    end

    describe 'checks target' do

      before :each do
        @fork_dsl = Inprovise::Fork::DSL.new(nil, :sync)
        @runner = Inprovise::ScriptRunner.new(@node, 'myScript')
      end

      it 'does not allow fork for active node' do
        @script2 = Inprovise::DSL.script('anotherScript') { apply { config[:myMockup].do_something('test') } }
        @script.apply { fork.apply('anotherScript', 'myNode', {:myMockup => config[:myMockup]}) }
        @mockObj = mock
        assert_raises ArgumentError do
          @runner.execute(:apply, {:myMockup => @mockObj})
        end
      end

    end

  end

end

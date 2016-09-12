# Fork support for Inprovise scripts
#
# Author::    Martin Corino
# License::   Distributes under the same license as Ruby

module Inprovise::Fork

  module ContextDSLExt
    def fork(mode=:sync, &action)
      fork = Inprovise::Fork::DSL.new(@context, mode)
      fork.instance_eval(&action) if block_given?
      fork
    end
  end

  Inprovise::ExecutionContext::DSL.send(:include, ContextDSLExt)

  class DSL

    def initialize(context, mode)
      @context = context
      @async = mode == :async
    end

    def verify_targets(*names)
      if names.any? { |name| @context.node.name == name || Inprovise::Infrastructure.find(name).includes?(@context.node.name) }
        raise ArgumentError, "Not allowed to fork for same node as running context : #{@context.node.name}"
      end
    end
    private :verify_targets

    def run_command(cmd, script, *args)
      config = Hash === args.last ? args.pop : {}
      verify_targets(*args)
      if @async
        Inprovise::Controller.run_provisioning_command(cmd, script, config, *args)
      else
        ctrl = Inprovise::Controller.new
        ctrl.run_provisioning_command(cmd, script, config, *args)
        ctrl.wait
      end
      self
    end
    private :run_command

    def apply(script, *args)
      run_command(:apply, script, *args)
    end

    def revert(script, *args)
      run_command(:revert, script, *args)
    end

    def validate(script, *args)
      run_command(:validate, script, *args)
    end

    def trigger(script, *args)
      run_command(:trigger, script, *args)
    end

  end

end

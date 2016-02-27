# Runs an external command and returns the results
Puppet::Parser::Functions::newfunction(:generate_unsafe, :arity => -2, :type => :rvalue,
    :doc => "Calls an external command on the Puppet master and returns
    the results of the command.  Any arguments are passed to the external command as
    arguments.  If the generator does not exit with return code of 0,
    the generator is considered to have failed and a parse error is
    thrown.  This function will attempt to protect you from
    malicious generator calls (e.g., those with '..' in them), but it can
    never be entirely safe.  No subshell is used to execute
    generators, so all shell metacharacters are passed directly to
    the generator.") do |args|

      raise Puppet::ParseError, "Generators must be fully qualified" unless Puppet::Util.absolute_path?(args[0])

      if args[0] =~ /\.\./
        raise Puppet::ParseError,
          "Can not use generators with '..' in them."
      end

      begin
        Dir.chdir(File.dirname(args[0])) { Puppet::Util::Execution.execute(args).to_str }
      rescue Puppet::ExecutionFailure => detail
        raise Puppet::ParseError, "Failed to execute generator #{args[0]}: #{detail}", detail.backtrace
      end
end

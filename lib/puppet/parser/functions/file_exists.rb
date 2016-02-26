require 'puppet/file_system'

module Puppet::Parser::Functions
  newfunction(:file_exists, :arity => 1, :type => :rvalue) do |args|
    found = Puppet::Parser::Files.find_file(args[0], compiler.environment)
    (found && Puppet::FileSystem.exist?(found))
  end
end

module Oni
  ##
  # Configurable is a basic configuration mixin that can be used to set options
  # on class level and easily access them on instance level, optionally only
  # evaluating the setting when it's accessed.
  #
  # Basic usage:
  #
  #     class SomeClass
  #       include Oni::Configurable
  #
  #       set :threads, 5
  #       set :logger, proc { Logger.new(STDOUT) }
  #
  #       def some_method
  #         option(:threads).times do
  #           # ...
  #         end
  #       end
  #     end
  #
  module Configurable
    ##
    # @param [Class|Module] into
    #
    def self.included(into)
      into.extend(ClassMethods)
    end

    ##
    # Returns the value of the given option. If the value responds to `#call`
    # the method is invoked and the return value of this call is returned.
    #
    # @param [Symbol|String] name
    # @param [Mixed] default The default value to return if no custom one was
    #  found.
    # @return [Mixed]
    #
    def option(name, default = nil)
      value = self.class.options[name.to_sym]
      value = default if default and !value

      if value.respond_to? :call then value.call else value end
    end

    ##
    # Raises an error if the given option isn't set.
    #
    # @param [Symbol|String] option
    # @raise [ArgumentError]
    #
    def require_option!(option)
      unless option(option)
        raise ArgumentError, "The option #{option} is required but isn't set"
      end
    end

    module ClassMethods
      ##
      # Returns a Hash containing the options of the current class.
      #
      # @return [Hash]
      #
      def options
        return @options ||= {}
      end

      ##
      # Sets the option to the given value. If a Proc (or any object that
      # responds to `#call`) is given it's not evaluated until it's accessed.
      # This makes it possible to for example set a logger that's not created
      # until an instance of the including class is created.
      #
      # @example Setting a regular option
      #  set :number, 10
      #
      # @example Setting an option using a proc
      #  # This means the logger won't be shared between different instances of
      #  # the including class.
      #  set :logger, proc { Logger.new(STDOUT) }
      #
      # @param [Symbol|String] option
      # @param [Mixed] value
      #
      def set(option, value)
        options[option.to_sym] = value
      end

      ##
      # Sets a number of options based on the given Hash.
      #
      # @example
      #  set_multiple(:a => 10, :b => 20)
      #
      # @param [Hash] options
      #
      def set_multiple(options)
        options.each do |option, value|
          set(option, value)
        end
      end

    end
  end
end

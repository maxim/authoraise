require 'authoraise/version'
require 'set'

module Authoraise
  Error = Class.new(RuntimeError)

  class << self; attr_accessor :strict_mode end

  def authorize(options = {}, &block)
    Policy.new(&block).authorize(options)
  end

  class Check
    attr_reader :required_keys

    def initialize(required_keys, procedure)
      @required_keys = required_keys.to_set.freeze
      @procedure = procedure
    end

    def call(options)
      given_keys = options.keys.to_set

      if required_keys.subset?(given_keys)
        @procedure.call(*required_keys.map{|k| options[k]})
      else
        raise Error, "Check failed, missing keys: #{missing_keys(given_keys)}"
      end
    end

    def missing_keys(given_keys)
      (required_keys - given_keys.to_set).to_a
    end
  end

  class Policy
    def initialize
      @checks = []
      yield(self) if block_given?
    end

    def allow(&procedure)
      @checks <<
        Check.new(procedure.parameters.map(&:last), procedure)
    end

    def authorize(options = {})
      raise Error, 'Policy is empty' if @checks.empty?
      given_keys = options.keys.to_set
      assert_all_keys_match(given_keys) if Authoraise.strict_mode
      missing_keys = Set.new

      @checks.each do |check|
        if check.required_keys.subset?(given_keys)
          return true if check.(options)
        else
          missing_keys += check.missing_keys(given_keys)
        end
      end

      if missing_keys.empty?
        return false
      else
        raise Error,
          "Inconclusive authorization, missing keys: #{missing_keys.to_a}"
      end
    end

    def freeze
      @checks.freeze
      super
    end

    private

    def assert_all_keys_match(given_keys)
      missing_keys = @checks.inject(Set.new) do |set, check|
        set + check.missing_keys(given_keys)
      end.to_a

      if !missing_keys.empty?
        raise Error, "Strict mode found missing keys: #{missing_keys}"
      end
    end
  end
end

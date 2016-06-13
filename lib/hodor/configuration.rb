require 'erb'
require 'yaml'
require_relative 'config/config_set'
require 'active_support/core_ext/hash'

module Hodor
  class Configuration
    include YAML

    attr_accessor :config_name

    LOAD_SETS_FILE_SPEC =  { yml:
                            { local:
                                  { folder: 'config',
                                    config_file_name: 'load_sets' }}}
    def self.config_definitions_sets
      Hodor::Config::ConfigSet.new_config_set('load_sets', LOAD_SETS_FILE_SPEC)
    end

    def env
      Environment.instance
    end

    def target
      env.settings[:target]
    end

    def config_sets
      @config_sets ||= load
    end

    def config_defs
      @config_defs ||= self.class.config_definitions_sets.hash.deep_symbolize_keys[config_name.to_sym]
    end

    def logger
      env.logger
    end

    def initialize(config_name)
      @config_name = config_name
    end

    def config_hash
      config_sets.each_with_object({}) { |in_configs, out_configs| out_configs.merge!(in_configs.hash)}
    end

    def process

    end

    def load
      out_set = []
      config_defs.each do |conf_def|
        set_name = "#{conf_def.keys.first}:#{config_name}"
        out_set << Hodor::Config::ConfigSet.new_config_set(set_name, conf_def)
      end
      out_set
    end
  end
end


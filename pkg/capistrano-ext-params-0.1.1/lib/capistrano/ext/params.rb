require 'yaml'
require 'capistrano'
require 'capistrano/ext/set/helpers'

class CapistranoExtParams
  VERSION = '0.1.1'

  def self.with_configuration(&block)
    Capistrano::Configuration.instance(:must_exist).load(&block)
  end
end

$capistrano_ext_params = {}

CapistranoExtParams.with_configuration do
  namespace :params do
    desc "List all known parameters and their options"
    task :list do
      puts $capistrano_ext_params.to_yaml
    end
  end
end

module Capistrano
    class Configuration
        module Namespaces
          def desc_param(var,description,opts={})
            $capistrano_ext_params[var] = {
              :description => description
            }.merge(opts)
          end
        end
    end
end

module Capistrano
  class TaskDefinition
    alias_method :original_brief_description, :brief_description
    def brief_description(max_length=nil)
        brief = original_brief_description(max_length)
        unless @options.nil? || @options[:required].nil? || @options[:required].empty?
            brief << " " * (max_length-brief.length) if max_length > brief.length
            brief << "requires " + @options[:required].join(",")
        end
        brief
    end
  end
end


module Capistrano
  class Configuration
    module Execution

      def ensure_params(params=[])
        params = [ params ].flatten

        # Query user for any undefined variables
        params.each do |param|
          param_desc = $capistrano_ext_params[param][:description] || "value for #{param}"
          unless exists?(param)
            set_ask( param, "#{param} - #{param_desc}: " )
          end

          puts "  %s: %s" % [param, fetch(param)]
        end
      end

      alias_method :original_execute_task, :execute_task
      def execute_task(task)
        ensure_params(task.options[:required]) if task.options[:required]
        original_execute_task(task)
      end

    end

  end
end

module Capistrano
  class CLI
    module Help
      alias_method :original_explain_task, :explain_task

      def explain_task(config,name)

        def print( task )
          puts "-"*HEADER_LEN
          puts "Usage:\n\tcap %s %s %s" % [
            $recipe,
            task.fully_qualified_name,
            [
              [task.options[:required]].flatten.compact.map {|param| " %s=ARG" % [param] },
              [task.options[:optional]].flatten.compact.map {|param| " [%s=ARG]" % [param] }
            ].flatten.join()
          ]
          puts "-"*HEADER_LEN
          puts format_text(task.description)
          puts "-"*HEADER_LEN
          if task.options[:required]
            puts "Required Parameters"
            task.options[:required].each do |param|
              param_desc = $capistrano_ext_params[param][:description] || param
              puts "\t#{param} - #{param_desc}"
            end
          end
          if task.options[:optional]
            puts "Optional Parameters"
            task.options[:optional].each do |param|
              param_details = $capistrano_ext_params[param]
              if param_details
                param_desc = "#{param_details[:description]} (default=#{param_details[:default]})"
              else
                param_desc = param
              end
              puts "\t#{param} - #{param_desc}"
            end
          end
        end

        task = config.find_task(name)

        # if name is for a namespace, then explain all tasks in namespace
        if task.nil?
          # Following logic adapted from Namespaces#find_task
          parts = name.to_s.split(/:/)

          ns = config
          until parts.empty?
            next_part = parts.shift
            ns = next_part.empty? ? nil : ns.namespaces[next_part.to_sym]
            return nil if ns.nil?
          end

          # print each task
          ns.tasks.each do |_name,_task|
            print( task )
            puts "\n\n"
          end

        else
          print( task )
        end
      end

    end

  end

end

require 'capistrano'
class CapistranoExtParams
  VERSION = '0.1.0'
end

module Capistrano
  class TaskDefinition
    alias_method :original_brief_description, :brief_description
    def brief_description(max_length=nil)
        brief = original_brief_description(max_length)
        unless @options.nil? || @options[:required_params].nil? || @options[:required_params].empty?
            brief << " " * (max_length-brief.length) if max_length > brief.length
            brief << "requires " + @options[:required_params].join(",")
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
          param_desc = $parameter_descriptions[param] || "value for #{param}"
          unless exists?(param)
            set_ask( param, "#{param} - #{param_desc}: " )
          end

          puts "  %s: %s" % [param, fetch(param)]
        end
      end

      alias_method :original_execute_task, :execute_task
      def execute_task(task)
        puts "     options #{task.options}"
        ensure_params(task.options[:required_params]) if task.options[:required_params]
        original_execute_task(task)
      end

    end

  end
end

module Capistrano
  class CLI
    module Help
      #alias_method :original_explain_task, :explain_task

      def explain_task(config,name)

        def print( task )
          puts "-"*HEADER_LEN
          puts "Usage:\n\tcap %s %s %s" % [
            $recipe,
            task.fully_qualified_name,
            [
              [task.options[:required_params]].flatten.compact.map {|param| " %s=ARG" % [param] },
              [task.options[:optional_params]].flatten.compact.map {|param| " [%s=ARG]" % [param] }
            ].flatten.join()
          ]
          puts "-"*HEADER_LEN
          puts format_text(task.description)
          puts "-"*HEADER_LEN
          if task.options[:required_params]
            puts "Required Parameters"
            task.options[:required_params].each do |param|
              param_desc = $parameter_descriptions[param] || param
              puts "\t#{param} - #{param_desc}"
            end
          end
          if task.options[:optional_params]
            puts "Optional Parameters"
            task.options[:optional_params].each do |param|
              param_details = $optional_parameter_descriptions[param]
              if param_details
                param_desc = "#{param_details[:desc]} (default=#{param_details[:default]})"
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

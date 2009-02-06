# module Rake
# 	module TaskManager
# 		def redefine_task(task_class, args, &block)
# 			task_name, deps = (RAKEVERSION >= '0.8.0') ? resolve_args([args]) : resolve_args(args)
# 			task_name = task_class.scope_name(@scope, task_name)
# 			deps = [deps] unless deps.respond_to?(:to_ary)
# 			deps = deps.collect {|d| d.to_s }
# 			task = @tasks[task_name.to_s] = task_class.new(task_name, self)
# 			task.application = self
# 			if RAKEVERSION >= '0.8.0'
# 				task.add_description(@last_description)
# 				@last_description = nil
# 			else
# 				task.add_comment(@last_comment)
# 				@last_comment = nil
# 			end
# 			task.enhance(deps, &block)
# 			task
# 		end
# 	end
# 	class Task
# 		class << self
# 			def redefine_task(args, &block)
# 				Rake.application.redefine_task(self, args, &block)
# 			end
# 		end
# 	end
# end
# 
# 
# # Everything beyond this point is utterly stupid
# 
# 
# class << Rake::TaskManager
# 	def redefine_task; end
# end
# 
# class Array
# 	alias :xyz_include? :include?
# 	def include?( obj )
# 		obj = 'redefine_task' if obj == :redefine_task
# 		self.xyz_include?( obj )
# 	end
# end
# 
# 

# railties/lib/rails/application.rb
# The Application is also responsible for building the middleware stack.
#
# == Booting process         
#
# The application is also responsible for setting up and executing the booting
# process. From the moment you require "config/application.rb" in your app,
# the booting process goes like this:
#
#   1)  require "config/boot.rb" to setup load paths
#   2)  require railties and engines
#   3)  Define Rails.application as "class MyApp::Application < Rails::Application"
#   4)  Run config.before_configuration callbacks
#   5)  Load config/environments/ENV.rb
#   6)  Run config.before_initialize callbacks
#   7)  Run Railtie#initializer defined by railties, engines and application.
#       One by one, each engine sets up its load paths, routes and runs its config/initializers/* files.
#   9)  Custom Railtie#initializers added by railties, engines and applications are executed
#   10) Build the middleware stack and run to_prepare callbacks
#   11) Run config.before_eager_load and eager_load! if eager_load is true
#   12) Run config.after_initialize callbacks

# Rails has 5 initialization events which can be hooked into (listed in the order that they are ran):
#   before_configuration: This is run as soon as the application constant inherits from Rails::Application. 
#                        The config calls are evaluated before this happens.
#   before_initialize: This is run directly before the initialization process of the application occurs with the :bootstrap_hook initializer near the beginning                     of the Rails initialization process.
#   to_prepare: Run after the initializers are ran for all Railties (including the application itself), but before eager loading and the middleware stack is built. More importantly, will run upon every request in development, but only once (during boot-up) in production and test.
#   before_eager_load: This is run directly before eager loading occurs, which is the default behaviour for the production environment and not for the development environment.
#   after_initialize: Run directly after the initialization of the application, but before the application initializers are run.

# * rails 4 feature *
# config.cache_classes 決定要不要reload, eager_load 決定有沒有把eager_load_namespaces 裡面的包含進去
# eager_load! If config.cache_classes is true, runs the config.before_eager_load hooks and then calls eager_load! which will load all the Ruby files from config.eager_load_paths.
# config.eager_load when true, eager loads all registered config.eager_load_namespaces. This includes your application, engines, Rails frameworks and any other registered namespace.
# config.eager_load_namespaces registers namespaces that are eager loaded when config.eager_load is true. All namespaces in the list must respond to the eager_load! method.
#
#
# 從 activesupport/lib/active_support/dependencies/autoload.rb  
#    def eager_load!
#      @_autoloads.values.each { |file| require file }
#    end 
# 可以看出基本上eager_load 就是要先把code load 進來所以在這邊就是把那些都require 進來
# 會在其他module 看到
#  eager_autoload do
#    autoload :Errors
#  end 
# 當然就是說eager_load 時 這些要進來 單純設autoload 就不用 eager_load 的就要
# 所以單純是config.cahce_classes 決定的有
#    middleware.use ::Rack::Lock unless config.cache_classes
#
#         unless config.cache_classes     
#          middleware.use ::ActionDispatch::Reloader, lambda { app.reload_dependencies? }
#        end

module RailtieDemo
  class Railtie < Rails::Railtie
    #config.eager_load_namespaces << RailtieDemo::Bomb
    config.railtie_demo = ActiveSupport::OrderedOptions.new
    config.railtie_demo.railtie_demo_config = :bomb
    # This is application's middleware
    # A railtie don't have its own middleware
    # in railtie the variables are all class variables
    # just check code rails source code railties-3.2.8/lib/rails/railtie/configuration.rb
    # But engine have its own
    # just check code rails source code railties-3.2.8/lib/rails/engine/configuration.rb
    config.app_middleware.use RailtieDemo::Bomb

    config.before_configuration do
      p "before_configuration"
    end

    config.before_initialize do
      p "before_initialize"
    end

    # The block argument of the initializer method is the instance of the application itself, and so we can access the configuration on it by using the config method as done in the example.
    initializer "railtie_demo.railtie.first_configuration" do |app|
      p "initializer first"
    end

    initializer "railtie_demo.railtie.third_configuration" do
      p "initializer third"
    end

    initializer "railtie_demo.railtie.second_configuration", :before => "railtie_demo.railtie.third_configuration" do
      p "initializer second"
    end

    # initializer "railtie_demo.railtie.add_middleware" do |app|
    #   app.middleware.use RailtieDemo::Bomb
    # end

    # Add a to_prepare block which is executed once in production
    # and before each request in development
    config.to_prepare do
      p "to prepare"
    end

    config.before_eager_load do
      p "before_eager_load"
    end

    config.after_initialize do
      p "after_initialize"
    end

    # configure our plugin on boot. other extension points such
    # as configuration, rake tasks, etc, are also available
    initializer "railtie_demo.initialize" do |app|

      # subscribe to all rails notifications: controllers, AR, etc.
      ActiveSupport::Notifications.subscribe do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        puts "===========================================Got notification: #{event.inspect}"
      end

    end
    
    rake_tasks do
      load "tasks/railtie_demo.rake"
    end

    console do
      p "in console"
    end

    # you could check how many railtie in app through Rails::Railtie.subclasses
  end
end

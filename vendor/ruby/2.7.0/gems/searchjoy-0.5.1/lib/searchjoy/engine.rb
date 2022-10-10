module Searchjoy
  class Engine < ::Rails::Engine
    isolate_namespace Searchjoy

    initializer "searchjoy" do |app|
      if app.config.respond_to?(:assets)
        if defined?(Sprockets) && Sprockets::VERSION >= "4"
          app.config.assets.precompile << "searchjoy/application.js"
        else
          # use a proc instead of a string
          app.config.assets.precompile << proc { |path| path == "searchjoy/application.js" }
        end
      end

      Searchjoy.attach_to_searchkick! if defined?(Searchkick)
    end
  end
end

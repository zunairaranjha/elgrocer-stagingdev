if Rails.env.test? and File.basename($0) != 'rake' # we dont want this for rake tasks
  dir = Rails.root.join("app/models")
  Dir.glob(File.join("#{dir}/**/*.rb")).each do |path|
    model_filename = path[/#{Regexp.escape(dir.to_s)}\/([^\.]+).rb/, 1]

    next if model_filename.match(/^concerns\//i) # Skip concerns/ folder

    begin
      klass = model_filename.camelize.constantize
    rescue NameError
      require(path) ? retry : raise(RuntimeError, "Cannot load class '#{klass}'")
    end

    # Skip if the class doesn't have Elasticsearch integration
    next unless klass.respond_to?(:__elasticsearch__)

    klass.__elasticsearch__.import  force:      true,
                                    batch_size: 1000,
                                    index:      nil,
                                    type:       nil,
                                    scope:      nil
  end
end
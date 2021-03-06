require 'listen'

module Bunto
  module Watcher
    extend self

    # Public: Continuously watch for file changes and rebuild the site
    # whenever a change is detected.
    #
    # If the optional site argument is populated, that site instance will be
    # reused and the options Hash ignored. Otherwise, a new site instance will
    # be instantiated from the options Hash and used.
    #
    # options - A Hash containing the site configuration
    # site    - The current site instance (populated starting with Bunto 3.2)
    #           (optional, default: nil)
    #
    # Returns nothing.
    def watch(options, site = nil)
      ENV["LISTEN_GEM_DEBUGGING"] ||= "1" if options['verbose']

      site ||= Bunto::Site.new(options)
      listener = build_listener(site, options)
      listener.start

      Bunto.logger.info "Auto-regeneration:", "enabled for '#{options["source"]}'"

      unless options['serving']
        trap("INT") do
          listener.stop
          puts "     Halting auto-regeneration."
          exit 0
        end

        sleep_forever
      end
    rescue ThreadError
      # You pressed Ctrl-C, oh my!
    end

    # TODO: shouldn't be public API
    def build_listener(site, options)
      Listen.to(
        options['source'],
        :ignore => listen_ignore_paths(options),
        :force_polling => options['force_polling'],
        &(listen_handler(site))
      )
    end

    def listen_handler(site)
      proc do |modified, added, removed|
        t = Time.now
        c = modified + added + removed
        n = c.length
        print Bunto.logger.message("Regenerating:",
          "#{n} file(s) changed at #{t.strftime("%Y-%m-%d %H:%M:%S")} ")
        begin
          site.process
          puts "...done in #{Time.now - t} seconds."
        rescue => e
          puts "...error:"
          Bunto.logger.warn "Error:", e.message
          Bunto.logger.warn "Error:", "Run bunto build --trace for more information."
        end
      end
    end

    def custom_excludes(options)
      Array(options['exclude']).map { |e| Bunto.sanitized_path(options['source'], e) }
    end

    def config_files(options)
      %w(yml yaml toml).map do |ext|
        Bunto.sanitized_path(options['source'], "_config.#{ext}")
      end
    end

    def to_exclude(options)
      [
        config_files(options),
        options['destination'],
        custom_excludes(options)
      ].flatten
    end

    # Paths to ignore for the watch option
    #
    # options - A Hash of options passed to the command
    #
    # Returns a list of relative paths from source that should be ignored
    def listen_ignore_paths(options)
      source       = Pathname.new(options['source']).expand_path
      paths        = to_exclude(options)

      paths.map do |p|
        absolute_path = Pathname.new(p).expand_path
        next unless absolute_path.exist?
        begin
          relative_path = absolute_path.relative_path_from(source).to_s
          unless relative_path.start_with?('../')
            path_to_ignore = Regexp.new(Regexp.escape(relative_path))
            Bunto.logger.debug "Watcher:", "Ignoring #{path_to_ignore}"
            path_to_ignore
          end
        rescue ArgumentError
          # Could not find a relative path
        end
      end.compact + [/\.bunto\-metadata/]
    end

    def sleep_forever
      loop { sleep 1000 }
    end
  end
end

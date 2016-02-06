module Bunto
  module Commands
    module Watch
      extend self

      def init_with_program(prog)
      end

      # Build your bunto site
      # Continuously watch if `watch` is set to true in the config.
      def process(options)
        Bunto.logger.log_level = :error if options['quiet']
        watch(site, options) if options['watch']
      end

      # Watch for file changes and rebuild the site.
      #
      # site - A Bunto::Site instance
      # options - A Hash of options passed to the command
      #
      # Returns nothing.
      def watch(_site, options)
        Bunto::Watcher.watch(options)
      end

    end
  end
end

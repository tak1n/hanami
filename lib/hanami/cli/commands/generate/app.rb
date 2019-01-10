module Hanami
  class CLI
    module Commands
      module Generate
        # @since 1.1.0
        # @api private
        class App < Command # rubocop:disable Metrics/ClassLength
          requires "environment"

          desc "Generate an app"

          argument :app, required: true, desc: "The application name (eg. `web`)"
          option :application_base_url, desc: "The app base URL (eg. `/api/v1`)"

          example [
            "admin                              # Generate `admin` app",
            "api --application-base-url=/api/v1 # Generate `api` app and mount at `/api/v1`"
          ]

          # @since 1.1.0
          # @api private
          #
          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/MethodLength
          def call(app:, application_base_url: nil, **options)
            app      = Utils::String.underscore(app)
            template = options.fetch(:template)
            base_url = application_base_url || "/#{app}"
            context  = Context.new(app: app, base_url: base_url, test: options.fetch(:test), template: template, options: options)

            assert_valid_base_url!(context)

            generate_app(context)
            generate_routes(context)
            generate_layout(context)
            generate_template(context)
            generate_favicon(context)

            create_controllers_directory(context)
            create_assets_images_directory(context)
            create_assets_javascripts_directory(context)
            create_assets_stylesheets_directory(context)

            create_spec_features_directory(context)
            create_spec_controllers_directory(context)
            generate_layout_spec(context)

            inject_require_app(context)
            inject_mount_app(context)

            append_development_http_session_secret(context)
            append_test_http_session_secret(context)
          end
          # rubocop:enable Metrics/MethodLength
          # rubocop:enable Metrics/AbcSize

          private

          # @since 1.1.0
          # @api private
          def assert_valid_base_url!(context)
            if Utils::Blank.blank?(context.base_url) # rubocop:disable Style/GuardClause
              warn "`' is not a valid URL"
              exit(1)
            end
          end

          # @since 1.1.0
          # @api private
          def generate_app(context)
            destination = project.app_application(context)

            generator.create("application.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def generate_routes(context)
            destination = project.app_routes(context)

            generator.create("routes.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def generate_layout(context)
            destination = project.app_layout(context)

            generator.create("layout.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def generate_template(context)
            destination = project.app_template(context)

            generator.create("template.#{context.template}.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def generate_favicon(context)
            destination = project.app_favicon(context)

            generator.copy("favicon.ico", destination)
          end

          # @since 1.1.0
          # @api private
          def create_controllers_directory(context)
            destination = project.keep(project.controllers(context))

            generator.create("gitkeep.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def create_assets_images_directory(context)
            destination = project.keep(project.images(context))

            generator.create("gitkeep.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def create_assets_javascripts_directory(context)
            destination = project.keep(project.javascripts(context))

            generator.create("gitkeep.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def create_assets_stylesheets_directory(context)
            destination = project.keep(project.stylesheets(context))

            generator.create("gitkeep.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def create_spec_features_directory(context)
            destination = project.keep(project.features_spec(context))

            generator.create("gitkeep.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def create_spec_controllers_directory(context)
            destination = project.keep(project.controllers_spec(context))

            generator.create("gitkeep.erb", destination, context)
          end

          # @since 1.1.0
          # @api private
          def generate_layout_spec(context)
            source      = "layout_spec.#{context.options.fetch(:test)}.erb"
            destination = project.app_layout_spec(context)

            generator.create(source, destination, context)
          end

          # @since 1.1.0
          # @api private
          def inject_require_app(context)
            content = "require_relative '../apps/#{context.app}/application'"
            path    = project.environment(context)

            req_regex = /^\s*require .*$/
            rel_regex = /^\s*require_relative .*$/

            case File.read(path)
            when rel_regex
              generator.insert_after_last(path, content, after: rel_regex)
            when req_regex
              generator.insert_after_last(path, content, after: req_regex)
            else
              raise "No require found"
            end
          end

          # @since 1.1.0
          # @api private
          def inject_mount_app(context)
            content = "  mount #{context.app.classify}::Application, at: '#{context.base_url}'"
            path    = project.environment(context)

            generator.insert_after_first(path, content, after: /Hanami.configure do/)
          end

          # @since 1.1.0
          # @api private
          def append_development_http_session_secret(context)
            append_env_to_http_session_secret(context, "development")
          end

          # @since 1.1.0
          # @api private
          def append_test_http_session_secret(context)
            append_env_to_http_session_secret(context, "test")
          end

          private

          def append_env_to_http_session_secret(context, env)
            content = %(#{context.app.upcase}_SESSIONS_SECRET="#{project.app_sessions_secret}")
            path = project.env(context, env)

            generator.append(path, content)
          end
        end
      end
    end
  end
end
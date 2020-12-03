# frozen_string_literal: true

module Hanami
  class CLI
    module Commands
      class New < Command
        # SUPPORTED_ENGINES = {
        #     'mysql'      => { type: :sql,         mri: 'mysql2',  jruby: 'jdbc-mysql'    },
        #     'mysql2'     => { type: :sql,         mri: 'mysql2',  jruby: 'jdbc-mysql'    },
        #     'postgresql' => { type: :sql,         mri: 'pg',      jruby: 'jdbc-postgres' },
        #     'postgres'   => { type: :sql,         mri: 'pg',      jruby: 'jdbc-postgres' },
        #     'sqlite'     => { type: :sql,         mri: 'sqlite3', jruby: 'jdbc-sqlite3'  },
        #     'sqlite3'    => { type: :sql,         mri: 'sqlite3', jruby: 'jdbc-sqlite3'  }
        # }.freeze

        desc 'Creates a basic hanami application'

        argument :project, required: true, desc: 'The project name'

        option :database, desc: "Database (#{{}.keys.join('/')})",
               default: 'sqlite', aliases: ["-d"]

        def call(project:, **args)
          project_name = project
          pwd = ::File.basename(::Dir.pwd) if project == '.'
          project = Utils::String.underscore(pwd || project)
          assert_project_name!(project)
          files.mkdir(project)

          Dir.chdir(project) do
            git_init
          end

          puts "Project name: #{project}"
          puts "Selected database: #{args[:database]}"
          puts "Creating your application"
          puts "Creating #{project_name} under folder #{project}"
        end

        private

        def git_init
          say(:run, 'git init . from "."')
          system("git init #{Shellwords.escape(Pathname.new('.'))}", out: File::NULL)
        end

        def assert_project_name!(project)
          if project.include?(File::SEPARATOR)
            raise ArgumentError.new("PROJECT must not contain #{File::SEPARATOR}.")
          end
        end
      end
    end

    register "new", Commands::New
  end
end

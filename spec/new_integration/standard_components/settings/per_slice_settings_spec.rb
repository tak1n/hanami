RSpec.describe "Standard components / Settings / Per-slice settings", :application_integration do
  specify "Settings are registered for each slice with a settings file" do
    with_tmp_directory(Dir.mktmpdir) do
      write "config/application.rb", <<~RUBY
        require "hanami"

        module TestApp
          class Application < Hanami::Application
          end
        end
      RUBY

      # The main slice has settings
      write "slices/main/config/settings.rb", <<~RUBY
        # frozen_string_literal: true

        require "hanami/application/settings"

        module Main
          class Settings < Hanami::Application::Settings
            setting :main_session_secret
          end
        end
      RUBY

      # The main slice has none
      write "slices/admin/.keep", ""

      require "hanami/prepare"

      expect(Main::Slice.key?(:settings)).to be true
      expect(Main::Slice[:settings]).to respond_to :main_session_secret

      expect(Admin::Slice.key?(:settings)).to be false
    end
  end
end

RSpec.describe 'hanami new', type: :integration  do
  it 'generates a vanilla project' do
    project = 'bookshelf'
    output = <<~OUTPUT
      Project name: #{project}
      Selected database: sqlite
      Creating your application
      Creating #{project} under folder #{project}
    OUTPUT

    run_cmd "hanami new #{project}", output.split

    within_project_directory(project) do
      run_cmd 'git status', 'On branch master'
    end
  end

  context "with missing name" do
    it "fails" do
      output = <<~OUT
        ERROR: "hanami new" was called with no arguments
        Usage: "hanami new PROJECT"
      OUT

      run_cmd "hanami new", output, exit_status: 1
    end
  end

  context "with a file separator in the project name" do
    it 'fails' do
      run_cmd "hanami new book/shelf", nil, exit_status: 1
    end
  end
end

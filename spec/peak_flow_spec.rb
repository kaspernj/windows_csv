require "yaml"

# rubocop:disable RSpec/DescribeClass
describe "peak_flow.yml" do
  let(:config) { YAML.load_file(File.expand_path("../peak_flow.yml", __dir__)) }

  it "defines the same broad repository filter for every build" do
    builds = config.fetch("builds")

    expect(builds.keys).to contain_exactly("build_1", "build_2", "build_3", "build_4", "build_5")

    builds.each_value do |build|
      expect(build.fetch("paths")).to eq([
                                           "**/*",
                                           "!README.rdoc",
                                           "!LICENSE.txt",
                                           "!.document",
                                           "!.gitignore",
                                           "!docs/**"
                                         ])
    end
  end
end
# rubocop:enable RSpec/DescribeClass

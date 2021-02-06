# frozen_string_literal: true

require 'dottie/models/yaml_helpers'

files = {
  home: {
    config: {
      dottie: {}
    }
  }
}

describe Dottie::Models::Yaml do
  subject do
    Struct.new(:first_name, :last_name) do
      include Dottie::Models::Yaml

      def self.config_file_location(os)
        File.join(os.config_dir, 'test_config.yml')
      end
    end
  end

  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }

  it 'should serialize to YAML' do
    expect(subject.new('First', 'Last').to_yaml).to eql("---\nfirst_name: First\nlast_name: Last\n")
  end

  it 'should serialize to a file' do
    model = subject.new('First', 'Last')
    model.save(file_system, os)
    expect(file_system.read_file('/home/config/dottie/test_config.yml')).to eql("---\nfirst_name: First\nlast_name: Last\n")
  end

  it 'should deserialize from YAML' do
    result = subject.from_yaml("---\nfirst_name: First\nlast_name: Last\n")
    expect(result.first_name).to eql('First')
    expect(result.last_name).to eql('Last')
  end

  it 'should deserialize from a file' do
    file_system.use(
      {
        home: {
          config: {
            dottie: {
              'test_config.yml': "---\nfirst_name: First\nlast_name: Last\n"
            }
          }
        }
      }
    )

    model = subject.load_yaml(file_system, os)
    expect(model.first_name).to eql('First')
    expect(model.last_name).to eql('Last')
  end
end

describe Dottie::Models::KeywordYaml do
  subject do
    Struct.new(:first_name, :last_name, keyword_init: true) do
      include Dottie::Models::KeywordYaml

      def self.config_file_location(os)
        File.join(os.config_dir, 'test_config.yml')
      end
    end
  end

  let(:file_system) { SpecHelper::FileSystem.new.use(files) }
  let(:os) { SpecHelper::OS.new.use(:macos, '/home/config') }

  it 'should serialize to YAML' do
    expect(subject.new(first_name: 'First', last_name: 'Last').to_yaml).to eql("---\nfirst_name: First\nlast_name: Last\n")
  end

  it 'should serialize to a file' do
    model = subject.new(first_name: 'First', last_name: 'Last')
    model.save(file_system, os)
    expect(file_system.read_file('/home/config/dottie/test_config.yml')).to eql("---\nfirst_name: First\nlast_name: Last\n")
  end

  it 'should deserialize from YAML' do
    result = subject.from_yaml("---\nfirst_name: First\nlast_name: Last\n")
    expect(result.first_name).to eql('First')
    expect(result.last_name).to eql('Last')
  end

  it 'should deserialize from a file' do
    file_system.use(
      {
        home: {
          config: {
            dottie: {
              'test_config.yml': "---\nfirst_name: First\nlast_name: Last\n"
            }
          }
        }
      }
    )

    model = subject.load_yaml(file_system, os)
    expect(model.first_name).to eql('First')
    expect(model.last_name).to eql('Last')
  end
end

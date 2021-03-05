# frozen_string_literal: true

describe Dottie::Models::Profile do
  let(:shell_settings) do
    commands = [
      {
        type: :source,
        options: {
          path: '/home/test.sh'
        }
      }
    ]
    env = { test: 'true' }
    Dottie::Models::ShellSettings.new(commands, env)
  end

  it 'should add shell settings for a new shell type' do
    profile = described_class.new
    profile.add_shell(:common, shell_settings)

    expect(profile.shell_settings(:common).commands).to eq(shell_settings.commands)
    expect(profile.shell_settings(:common).environment_vars).to eq(shell_settings.environment_vars)
  end

  it 'should merge shell settings for an existing shell type' do
    commands = [{ type: :path_add }]
    env = {
      test: false,
      home: '/home'
    }
    existing_settings = Dottie::Models::ShellSettings.new(commands, env)
    profile = described_class.new(shells: { common: existing_settings })
    profile.add_shell(:common, shell_settings)

    expect(profile.shell_settings(:common).commands.size).to be(2)
    expect(profile.shell_settings(:common).environment_vars[:test]).to eq('true')
    expect(profile.shell_settings(:common).environment_vars[:home]).to eq('/home')
  end

  it 'should return shell settings by shell type' do
    profile = described_class.new
    profile.add_shell(:common, shell_settings)

    expect(profile.shell_settings(:common)).to eq(shell_settings)
  end

  it 'should return empty shell settings for a shell type that was not defined' do
    profile = described_class.new
    profile.add_shell(:common, shell_settings)

    settings = profile.shell_settings(:bash)
    expect(settings.commands.size).to be(0)
    expect(settings.environment_vars.size).to be(0)
  end
end


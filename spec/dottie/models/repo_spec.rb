# frozen_string_literal: true

require 'dottie/models/repo'

describe Dottie::Models::Repo do
  it 'should generate an ID from a repo definition' do
    expect(described_class.from_definition(url: 'git').id).to eql('git')
    expect(described_class.from_definition(url: 'git', branch: 'a-branch').id).to eql('git_ba_branch')
    expect(described_class.from_definition(url: 'git', commit: 'a-commit').id).to eql('git_ca_commit')
    expect(described_class.from_definition(url: 'git', tag: 'a-tag').id).to eql('git_ta_tag')
  end

  it 'should construct a model from a git URL' do
    expect(described_class.from_git('git').url).to eql('git')
    expect(described_class.from_git('git').id).to eql('git')
    expect(described_class.from_git('git', branch: 'a-branch').id).to eql('git_ba_branch')
    expect(described_class.from_git('git', commit: 'a-commit').id).to eql('git_ca_commit')
    expect(described_class.from_git('git', tag: 'a-tag').id).to eql('git_ta_tag')
  end

  it 'should construct a model from a github repo ID' do
    expect(described_class.from_github('user/repo').url).to eql('https://github.com/user/repo.git')
    expect(described_class.from_github('user/repo', branch: 'a-branch').id).to eql('https___github_com_user_repo_git_ba_branch')

    expect(described_class.from_github('user/repo', ssh: true).url).to eql('git@github.com:user/repo.git')
    expect(described_class.from_github('user/repo', ssh: true, branch: 'a-branch').id).to eql('git_github_com_user_repo_git_ba_branch')
  end
end

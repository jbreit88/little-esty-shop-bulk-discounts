class GithubFacade
  attr_reader :repo,
              :commits,
              :contributors,
              :pull_requests,
              :service

  def initialize#(service = GithubService.new)
    @service = service
    # @repo = repo
    # @commits = commits
    # @contributors = contributors
    # @pull_requests = pull_requests
  end

  def repo
    @_repo ||= Repo.new(service.repo[:name])
  end

  def commits
    @_commits ||= service.commits.map do |data|
      Commit.new(data)
    end
  end

  def contributors
    @_contributors ||= service.contributors.map do |data|
      UserInfo.new(data)
    end
  end

  def pull_requests
    @_pull_requests ||= service.pull_requests.map do |data|
      PullRequest.new(data)
    end
  end

  def service
    @_service ||= GithubService.new
  end
end

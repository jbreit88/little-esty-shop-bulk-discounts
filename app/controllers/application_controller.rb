class ApplicationController < ActionController::Base

  def github_facade
    @github_facade = GithubFacade.new
  end
end

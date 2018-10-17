class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!

  include Dashboard::HasProposal

  helper_method :proposal, :proposed_actions, :resource, :resources, :next_goal, :next_goal_supports, :next_goal_progress, :community_members_count

  respond_to :html
  layout 'dashboard'

  private

  def proposed_actions
    @proposed_actions ||= Dashboard::Action.proposed_actions.active_for(proposal).order(order: :asc)
  end

  def resources
    @resources ||= Dashboard::Action.resources.active_for(proposal).order(order: :asc)
  end

  def next_goal_supports
    @next_goal_supports ||= next_goal&.required_supports || Setting["votes_for_proposal_success"]
  end

  def next_goal_progress
    @next_goal_progress ||= (proposal.votes_for.size * 100) / next_goal_supports.to_i
  end

  def community_members_count
    Rails.cache.fetch("community/#{proposal.community.id}/participants_count", expires_in: 1.hour) do
      proposal.community.participants.count
    end
  end

  def next_goal
    @next_goal ||= Dashboard::Action.next_goal_for(proposal)
  end
end
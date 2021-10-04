# frozen_string_literal: true

require 'rails_helper'

describe UserSerializer do
  fab!(:follower) { Fabricate(:user) }
  fab!(:followed) { Fabricate(:user) }

  before do
    ::Follow::Updater.new(follower, followed).watch_follow
  end

  def get_serializer(user, current_user:)
    UserSerializer.new(user, scope: Guardian.new(current_user), root: false).as_json
  end

  context "when no settings are restrictive" do
    before do
      SiteSetting.discourse_follow_enabled = true
      SiteSetting.follow_show_statistics_on_profile = true
      SiteSetting.follow_followers_visible = FollowPagesVisibility::EVERYONE
      SiteSetting.follow_following_visible = FollowPagesVisibility::EVERYONE
    end

    it 'total_followers field is included' do
      expect(get_serializer(followed, current_user: nil)[:total_followers]).to eq(1)
    end

    it 'total_following field is included' do
      expect(get_serializer(follower, current_user: nil)[:total_following]).to eq(1)
    end

    it 'can_see_following field is included' do
      expect(get_serializer(follower, current_user: nil)[:can_see_following]).to eq(true)
      expect(get_serializer(followed, current_user: nil)[:can_see_following]).to eq(true)
    end

    it 'can_see_followers field is included' do
      expect(get_serializer(follower, current_user: nil)[:can_see_followers]).to eq(true)
      expect(get_serializer(followed, current_user: nil)[:can_see_followers]).to eq(true)
    end

    it 'can_see_network_tab field is included' do
      expect(get_serializer(follower, current_user: nil)[:can_see_network_tab]).to eq(true)
      expect(get_serializer(followed, current_user: nil)[:can_see_network_tab]).to eq(true)
    end
  end

  context "when discourse_follow_enabled setting is off" do
    before do
      SiteSetting.discourse_follow_enabled = false
    end

    it 'total_followers field is not included' do
      expect(get_serializer(followed, current_user: followed)).not_to include(:total_followers)
    end

    it 'total_following field is not included' do
      expect(get_serializer(follower, current_user: follower)).not_to include(:total_following)
    end

    it 'can_see_following field is not included' do
      expect(get_serializer(follower, current_user: follower)).not_to include(:can_see_following)
    end

    it 'can_see_followers field is not included' do
      expect(get_serializer(follower, current_user: follower)).not_to include(:can_see_followers)
    end

    it 'can_see_network_tab field is not included' do
      expect(get_serializer(follower, current_user: follower)).not_to include(:can_see_network_tab)
    end
  end

  context "when follow_show_statistics_on_profile setting is off" do
    before do
      SiteSetting.follow_show_statistics_on_profile = false
    end

    it 'total_followers field is not included' do
      expect(get_serializer(followed, current_user: followed)).not_to include(:total_followers)
    end

    it 'total_following field is not included' do
      expect(get_serializer(follower, current_user: follower)).not_to include(:total_following)
    end

    it 'can_see_following is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_following]).to eq(true)
    end

    it 'can_see_followers is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_followers]).to eq(true)
    end

    it 'can_see_network_tab is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_network_tab]).to eq(true)
    end
  end

  context 'when follow_followers_visible does not allow anyone' do
    before do
      SiteSetting.follow_followers_visible = FollowPagesVisibility::NO_ONE
    end

    it 'total_followers field is not included' do
      expect(get_serializer(followed, current_user: followed)).not_to include(:total_followers)
    end

    it 'total_following field is included' do
      expect(get_serializer(follower, current_user: follower)[:total_following]).to eq(1)
    end

    it 'can_see_following is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_following]).to eq(true)
    end

    it 'can_see_followers is false' do
      expect(get_serializer(follower, current_user: follower)[:can_see_followers]).to eq(false)
    end

    it 'can_see_network_tab is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_network_tab]).to eq(true)
    end
  end

  context 'when follow_following_visible does not allow anyone' do
    before do
      SiteSetting.follow_following_visible = FollowPagesVisibility::NO_ONE
    end

    it 'total_followers field is included' do
      expect(get_serializer(followed, current_user: followed)[:total_followers]).to eq(1)
    end

    it 'total_following field is not included' do
      expect(get_serializer(follower, current_user: follower)).not_to include(:total_following)
    end

    it 'can_see_following is false' do
      expect(get_serializer(follower, current_user: follower)[:can_see_following]).to eq(false)
    end

    it 'can_see_followers is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_followers]).to eq(true)
    end

    it 'can_see_network_tab is true' do
      expect(get_serializer(follower, current_user: follower)[:can_see_network_tab]).to eq(true)
    end
  end
end
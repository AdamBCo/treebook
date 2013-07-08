require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase
    context "#new" do
        context "when not logged in" do
        should "redirect to the login page" do
            get :new
            assert_response :redirect
            assert_redirected_to login_path
        end
    end

        context "when logged in" do
            setup do
            sign_in users(:adam)
        end

        should "get new and return success" do
            get :new
            assert_response :success
        end

        should "should set a flash error if the friend_id params is missing" do
            get :new, {}
            assert_equal "Friend required", flash[:error]
        end

        should "display the friend's name" do
            get :new, friend_id: users(:simon)
            assert_match /#{users(:simon).full_name}/, response.body
        end

        should "assign a new user friendship" do
            get :new, friend_id: users(:simon)
            assert assigns(:user_friendship)
        end

        should "assign a new user friendship to the correct friend" do
            get :new, friend_id: users(:simon)
            assert_equal users(:simon), assigns(:user_friendship).friend
        end

        should "assign a new user friendship to the currently logged in user" do
            get :new, friend_id: users(:simon)
            assert_equal users(:adam), assigns(:user_friendship).user
        end

        should "return a 404 status if no friend is found" do
            get :new, friend_id: 'invalid'
            assert_response :not_found
        end

        should "ask if you really want to request this friendship" do
            get :new, friend_id: users(:simon)
            assert_match /Do you really want to friend #{users(:simon).full_name}?/, response.body
        end
    end 
end

  context "#create" do
    context "when not logged in" do
      should "redirect to the login page" do
        get :new
        assert_response :redirect
        assert_redirected_to login_path
      end
    end

  context "with no friend_id" do
    setup do
        post :create
      end

      should "set the flash error message" do
        assert !flash[:error].empty?
      end

      should "redirect to the site root" do
        assert_redirected_to root_path
      end
    end

  context "with a valid friend_id" do
      setup do
        post :create, friend_id: users(:nigel)
      end

      should "assign a friend object" do
          assert_equal users(:nigel), assigns(:friend)
      end

      should "assign a user_friendship object" do
        assert assigns(:user_friendship)
        assert_equal users(:adam), assigns(:user_friendship).user
        assert_equal users(:nigel), assigns(:user_friendship).friend
      end

      should "create a friendship" do
          assert users(:adam).friends.include?(users(:nigel))
      end

      should "redirect to the profile page of the friend" do
          assert_response :redirect
          assert_redirected_to profile_path(users(:nigel))
      end

      should 'set the flash success message' do
          assert flash[:success]
          assert_equal "You are now friends with #{@user_friendship.friend.first_name}", flash[:success]
      end
    end
  end
end

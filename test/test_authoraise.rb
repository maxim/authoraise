$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'authoraise'
require 'minitest/autorun'

class TestAuthoraise < Minitest::Test
  include Authoraise

  def setup
    Authoraise.strict_mode = false
  end

  def test_that_it_has_a_version_number
    refute_nil ::Authoraise::VERSION
  end

  def test_authorize_with_empty_policy_raises_error
    error = assert_raises Error do
      authorize {}
    end

    assert_match /empty/, error.message
  end

  def test_authorize_returns_true_on_true_policy
    assert authorize { |policy| policy.allow { true } }
  end

  def test_authorize_returns_false_on_false_policy
    refute authorize { |policy| policy.allow { false } }
  end

  def test_authorize_returns_true_on_any_true_policy
    assert authorize { |policy|
      policy.allow { false }
      policy.allow { true }
    }
  end

  def test_authorize_passes_options_into_policy_blocks
    authorize(user: 'ak') { |policy|
      policy.allow { |user| @passed_in_user = user }
    }

    assert_equal 'ak', @passed_in_user
  end

  def test_only_requested_options_are_passed_into_policy_blocks
    authorize(user: 'ak', post: 'opium') { |policy|
      policy.allow { |user| @lvars = local_variables }
    }

    assert_equal [:user, :policy], @lvars
  end

  def test_authorize_only_needs_one_check_with_matching_keys_to_work
    assert authorize(user: 'ak', post: 'opium') { |policy|
      policy.allow { |foo, bar| false }
      policy.allow { |user, post| true }
    }
  end

  def test_authorize_errors_out_when_no_checks_have_matching_keys
    error = assert_raises Error do
      authorize(post: 'opium') { |policy| policy.allow { |user| true } }
    end

    assert_match /missing keys.+:user/, error.message
    refute_match /:post/, error.message
  end

  def test_authorize_passes_when_any_check_with_matching_keys_returns_true
    assert authorize(user: 'ak') { |policy|
      policy.allow { |post| raise 'this should not run' }
      policy.allow { |user| true }
    }
  end

  def test_in_strict_mode_authorize_errors_out_on_missing_keys_anywhere
    Authoraise.strict_mode = true

    error = assert_raises Error do
      authorize(user: 'ak') { |policy|
        policy.allow { true }
        policy.allow { |user| true }
        policy.allow { |post| true }
        policy.allow { |foo| true }
      }
    end

    assert_match /missing keys.+:post, :foo/, error.message
    refute_match /\:user/, error.message
  end
end

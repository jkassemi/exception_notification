require 'test_helper'
require 'slack-notifier'

class SlackNotifierTest < ActiveSupport::TestCase

  test "should send a slack notification if properly configured" do
    options = {
      webhook_url: "http://slack.webhook.url"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)
  end

  test "should send the notification to the specified channel" do
    options = {
      webhook_url: "http://slack.webhook.url",
      channel: "channel"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.channel, options[:channel]
  end

  test "should send the notification to the specified username" do
    options = {
      webhook_url: "http://slack.webhook.url",
      username: "username"
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)

    assert_equal slack_notifier.notifier.username, options[:username]
  end

  test "should pass the additional parameters to Slack::Notifier.ping" do
    options = {
      webhook_url: "http://slack.webhook.url",
      username: "test",
      custom_hook: "hook",
      additional_parameters: {
        icon_url: "icon",
      }
    }

    Slack::Notifier.any_instance.expects(:ping).with(fake_notification, {icon_url: "icon"})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)
  end

  test "shouldn't send a slack notification if webhook url is missing" do
    options = {}

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)

    assert_nil slack_notifier.notifier
    assert_nil slack_notifier.call(fake_exception)
  end

  test "should send an exception with a message prefix" do
    prefix = "[prefix] "

    options = {
      webhook_url: "http://slack.webhook.url",
      message_prefix: prefix
    }

    expected_notification = "#{prefix}#{fake_notification}"
    Slack::Notifier.any_instance.expects(:ping).with(expected_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(fake_exception)
  end

  test "should send an exception when no backtrace exists on exception object" do
    backtraceless_exception = RuntimeError.new("no backtrace available")
    assert_nil backtraceless_exception.backtrace

    options = {
      webhook_url: "http://slack.webhook.url",
    }

    expected_notification = "An exception occurred: '#{backtraceless_exception.message}'"
    Slack::Notifier.any_instance.expects(:ping).with(expected_notification, {})

    slack_notifier = ExceptionNotifier::SlackNotifier.new(options)
    slack_notifier.call(backtraceless_exception)
  end

  private

  def fake_exception
    begin
      5/0
    rescue Exception => e
      e
    end
  end

  def fake_notification
    "An exception occurred: '#{fake_exception.message}' on '#{fake_exception.backtrace.first}'"
  end
end

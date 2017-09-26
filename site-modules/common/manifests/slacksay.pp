# Deploy the 'slacksay' script (posts messages to Slack)
class common::slacksay {
  $slack_webhook_url = hiera('slack_webhook_url')

  file { '/usr/local/bin/slacksay':
    content => template('common/slacksay.rb.erb'),
    mode    => '0755',
  }
}

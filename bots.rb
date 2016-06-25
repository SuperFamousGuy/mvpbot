require 'twitter_ebooks'
require 'yaml'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  def configure
    yaml_conf = YAML.load_file('.twitter_auth.yml')

    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = yaml_conf['twitter']['consumer_key']
    self.consumer_secret = yaml_conf['twitter']['consumer_secret']

    # Users to block instead of interacting with
    # self.blacklist = []

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..5
  end

  def generate_tweet(dm=false)
    model = Ebooks::Model.load("./model/mvpbot.model")
    return model.make_statement(140)
  end

  def on_startup
    scheduler.every '24h' do
      tweet(generate_tweet())
    end
  end

  def on_message(dm)
    # Reply to a DM
    reply(dm, generate_tweet(dm))
  end

  def on_follow(user)
    # Follow a user back
    follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    reply(tweet, generate_tweet())
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    reply(tweet, generate_tweet())
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet
    follow(user.screen_name)
  end

  def on_retweet(tweet)
    # Follow user who just retweeted bot's tweet
    follow(tweet.user.screen_name)
  end
end

# Make a MyBot and attach it to an account
MyBot.new("abby_ebooks") do |bot|
  yaml_conf = YAML.load_file('.twitter_auth.yml')
  bot.access_token = yaml_conf['twitter']['access_token']
  bot.access_token_secret = yaml_conf['twitter']['access_token_secret']
end

# Twilio Intro

This tutorial will walk you through creating an application that allows you to
send and receive text messages in your web browser using [Ruby](ruby),
[Sinatra](sinatra), and [Twilio](twilio).

### Learning Goals

- Use the Twilio API to send SMS messages
- Use the Twilio API to receive SMS messages
- Create a web interface for working with SMS messages from the Twilio API

### Getting Started

Before we start writing any code, let's make sure we've got all of the tools
that we're going to need.

First, head over to [Twilio](twilio) and sign up for an account. You can get an
account and number for free. The free plan does have some restrictions but you
can use it to get started and send messages before you have to decide whether or
not you want to add some money to your account.

We're going to use [Bundler](bundler) to keep track of and install all of our
dependencies. If you're not yet familiar with [Bundler](bundler), head over to
[bundler.io](bundler) and give it a read.

Start by creating a file named `Gemfile` in the root directory of your project.
We're going to be using the [twilio-ruby](twilio-ruby) gem to interact with
Twilio's API, so we should also add it to our `Gemfile`.

```ruby
# Gemfile

source 'https://rubygems.org'

gem 'twilio-ruby'
```

**Make sure you've got all of the gems installed by running `bundle install`.**

### Authenticating Your Requests

Create a file named `app.rb`. We'll use this to hold the code for our
application.

Before we can start interacting with the Twilio API, we need to configure
[twilio-ruby](twilio-ruby) to use our account credentials to authenticate our
requests.

```ruby
# app.rb

require 'twilio-ruby'

# Configure twilio-ruby with your Twilio account credentials
# You can find yours at https://www.twilio.com/user/account
Twilio.configure do |config|
  config.account_sid = '<YOUR_ACCOUNT_SID>'
  config.auth_token = '<YOUR_AUTH_TOKEN>'
end
```

> How do I know how to do such magic? As with all (good) gems, you can find
> information about how to use it in the [README](twilio-ruby).

### Storing Your Configuration in the Environment

You can think of your "account_sid" and "auth_token" like your username and
password for using the Twilio API. You don't want other people using your
credentials to send requests.

If you're planning on adding this project to your GitHub, you certainly don't
want people to be able to see what your credentials are.

A common way to solve this problem is to rely on [environment
variables](environment-variables) for your application's configuration. You can
read more about the philosophy behind this at [12factor.net](12factor).

We can use the [dotenv](dotenv) gem to easily define the environment variables
for our development environment and export them each time we run our app.

Add the [dotenv](dotenv) gem to your `Gemfile`, and run `bundle install`:

```ruby
# Gemfile

source 'https://rubygems.org'

gem 'dotenv'
gem 'twilio-ruby'
```

Since we're going to be defining our environment variables in a file inside of
our git repo, we want to make sure that this file is ignored by git and not
added to our repository. **This is very important because this is what keeps our
credentials from being visible when we push our project to GitHub.**

Create a file named `.gitignore` in the root directory of your project:

```ruby
# .gitignore

.env
```

> A `.gitignore` allows you to specify file name patterns that you want to
> ignore. You can read more about this at [GitHub Help - Ignoring
> Files](ignoring-files).

Create a `.env` file that we can use to store our Twilio API credentials
as environment variables:

```no-highlight
# .env

# Use your Twilio API credentials here
TWILIO_ACCOUNT_SID=123567890ABCDEFGHIJHKLMNOP
TWILIO_AUTH_TOKEN=123567890ABCDEFGHIJHKLMNOP
```

Update `app.rb` to reference these environment variables rather than hard
coding our credentials into the app:

```ruby
# app.rb

require 'dotenv'
require 'twilio-ruby'

Dotenv.load

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end
```

### Sending an SMS

Now that we've configured [twilio-ruby](twilio-ruby) to use our credentials we
can create a client that we can use to talk to Twilio:

```ruby
# app.rb

require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

# Create a client to talk to Twilio
client = Twilio::REST::Client.new
```

The client that we created can be used to do a lot of awesome things using
Twilio. We can send text messages, multimedia messages, and even call people.

We're going to start by sending a text message to ourself:

```ruby
# app.rb

require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

client = Twilio::REST::Client.new

# Send a new SMS message to yourself
client.messages.create(
  from: '<YOUR_TWILIO_NUMBER>',
  to: '<YOUR_REAL_NUMBER>',
  body: 'YO. I am a robot.'
)
```

> If you're having trouble getting messages to send, make sure that you're
> providing both numbers in the correct format. Ex: "+12345678900".

Let's try that again but this time we'll include a picture:

```ruby
# app.rb

require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

client = Twilio::REST::Client.new

# Send a new MMS message to yourself
client.messages.create(
  from: '<YOUR_TWILIO_NUMBER>',
  to: '<YOUR_REAL_NUMBER>',
  body: 'It\'s such a good vibration',
  media_url: 'http://i.imgur.com/HefNmTU.jpg'
)
```

> You might want to take some time to also set up your Twilio number and your
> real number as environment variables so you can avoid having them included in
> your git repo.

### Moving to the web

Now that we've figured out how to send text messages, let's use
[Sinatra](sinatra) to build a web interface that lets us view all the incoming
and outgoing messages.

Since our application is going to be depending on having the sinatra gem
available, we should add it to our `Gemfile` and run `bundle install`:

```ruby
# Gemfile

source 'https://rubygems.org'

gem 'dotenv'
gem 'sinatra'
gem 'twilio-ruby'
```

> Don't forget to run `bundle install`.

Let's create the index page for our app:

```ruby
# app.rb

require 'sinatra'
require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

get '/' do
  client = Twilio::REST::Client.new

  # Retrieve an array of Message objects from Twilio
  @messages = client.messages.list

  erb :index
end
```

Each messages in our `@messages` array has a few methods that allow us to access
some information about it.

In our view template, we can use the `#to`, `#from`, and `#body` methods to
display information about each message:

```html
<!-- views/index.erb -->

<h1>Messages</h1>

<% @messages.each do |message| %>
  <h3>From <%= message.from %> to <%= message.to %></h3>
  <p><%= message.body %></p>
<% end %>
```

**Go try out the app and make sure everything is working!**

### Filtering messages

You might have noticed that we're currently listing both incoming and outgoing
messages from our account. If you haven't, try responding to one of the text
messages that you sent yourself. You should be able to see it in the list.

To produce the user interface that we want, we're going to work on making the
index only display incoming messages. Later, we'll add another page where we can
view the whole conversation between our app and any particular number.

Twilio allows us to filter the messages that we're listing by providing either a
"to" or "from" number. In our case, we want to provide a "to" number that is
your Twilio number so we only see incoming messages displayed on our index
page:

```ruby
# app.rb

get '/' do
  client = Twilio::REST::Client.new
  @messages = client.messages.list(to: '<YOUR_TWILIO_NUMBER>')

  erb :index
end
```

**Restart your Sinatra app and make sure the changes worked!**

### Viewing a Conversation

Now that we can view our incoming messages, it would be nice if we could click
on the message to view the whole conversation between our Twilio number and the
number that sent the message.

We'll make a new route that takes the sender's phone number as a dynamic segment
so that we can retrieve all of the messages that we've sent and received by that
number.

```ruby
# app.rb

get '/conversations/:sender_number' do
  client = Twilio::REST::Client.new
  @sender_number = params[:sender_number]

  erb :'conversations/show'
end
```

And then we'll make a view template for displaying the conversation:

```html
<!-- views/conversations/show.erb -->

<h1>Conversation with <%= @sender_number %></h1>
```

**Make sure you take a minute to try visiting the newly created route.**

Twilio doesn't give us an easy way to retrieve all of the messages between two
numbers but we can make it work.

First, we need to get all of the incoming messages that were sent "to" our Twilio number by
"from" sender's number:

```ruby
# app.rb

get '/conversations/:sender_number' do
  client = Twilio::REST::Client.new
  @sender_number = params[:sender_number]

  incoming = client.messages.list(from: @sender_number, to: '<YOUR_TWILIO_NUMBER>')

  erb :'conversations/show'
end
```

Then we want to get all of the outgoing messages that were sent "from" our
Twilio number "to" the sender's number:

```ruby
# app.rb

get '/conversations/:sender_number' do
  client = Twilio::REST::Client.new
  @sender_number = params[:sender_number]

  incoming = client.messages.list(from: @sender_number, to: '<YOUR_TWILIO_NUMBER>')
  outgoing = client.messages.list(from: '<YOUR_TWILIO_NUMBER>', to: @sender_number)

  erb :'conversations/show'
end
```

Now we can add those two arrays of messages together to get the entire
conversation between our Twilio number and the sender's number:

```ruby
# app.rb

get '/conversations/:sender_number' do
  client = Twilio::REST::Client.new
  @sender_number = params[:sender_number]

  incoming = client.messages.list(from: @sender_number, to: '<YOUR_TWILIO_NUMBER>')
  outgoing = client.messages.list(from: '<YOUR_TWILIO_NUMBER>', to: @sender_number)

  @messages = incoming + outgoing

  erb :'conversations/show'
end
```

And then we can display the messages in our view template for the conversation:

```html
<!-- views/conversations/show.erb -->

<h1>Conversation with <%= @sender_number %></h1>

<% @messages.each do |message| %>
  <h3>From <%= message.from %> to <%= message.to %></h3>
  <p><%= message.date_sent %></p>
  <p><%= message.body %></p>
<% end %>
```

And finally, before we send our messages to the view template we should probably
put them in order of when they were sent so we can follow the conversation:

```ruby
# app.rb

get '/conversations/:sender_number' do
  client = Twilio::REST::Client.new
  @sender_number = params[:sender_number]

  incoming = client.messages.list(from: @sender_number, to: '<YOUR_TWILIO_NUMBER>')
  outgoing = client.messages.list(from: '<YOUR_TWILIO_NUMBER>', to: @sender_number)

  @messages = (incoming + outgoing).sort_by do |message|
    message.date_sent
  end

  erb :'conversations/show'
end
```

You can improve the user interface by adding a link to each of messages
displayed on the index page that brings you to the conversation page:

```html
<!-- views/index.erb -->

<h1>Messages</h1>

<% @messages.each do |message| %>
  <h3>
    From
    <a href="/conversations/<%= message.from %>"><%= message.from %></a>
    to <%= message.to %>
  </h3>

  <p><%= message.body %></p>
<% end %>
```

### The Next Step

- **Reply to incoming messages:** Using what you've already learned about how to send SMS messages
  programmatically, create a form on the conversation page that allows a user to
  reply to incoming messages.
- **Style the app:** Nobody wants to use an app that looks like this!
- **Do more cool stuff with Twilio:** Sending SMS messages isn't the only thing
  that Twilio lets you do. Check out [the rest of the
  docs](twilio-ruby-helper-api) to find out how to do more cool stuff.

[bundler]: http://bundler.io/ "Bundler"
[dotenv]: https://github.com/bkeepers/dotenv "dotenv"
[environment-variables]: http://en.wikipedia.org/wiki/Environment_variable "Environment Variables"
[ignoring-files]: https://help.github.com/articles/ignoring-files/ "Ignoring Files"
[ruby]: http://ruby-lang.org/ "Ruby"
[twilio-ruby-helper-api]: http://twilio-ruby.readthedocs.org/en/latest/index.html "Twilio Ruby Helper API"
[twilio-ruby]: https://github.com/twilio/twilio-ruby "Twilio gem"
[twilio]: http://twilio.com/ "twilio"

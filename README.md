# Codebreaker

Welcome to codebreaker gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/codebreaker`. To experiment with that code, run `bin/console` for an interactive prompt.
To play game, run 'lib/console.rb'.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codebreaker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codebreaker

## Usage

This is a full game with complete process. It consists of 6 stages:
- main menu(:menu);
- game(:game);
- show result(:complete_game);
- save result is optional stage(:save_score);
- play again question(:repeate);
- show scores(:scores).

In your application you need to require 'codebreaker' and create new instance of GameProcess:
```ruby
require 'codebreaker'
game = Codebreaker::GameProcess.new
```

To management of game process use function:

```ruby
game.listens_and_shows(option) #option is a string with option see below
```
Therer is choise is option for each stage. This function returns symbol named as next stage if process change stage or returns nil if process stays the same.
*The first stage is 'menu', so you need to implement describing for it.

The stages can get and work on the next choises:
```ruby
menu: ["new game", "scores", "exit"]
game: ["hint", "restart", '1234'] 
# 1234 can be any string with 4 digits. 
# Each diget between 1 and 6 enclusive both
complete_game: ["yes", "no"]
save_score: ["name"]
# pass player name
repete: ["yes", "no"]
scores: ["back"]
:exit # was implemented for console application

```
The answer after each listens_and_shows(option) method you can get from game.answers:
```ruby
command = "scores"
game.listens_and_shows(command)
puts game.answers # contain the array of scores
```
All another answers are Strings.

In the game stage you can know how many guesses and hints do you have, use:
```ruby
game.remaining_guess
game.remaining_hint
```
Both return number. In the another stage both return nil.

Scores are saved into 'scores.yaml' file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andreykraveckiy/codebreaker.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


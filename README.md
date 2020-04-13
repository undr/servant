# Servant

Build an army of servants and king it over them.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'servant'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install servant
```

## Usage

```ruby
module Services
  class UpsertSomething < Servant::Base
    context do
      argument :attributes, type: Hash, presence: true
      argument :export_to, type: String
    end

    def perform
      (find_and_update_something || create_something).tap do |something|
        send_to_somewhere(something) if context.export_to
      end
    end

    private

    def somewhere
      context.options[:somewhere]
    end

    def send_to_somewhere(something)
      result = Services::ExportToSomewhere.perform(something: something, to: context.export_to)
      error!('impossible to export it to somewhere', :export) unless result.success?
    end

    def create_something
      Services::CreateSomething.perform(attributes: context.attributes).tap do |result|
        halt_with!(result.errors) unless result.success?
      end.value
    end

    def find_and_update_something
      result = Services::FindSomething.perform(context.attributes)
      halt!('impossible accurately determinate a Something') if result.failed? || result.value.count > 1
      something = result.value.first

      if something
        if something.update_attributes(context.attributes)
          something
        else
          halt_with!(something.errors)
        end
      end
    end
  end
end
```

```ruby
module Services
  class CreateSomething < Servant::Base
    context do
      argument :name, type: String, presence: true
      argument :description, type: String, presence: true
      argument :rating, type: Integer, default: 0
    end

    def perform
      Something.new(context.to_hash).tap do |something|
        merge_errors!(something.errors) unless something.save
      end
    end
  end
end
```

```ruby
module Services
  class FindSomething < Servant::Base
    context do
      argument :name, type: String, presence: true
    end

    def perform
      Something.where(name: context.name)
    end
  end
end
```

```ruby
 result = Services::UpsertSomething.perform(attributes: params, export_to: :somewhere)

 if result.success?
   # Do whatever you want with `result.value`
 else
   # handle errors using `result.errors`
 end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/undr/servant.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

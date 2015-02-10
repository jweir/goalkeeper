# Goalkeeper

Goalkeeper is a simple system for tracking if system wide requirements have been met. It is a TODO list for your application.

An example usage would be validating if each customer was sent a daily report.


##### Installation

Add this line to your application's Gemfile:

```ruby
gem 'goalkeeper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install goalkeeper

## Usage

### Goal
| method     | description                                                | example                                  |
| --------   | ------                                                     | -----                                    |
| new(label) | Creates a new Goal with the unique label                   | `g = Goal.new('process')`                |
| met?       | Returns true if the Goal has been met                      | `g.met? #=> false`                       |
| met!       | Marks the goal as completed with a timestamp               | `g.met! #=> Time.now`                    |
| met\_at    | Nil if unmet, otherwise returns the time the Goal was met. | `g.met_at #=> 2015-02-09 22:24:07 -0500` |
| ttl        | The Redis ttl value if there is a record for the goal.     | `g.ttl #=> 86400`                       |
| key        | The key used to store the record in Redis.                 | `g.key #=> "Goalkeeper:process"`         |
| clear!     | Deletes the `met` record.  Goal is now unmet.              | `g.clear!`                               |


### Set
| method     | description                                                             | example                                  |
| --------   | ------                                                                  | -----                                    |
| new        | creates an empty set of goals.                                          | `s = set.new`                            |
| add(label) | Adds a new Goal the Set. _chainable_                                    | `s.add('process.a').add('process.b')`    |
| met?       | Returns true if _all_ the Set's Goals have been met.                    | `s.met? #=> false`                       |
| met!       | Calls `met!` on all Goals.                                              | `s.met! #=> Time.now`                    |
| met\_at    | Returns the most recent met_at for the Set's Goals. Nil if no Goal met. | `s.met_at #=> 2015-02-09 22:24:07 -0500` |
| clear!     | Calls `clear!` on all Goals.                                            | `s.clear!`                               |
| met        | Returns a new Set with all Goals which have been met.                   | `s.met #=> Set(...)`                     |
| unmet      | Returns a new Set with all Goals which have not been met.               | `s.unmet` #=> Set(...)                   |

### Goalkeeper
| method        | description                          | example |
| --------      | ------                               | -----   |
| ::met!(label) | Creates a new Goal and marks it met. | `Goalkeeper.met!('process') #=> <Goalkeepr::Goal>`

## Contributing

1. Fork it ( https://github.com/jweir/goalkeeper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

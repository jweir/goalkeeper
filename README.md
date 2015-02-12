# Goalkeeper

Goalkeeper is a simple system for tracking if unique label(Goal) has been met.  A Set of
goals can be combined to check if all of them have been completed. Goalkeeper is backed by and requires Redis.

_No initialization of Goals is required.  Either is Goal exists in Redis and is
met, or it does not exist and is unmet._

### Examples

Check if each customer was sent a report today

```ruby
# send the report and mark the report as sent
def send_report(customer)
  deliver
  Goalkeeper.met!("report:#{customer.id}")
end

# warn for any customer whose report has not been sent
def check
  Customers.all.map |customer|
    warn(customer) unless Goalkeeper.met?("report:#{customer.id}")
  end
end
```

Wait for a set of processes to be met before starting another.
```ruby
# We need to wait for the prices and award data to be downloaded
def email_on_complete
  set = Goalkeeper::Set.new.
    add("prices:#{Date.today}").
    add("awards:#{Date.today}")

  if set.met?
    log.info "Downloaded completed #{set.met_at}"
    deliver
  else
    log.info "These tasks are not complete #{set.unmet.map(&:label)}"
    retry_later
  end
end

# elsewhere the code to get the data and mark it complete
def download_prices
  if fetch
    Goalkeeper.met!('prices:#{Date.today}')
  end
end

def download_awards
  if fetch
    Goalkeeper.met!('awards:#{Date.today}')
  end
end
```

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'goalkeeper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install goalkeeper

### Usage

Its goes likes this...

You might never need to reference the Goal class.  Most everything can be done via Goalkeeper and Goalkeeper::Set.

```ruby
Goalkeeper.met? "label" #=> false
Goalkeeper.met! "label" #=> <Goalkeeper::Goal>
Goalkeeper.met? "label" #=> true
```
   
But lets have a granular example.  Lets ensure we wakeup New Years Day 2020.
The Goal will be named 'wakeup:2020-01-01'

```ruby
g = Goalkeeper::Goal.new('wakeup:2020-01-01')
g.met? #=> false
```

Time flies... it is New Years Day 2020.

```ruby
g.met! # or Goalkeeper.met!('wakeup:2020-01-01')
g.met? #=> true
g.met_at #=> 2020-01-01 05:01:31 -0500
```

Now if our application checks our goal, it will be met.

```ruby
Goalkeeper.met?('wakeup:2020-01-01') #=> true
# or
Goalkeeper::Goal.new('wakeup:2020-01-01').met? #=> true
```
  
Note: Once a Goal is 'met' the 'met\_at' timestamp will not change, unless
'clear!' is called.

We are probably only interested in this goal being complete for a limited
time, so it will expire and be removed from Redis.

```ruby
g.ttl #=> 86400 (1 day)
```

If you need to reference the Redis key

```ruby
g.key #=> Goalkeeper:wakeup:2020-01-01
```

Finally deleting the Goal is simple

```ruby
g.clear!
g.met? #=> false
```

#### Sets

Perhaps you have a series of Goals you want to track, and see if they all have been met, or not.

```ruby
set = Goalkeeper::Set.new
set.add('goal1').add('goal2')
set.met? #=> false
```

Lets have 1 goal met:

```ruby
Goalkeeper.met!('goal1')
```

But our set is not met yet

```ruby
set.met? #=> false
```

See which goals are met, or unmet

```ruby
set.met #=> [#<Goalkeeper::Goal @label="goal1">]
set.unmet #=> [#<Goalkeeper::Goal @label="goal2">]
```

Lets complete our set.

```ruby
Goalkeeper.met!('goal1')
set.met? #=> true
```

See the time the final goal was met

```ruby
set.met_at #=> 2015-01-01 08:02:15 -0500
```

#### Customization

Customize the redis client by setting it in your application

```ruby
Goalkeeper.redis = your_redis_client
```

Each record has a default expiration of 24 hours, but this can be modified.

```ruby
Goalkeeper.expiration = number_of_seconds
```

Redis keys are stored under the default namespace of "Goalkeeper:". The
namespace can be configured:

```ruby
Goalkeeper.namespace = string
```

## API

#### Goal
| method     | description                                                | example                                  |
| --------   | ------                                                     | -----                                    |
| new(label) | Creates a new Goal with the unique label                   | `g = Goal.new('process')`                |
| met?       | Returns true if the Goal has been met                      | `g.met? #=> false`                       |
| met!       | Marks the goal as completed with a timestamp               | `g.met! #=> Time.now`                    |
| met\_at    | Nil if unmet, otherwise returns the time the Goal was met. | `g.met_at #=> 2015-02-09 22:24:07 -0500` |
| ttl        | The Redis ttl value if there is a record for the goal.     | `g.ttl #=> 86400`                       |
| key        | The key used to store the record in Redis.                 | `g.key #=> "Goalkeeper:process"`         |
| clear!     | Deletes the `met` record.  Goal is now unmet.              | `g.clear!`                               |


#### Set
| method     | description                                                             | example                                  |
| --------   | ------                                                                  | -----                                    |
| new        | creates an empty set of goals.                                          | `s = set.new`                            |
| add(label) | Adds a new Goal the Set. _chainable_                                    | `s.add('process.a').add('process.b')`    |
| met?       | Returns true if _all_ the Set's Goals have been met.                    | `s.met? #=> false`                       |
| met\_at    | Returns the most recent met_at for the Set's Goals. Nil if no Goal met. | `s.met_at #=> 2015-02-09 22:24:07 -0500` |
| met        | Returns a new Set with all Goals which have been met.                   | `s.met #=> Set(...)`                     |
| unmet      | Returns a new Set with all Goals which have not been met.               | `s.unmet` #=> Set(...)                   |

### Goalkeeper
| method        | description                          | example |
| --------      | ------                               | -----   |
| ::met!(label) | Creates a new Goal and marks it met. | `Goalkeeper.met!('process') #=> <Goalkeepr::Goal>`
| ::met?(label) | Checks if the label has been met or not | `Goalkeeper.met?('process') #=> true`

## Contributing

1. Fork it ( https://github.com/jweir/goalkeeper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

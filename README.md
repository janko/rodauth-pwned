# rodauth-pwned

[Rodauth] feature that checks user passwords against the [Pwned Passwords API]
(using the [Pwned] rubygem).

## Installation

```rb
gem "rodauth-pwned"
```

## Usage

All you need to do is enable the `pwned_password` Rodauth feature provided by
this gem, and new passwords will be automatically checked.

```rb
plugin :rodauth do
  enable :pwned_password, ...
  # ...
end
```

### Allowed count

You can still accept passwords that have only been exposed a small number of
times:

```rb
plugin :rodauth do
  # ...
  password_allowed_pwned_count 5 # allow password to be pwned up to 5 times
end
```

### Validation error message

You can change the default validation error message:

```rb
plugin :rodauth do
  # ...
  password_pwned_message "has been pwned"
end
```

### Request options

You can pass additional request options to the [Pwned] gem:

```rb
plugin :rodauth do
  # ...
  pwned_request_options open_timeout: 1, read_timeout: 5, headers: { "User-Agent" => "MyApp" }
end
```

### Handling network errors

By default, any network errors to the Pwned Passwords API will be ignored, and
the password will be considered not pwned. You can hook into these errors:

```rb
plugin :rodauth do
  # ...
  on_pwned_error { |error| Raven.capture_exception(error) }
end
```

### API

The feature exposes two public methods which you can use in your own code:

* `password_pwned?(password)` – whether given password is considered pwned
* `pwned_count(password)` – how many times has the given password been pwned

```rb
rodauth.password_pwned?("password123") #=> true
rodauth.pwned_count("password123")     #=> 123063
```

You can also override these two methods:

```rb
plugin :rodauth do
  # ...
  password_pwned? { |password| ... }
  pwned_count { |password| ... }
end
```

### Warning users with pwned passwords

If a user's password becomes pwned, you may want to warn them on login:

```rb
plugin :rodauth do
  # ...
  after_login do
    db.after_commit do # better to make HTTP requests outside of transactions
      if param_or_nil(password_param) && password_pwned?(param(password_param))
        set_redirect_error_flash "Your password has previously appeared in a data breach and should never be used. We strongly recommend you change your password."
      end
    end
  end
end
```

## Development

Run tests with Rake:

```sh
$ bundle exec rake test
```

## Credits

This gem has been inspired by [devise-pwned_password].

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rodauth::Pwned project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/janko/rodauth-pwned/blob/master/CODE_OF_CONDUCT.md).

[Rodauth]: https://github.com/jeremyevans/rodauth
[Pwned Passwords API]: https://haveibeenpwned.com/Passwords
[Pwned]: https://github.com/philnash/pwned
[devise-pwned_password]: https://github.com/michaelbanfield/devise-pwned_password

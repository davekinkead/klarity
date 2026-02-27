# Klarity

A static dependency analyzer for Ruby code that identifies coupling between classes, modules, and services.

## Features

- **Message Detection**: Tracks all method call receivers (constants, instance variables, local variables)
- **Reference Tracking**: Captures all CamelCase constant references throughout code
- **Inheritance Detection**: Identifies class inheritance chains
- **Mixin Detection**: Detects `include`, `extend`, and `prepend` calls
- **ActiveRecord Associations**: Detects Rails associations (`belongs_to`, `has_many`, `has_one`, `has_and_belongs_to_many`) and infers class names
- **Dynamic Method Detection**: Identifies usage of `send`, `method_missing`, `define_method`, etc.
- **Directory Scanning**: Recursively scans Ruby files with include/exclude patterns
- **Multiple Output Formats**: Ruby Hash or JSON, or interactive HTML visualization

## Installation

```bash
gem install klarity
```

Or add to your Gemfile:

```ruby
gem 'klarity'
```

## Usage

### Command Line Interface

```bash
# Analyze a directory
klarity ./app

# With JSON output
klarity ./app --json

# Generate interactive HTML visualization
klarity ./app --html

# Exclude specific patterns
klarity ./app --exclude "*/concerns/*" --exclude "*/test/*"

# Include only specific patterns
klarity ./app --include "**/*service.rb"

# Show help
klarity --help
```

### Programmatic API

```ruby
require 'klarity'

# Analyze a directory
result = Klarity.analyze('/path/to/project')

# Access dependency information
result.each do |class_name, dependencies|
  puts "#{class_name}:"
  puts "  Inherits: #{dependencies[:inherits]}"
  puts "  Mixins: #{dependencies[:mixins]}"
  puts "  Messages: #{dependencies[:messages]}"
  puts "  References: #{dependencies[:references]}"
  puts "  Dynamic: #{dependencies[:dynamic]}"
  puts "  Associations: #{dependencies[:associations]}"
end

# With options
result = Klarity.analyze('/path/to/project',
  exclude_patterns: ['*/concerns/*'],
  include_patterns: ['**/*service.rb']
)
```

## Output Format

### JSON

```ruby
{
  "UserService" => {
    inherits: [],
    mixins: [],
    messages: ["UserRepository", "NotificationService", "@notifier"],
    references: ["UserRepository", "NotificationService", "EmailValidator"],
    dynamic: ["send"],
    associations: []
  }
}
```

### Interactive HTML

Using the `--html` flag generates an interactive web visualization with:

- **Force-directed graph** with pan and zoom
- **Edge type filtering** - toggle visibility for inherits, mixins, messages, references, associations, and dynamic dependencies
- **Color-coded edges** for quick visual distinction of dependency types
- **Search functionality** - filter nodes by class/module name
- **Interactive details panel** - click any node to see all dependencies with counts
- **Multiple layouts** - force-directed, hierarchical, circular, and grid
- **Export capability** - save the graph as a PNG image
- **Coupling metrics** - see total dependency count per class

The HTML file is self-contained and can be shared or opened on any device with a web browser. No server required.

### Fields

- **`inherits`**: Array of parent classes this class inherits from
- **`mixins`**: Array of modules included/extended/prepended
- **`messages`**: Array of all message receivers (constants, instance variables, local variables)
- **`references`**: Array of all CamelCase constant references in the class
- **`dynamic`**: Array of dynamic method names used (`send`, `method_missing`, `define_method`, etc.)
- **`associations`**: Array of ActiveRecord associations with inferred class names (e.g., `has_many :orders` → `Order`)

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## What Klarity Detects

### Static Dependencies

- Direct method calls: `User.save`, `Database.query`
- Instance variable receivers: `@repository.find(id)`, `@cache.get(key)`
- Local variable receivers: `service.call()`, `validator.validate(data)`
- Constant references: `User`, `PaymentGateway::Client`
- Array type checks: `[User, Admin].include?(object.class)`
- Case statement types: `case object; when User, Admin; end`
- Keyword argument defaults: `def initialize(repo: Repository.new)`

### ActiveRecord Associations

- `belongs_to`: Ownership associations (e.g., `belongs_to :user`)
- `has_many`: One-to-many associations with class name inference (e.g., `has_many :orders` → `Order`)
- `has_one`: One-to-one associations (e.g., `has_one :profile`)
- `has_and_belongs_to_many`: Many-to-many associations with class name inference (e.g., `has_and_belongs_to_many :tags` → `Tag`)
- Custom class names: Supports `class_name:` option (e.g., `belongs_to :author, class_name: 'Person'`)
- Namespaced associations: Handles qualified class names (e.g., `Taxonomy::Category`)

### Dynamic Dependencies

- `send`, `public_send`, `__send__`
- `method_missing`, `respond_to_missing?`
- `define_method`, `define_singleton_method`
- `instance_variable_get`, `instance_variable_set`
- `const_get`, `const_set`
- `respond_to?`

## Limitations

- **Runtime DI**: Dependencies injected at call time without defaults are not detected
- **DI Containers**: Framework-specific DI containers (e.g., `container.resolve(:repo)`) are not tracked
- **Mock/Stub Substitutions**: Test doubles used in place of real dependencies
- **Type Erasure**: Cannot determine type of instance/local variables without explicit usage

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/username/klarity.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

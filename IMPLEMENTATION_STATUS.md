# Klarity - Implementation Progress

## What's Been Implemented

### ✅ Phase 1: Foundation

1. **DependencyGraph** (`lib/klarity/dependency_graph.rb`)
   - Stores dependency information for classes/modules
   - Supports merging multiple graphs
   - Deduplicates messages, mixins, and references automatically

2. **FileScanner** (`lib/klarity/file_scanner.rb`)
   - Recursively scans directories for `.rb` files
   - Supports inclusion/exclusion patterns
   - Excludes common directories (vendor, node_modules, .git, etc.)

3. **Visitor** (`lib/klarity/visitor.rb`)
   - Extends `Prism::Visitor` for AST traversal
   - Tracks classes and modules with namespacing
   - Handles nested class/module definitions

4. **Analyzer** (`lib/klarity/analyzer.rb`)
   - Orchestrates analysis pipeline
   - Scans files, parses with Prism, traverses AST
   - Merges results from multiple files
   - Handles parse errors gracefully

5. **Main API** (`lib/klarity.rb`)
   - Simple entry point: `Klarity.analyze(directory, **options)`
   - Returns dependency graph as Ruby Hash

### ✅ Phase 2: Detectors

#### Messages Detector
- Detects method invocations with explicit receivers
- Detects calls to instance variables: `@repo.find(id)`
- Detects calls to local variables: `service.call()`
- Detects calls to class variables and global variables
- Handles implicit receiver (self) by excluding it

#### References Detector
- Tracks ALL CamelCase constants throughout code
- Captures `ConstantReadNode` and `ConstantPathNode`
- Works recursively through arrays, arguments, method calls
- Comprehensive constant tracking regardless of context

#### Inheritance Detector
- Detects class inheritance from `ClassNode.superclass`
- Builds fully qualified names for nested classes
- Tracks inheritance chains
- Handles simple and namespaced parent classes

#### Mixins Detector
- Detects `include`, `extend`, and `prepend` calls
- Extracts module names from arguments
- Deduplicates mixins
- Handles namespaced modules (e.g., `ActiveModel::Validations`)

#### Dynamic Methods Detector
- Detects usage of `send`, `public_send`, `__send__`
- Detects usage of `method_missing`, `respond_to_missing?`
- Detects usage of `define_method`, `define_singleton_method`
- Detects usage of `instance_variable_get`, `instance_variable_set`
- Detects usage of `const_get`, `const_set`
- Detects usage of `respond_to?`, `respond_to_missing?`
- Tracks both method calls and method definitions

### ✅ Phase 3: CLI

1. **CLI** (`lib/klarity/cli.rb`)
   - Command-line interface for Klarity
   - Argument parsing (directory, --exclude, --include, --json, --help)
   - Error handling and help messages
   - Returns values (no side-effects)
   - Supports JSON output format

2. **Executable** (`bin/klarity`)
   - Executable script for running Klarity
   - Located in `bin/` directory

3. **Options Supported**
   - `--exclude PATTERN`: Glob pattern to exclude files
   - `--include PATTERN`: Glob pattern to include files
   - `--json`: Output as JSON
   - `--help`, `-h`: Show help message

### ✅ Testing

28 tests covering:
- Message detection and deduplication
- Reference tracking (all constants)
- Inheritance detection
- Mixin detection (include/extend/prepend)
- Dynamic method detection
- Module and namespace handling
- Edge cases (empty classes, syntax errors, missing directories)
- Integration tests
- CLI tests (help, options, errors, JSON output)
- Array include pattern detection
- Keyword argument default detection
- Variable receiver tracking

All tests passing ✅

### ✅ Fixtures

Test fixtures in `spec/fixtures/sample_app/`:
- `user.rb` - User class with service calls
- `order.rb` - Order class with service calls
- `services.rb` - Service classes
- `modules.rb` - Module with nested class
- `empty.rb` - Empty class
- `inheritance.rb` - Inheritance and mixin examples
- `array_include.rb` - Array include? type checking patterns
- `dependency_injection.rb` - Keyword argument default patterns
- `dynamic_references.rb` - Dynamic method usage examples

## Output Format

```ruby
{
  "ClassName" => {
    inherits: ["SuperClass"],
    mixins: ["Module::Mixin", "AnotherMixin"],
    messages: ["Service1", "Service2", "@instance_var", "local_var"],
    references: ["Service1", "Service2", "Type1", "Type2"],
    dynamic: ["send", "method_missing"]
  }
}
```

### Fields

- **`inherits`**: Array of parent classes this class inherits from
- **`mixins`**: Array of modules included/extended/prepended
- **`messages`**: Array of all message receivers (constants, instance variables, local variables)
- **`references`**: Array of all CamelCase constant references in the class
- **`dynamic`**: Array of dynamic method names used

## Usage

### Programmatic API

```ruby
require 'klarity'

result = Klarity.analyze('/path/to/project')
result.each do |class_name, dependencies|
  puts "#{class_name}:"
  puts "  Inherits: #{dependencies[:inherits]}"
  puts "  Mixins: #{dependencies[:mixins]}"
  puts "  Messages: #{dependencies[:messages]}"
  puts "  References: #{dependencies[:references]}"
  puts "  Dynamic: #{dependencies[:dynamic]}"
end
```

### CLI

```bash
# Default Ruby inspect output
klarity ./app

# JSON output
klarity ./app --json

# With patterns
klarity ~/projects/myapp/app --exclude "*/concerns/*"
klarity ./app --include "**/*service.rb"

# Help
klarity --help
```

## Dependencies

Runtime: `prism` (~> 1.0)
Development: `rspec` (~> 3.12), `rubocop` (~> 1.60)

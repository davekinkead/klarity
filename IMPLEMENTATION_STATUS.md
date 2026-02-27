# Klarity - Implementation Progress

## What's Been Implemented

### ✅ Phase 1: Foundation

1. **DependencyGraph** (`lib/klarity/dependency_graph.rb`)
   - Stores dependency information for classes/modules
   - Supports merging multiple graphs
   - Deduplicates messages and mixins automatically

2. **FileScanner** (`lib/klarity/file_scanner.rb`)
   - Recursively scans directories for `.rb` files
   - Supports inclusion/exclusion patterns
   - Excludes common directories (vendor, node_modules, .git, etc.)

3. **Visitor** (`lib/klarity/visitor.rb`)
   - Extends `Prism::Visitor` for AST traversal
   - Tracks classes and modules with namespacing
   - Handles nested class/module definitions
   - Tracks method invocations (implicit receiver = self, explicit = receiver)

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
- Detects method invocations
- Handles implicit and explicit receivers
- Deduplicates messages (one per unique object type)

#### Inheritance Detector
- Detects class inheritance from `ClassNode.superclass`
- Builds fully qualified names for nested classes
- Tracks inheritance chains

#### Mixins Detector
- Detects `include`, `extend`, and `prepend` calls
- Extracts module names from arguments
- Deduplicates mixins
- Handles namespaced modules (e.g., `ActiveModel::Validations`)

### ✅ Phase 3: CLI

1. **CLI** (`lib/klarity/cli.rb`)
   - Command-line interface for Klarity
   - Argument parsing (directory, --exclude, --include, --help)
   - Error handling and help messages
   - Ruby Hash output format

2. **Executable** (`bin/klarity`)
   - Executable script for running Klarity
   - Located in `bin/` directory

### ✅ Testing

17 tests covering:
- Message detection and deduplication
- Inheritance detection
- Mixin detection (include/extend/prepend)
- Module and namespace handling
- Edge cases (empty classes, syntax errors, missing directories)
- Integration tests
- CLI tests

All tests passing ✅

### ✅ Fixtures

Test fixtures in `spec/fixtures/sample_app/`:
- `user.rb` - User class with service calls
- `order.rb` - Order class with service calls
- `services.rb` - Service classes
- `modules.rb` - Module with nested class
- `empty.rb` - Empty class
- `inheritance.rb` - Inheritance and mixin examples

## Output Format

```ruby
{
  "ClassName" => {
    inherits: ["SuperClass"],
    mixins: ["Module::Mixin", "AnotherMixin"],
    messages: ["Service1", "Service2"],
    dynamic: false
  }
}
```

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
end
```

### CLI
```bash
klarity ./app
klarity ~/projects/myapp/app --exclude "*/concerns/*"
klarity --help
```

## What's Next (Future Phases)

### Phase 4: Dynamic Detection
- Detect `send`, `constantize`, `safe_constantize`
- Detect `method_missing`, `respond_to_missing` definitions
- Detect `class_eval`, `instance_eval`, `module_eval`
- Detect `define_method`, `define_singleton_method`

### Phase 5: Polish
- Documentation (README, inline comments)
- Performance optimization (if needed)
- Additional edge case handling
- Modular detector architecture (extract detectors into separate modules)

## Dependencies

Runtime: `prism` (~> 1.0)
Development: `rspec` (~> 3.12), `rubocop` (~> 1.60)

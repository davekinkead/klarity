# Klarity - Implementation Progress

## What's Been Implemented (Phase 1 - Foundation)

### ✅ Core Components

1. **DependencyGraph** (`lib/klarity/dependency_graph.rb`)
   - Stores dependency information for classes/modules
   - Supports merging multiple graphs
   - Deduplicates messages automatically
   - Provides default empty arrays for inherits/includes

2. **FileScanner** (`lib/klarity/file_scanner.rb`)
   - Recursively scans directories for `.rb` files
   - Supports inclusion/exclusion patterns
   - Excludes common directories (vendor, node_modules, .git, etc.)

3. **Visitor** (`lib/klarity/visitor.rb`)
   - Extends `Prism::Visitor` for AST traversal
   - **Current feature**: Messages detector
   - Tracks classes and modules with namespacing
   - Handles nested class/module definitions
   - Tracks method invocations (implicit receiver = self, explicit = receiver)
   - Deduplicates messages (one per unique object type)

4. **Analyzer** (`lib/klarity/analyzer.rb`)
   - Orchestrates the analysis pipeline
   - Scans files, parses with Prism, traverses AST
   - Merges results from multiple files
   - Handles parse errors gracefully

5. **Main API** (`lib/klarity.rb`)
   - Simple entry point: `Klarity.analyze(directory, **options)`
   - Returns dependency graph as Ruby Hash

### ✅ Testing

11 tests covering:
- Basic message detection
- Deduplication
- Implicit receiver handling
- Module and namespace handling
- Edge cases (empty classes, syntax errors, missing directories)
- Integration tests

All tests passing ✅

### ✅ Fixtures

Test fixtures in `spec/fixtures/sample_app/`:
- `user.rb` - User class with multiple service calls
- `order.rb` - Order class with service calls
- `services.rb` - Service classes (PaymentService, EmailService, Database)
- `modules.rb` - Module with nested class and module class methods
- `empty.rb` - Empty class for edge case testing

### ✅ Demo

`demo.rb` shows the gem in action with formatted output

## Output Format

```ruby
{
  "ClassName" => {
    inherits: [],
    includes: [],
    messages: ["Service1", "Service2"],
    dynamic: false
  }
}
```

## What's Next (Future Phases)

### Phase 2: Additional Detectors
- Inheritance detector (superclass tracking)
- Inclusion detector (include/extend/prepend)
- Dynamic detector (send, constantize, method_missing, etc.)

### Phase 3: CLI
- Command-line interface (`exe/klarity`)
- Argument parsing
- Output formatting

### Phase 4: Polish
- Documentation
- Performance optimization
- Additional edge case handling

## Usage

```ruby
require 'klarity'

result = Klarity.analyze('/path/to/project')
result.each do |class_name, dependencies|
  puts "#{class_name}: #{dependencies[:messages]}"
end
```

## Dependencies

Runtime: `prism` (~> 1.0)
Development: `rspec` (~> 3.12), `rubocop` (~> 1.60)

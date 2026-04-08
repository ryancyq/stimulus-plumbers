# Stimulus Plumbers

## Folder Structure

```
stimulus-plumbers-rails/
├── lib/
│   └── stimulus_plumbers/
│       ├── components/               # components built on top of view_component gem
│       │   ├── */                    # child component
│       │   ├── *_component.html.erb  # component html template
│       │   └── *_component.rb        # component renderer
│       ├── engine.rb                 # rails engine
│       └── version.rb                # gem version
├── gemfiles/                         # appraisal generated gemfiles
├── spec/
│   ├── components/
│   │   └── *_spec.rb
│   ├── rails_helper.rb
│   └── spec_helper.rb
├── Gemfile
├── Gemfile.lock
├── Rakefile
├── README.md
└── *.gemspec
```

### Prerequisites

- **ruby** >= 2.7.0
- **rails** >= 6.1, < 8.2
- **view_component** ~> 3.0
- **rubygems** package manager

### CMD

```bash
bundle install
bundle exec rspec
```

**Build outputs:**


## Guidelines
- **Unit tests** using Rspec
- **Lint tests** using Rubocop
- **Always Run Linting** after appraisal command
- **System tests** generally should only be used for accessibility verification

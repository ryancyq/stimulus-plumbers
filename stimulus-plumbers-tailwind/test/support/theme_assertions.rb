# frozen_string_literal: true

module ThemeAssertions
  # The class tokens the theme resolves for `component`.
  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes].split
  end

  # Fails when any class token contains `pattern`, a string (e.g. a CSS variable) or a Regexp (e.g. a utility family).
  def refute_class_containing(classes, pattern)
    assert classes.none? { |token| token[pattern] },
           "Expected no class matching #{pattern.inspect} in #{classes.inspect}"
  end
end

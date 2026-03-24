{ ... }:
{
  scripts.lint.exec = ''
    composer lint
  '';

  scripts.test-lint.exec = ''
    composer test:lint
  '';

  scripts.test.exec = ''
    composer test
  '';
}

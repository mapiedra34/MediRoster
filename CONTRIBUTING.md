# Contributing to MediRoster

Thank you for your interest in contributing to MediRoster! This document provides guidelines for contributing to the project.

## Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/MediRoster.git
   cd MediRoster
   ```

2. **Set up your development environment**
   - Install Flutter SDK (3.0 or higher)
   - Install your preferred IDE (VS Code, Android Studio, or IntelliJ)
   - Run `flutter doctor` to verify your setup

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Set up Firebase** (for testing)
   - Follow the instructions in `FIREBASE_SETUP.md`
   - Add your Firebase configuration files

## Development Workflow

### Creating a Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Adding tests

### Code Style

This project follows the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

**Format your code before committing:**
```bash
flutter format .
```

**Run the linter:**
```bash
flutter analyze
```

**Fix common issues:**
```bash
dart fix --apply
```

### Coding Standards

1. **Use meaningful variable and function names**
   ```dart
   // Good
   final userName = 'John Doe';
   Future<void> fetchUserData() async { }
   
   // Bad
   final un = 'John Doe';
   Future<void> fud() async { }
   ```

2. **Add comments for complex logic**
   ```dart
   /// Calculates the overlap between two time periods
   bool hasOverlap(String start1, String end1, String start2, String end2) {
     // Implementation
   }
   ```

3. **Use const constructors where possible**
   ```dart
   const Text('Hello');  // Good
   Text('Hello');        // Avoid if const is possible
   ```

4. **Handle errors gracefully**
   ```dart
   try {
     await someAsyncOperation();
   } catch (e) {
     // Log error and show user-friendly message
     print('Error: $e');
     showErrorDialog('Operation failed');
   }
   ```

### Writing Tests

Add tests for new features:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/case_model_test.dart
```

Example test:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mediroster/models/case_model.dart';

void main() {
  group('CaseModel', () {
    test('should create case from JSON', () {
      final json = {
        'description': 'Test case',
        'operation': 'Surgery',
        'start_time': '08:00',
        'end_time': '10:00',
      };
      
      final caseModel = CaseModel.fromJson(json);
      
      expect(caseModel.description, 'Test case');
      expect(caseModel.operation, 'Surgery');
    });
  });
}
```

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(auth): add password reset functionality

Added password reset via email using Firebase Authentication.
Includes UI screen and email template.

Closes #123
```

```
fix(cases): correct date formatting in case list

The date was showing in wrong format on iOS devices.
Changed to use ISO 8601 format consistently.
```

### Pull Request Process

1. **Update your branch with the latest main**
   ```bash
   git checkout main
   git pull origin main
   git checkout your-branch
   git rebase main
   ```

2. **Push your changes**
   ```bash
   git push origin your-branch
   ```

3. **Create a Pull Request**
   - Go to GitHub and create a PR from your branch to `main`
   - Fill in the PR template
   - Link any related issues

4. **PR Requirements**
   - Code must pass all tests: `flutter test`
   - Code must pass linter: `flutter analyze`
   - Code must be formatted: `flutter format .`
   - Add appropriate tests for new features
   - Update documentation if needed

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Added unit tests
- [ ] Added widget tests

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing unit tests pass locally
```

## Reporting Bugs

When reporting bugs, include:

1. **Description**: Clear description of the bug
2. **Steps to Reproduce**: Step-by-step instructions
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Screenshots**: If applicable
6. **Environment**: 
   - Flutter version
   - Device/Emulator
   - OS version

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - Device: [e.g. iPhone 12, Pixel 5]
 - OS: [e.g. iOS 15.0, Android 12]
 - Flutter version: [e.g. 3.10.0]
 - App version: [e.g. 1.0.0]

**Additional context**
Any other context about the problem.
```

## Feature Requests

We welcome feature requests! When suggesting a feature:

1. **Check existing issues** to avoid duplicates
2. **Describe the feature** clearly
3. **Explain the use case** - why is it needed?
4. **Provide examples** if possible

## Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone.

### Our Standards

Examples of behavior that contributes to a positive environment:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

Examples of unacceptable behavior:
- Trolling, insulting/derogatory comments
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

## Getting Help

- **Documentation**: Check README.md, FIREBASE_SETUP.md, and MIGRATION.md
- **Issues**: Search existing issues or create a new one
- **Discussions**: Use GitHub Discussions for questions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in the project README.md.

---

Thank you for contributing to MediRoster! 🎉

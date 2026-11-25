import 'package:drift/drift.dart';

import 'app_database.dart';

class PincodeMatchResult {
  const PincodeMatchResult({
    required this.matches,
    this.matchedIncludeRule,
    this.blockedByExcludeRule,
    this.reason,
  });

  final bool matches;
  final PostalOfficeRule? matchedIncludeRule;
  final PostalOfficeRule? blockedByExcludeRule;
  final String? reason;
}

class PincodeMatcher {
  const PincodeMatcher();

  static final _sixDigitRegex = RegExp(r'^\d{6}$');

  /// Validates whether a pincode string is a valid 6-digit number string.
  static bool isValidPincode(String? pincode) {
    if (pincode == null) return false;
    return _sixDigitRegex.hasMatch(pincode.trim());
  }

  /// Tests whether a single pincode matches a list of rules for an office.
  ///
  /// Logical condition: `matchesAnyInclude && !matchesAnyExclude`.
  /// If an office has no Include rules, it matches no pincodes.
  PincodeMatchResult testPincode(String? rawPincode, List<PostalOfficeRule> rules) {
    if (rawPincode == null) {
      return const PincodeMatchResult(
        matches: false,
        reason: 'Pincode is missing.',
      );
    }

    final pincode = rawPincode.trim();
    if (!isValidPincode(pincode)) {
      return const PincodeMatchResult(
        matches: false,
        reason: 'Invalid pincode format (must be 6 digits).',
      );
    }

    final includeRules = rules.where((r) => r.operation == 'include').toList();
    final excludeRules = rules.where((r) => r.operation == 'exclude').toList();

    if (includeRules.isEmpty) {
      return const PincodeMatchResult(
        matches: false,
        reason: 'No Include rules configured.',
      );
    }

    PostalOfficeRule? matchedInclude;
    for (final rule in includeRules) {
      if (matchesRule(pincode, rule)) {
        matchedInclude = rule;
        break;
      }
    }

    if (matchedInclude == null) {
      return const PincodeMatchResult(
        matches: false,
        reason: 'Does not match any Include rule.',
      );
    }

    PostalOfficeRule? blockedByExclude;
    for (final rule in excludeRules) {
      if (matchesRule(pincode, rule)) {
        blockedByExclude = rule;
        break;
      }
    }

    if (blockedByExclude != null) {
      return PincodeMatchResult(
        matches: false,
        matchedIncludeRule: matchedInclude,
        blockedByExcludeRule: blockedByExclude,
        reason: 'Excluded by rule (${blockedByExclude.matchMethod}: ${blockedByExclude.startValue}${blockedByExclude.endValue != null ? ' - ${blockedByExclude.endValue}' : ''}).',
      );
    }

    return PincodeMatchResult(
      matches: true,
      matchedIncludeRule: matchedInclude,
      reason: 'Matched by Include rule (${matchedInclude.matchMethod}: ${matchedInclude.startValue}${matchedInclude.endValue != null ? ' - ${matchedInclude.endValue}' : ''}).',
    );
  }

  /// Evaluates whether a 6-digit pincode matches a single rule pattern.
  bool matchesRule(String pincode, PostalOfficeRule rule) {
    final start = rule.startValue.trim();
    switch (rule.matchMethod) {
      case 'prefix':
        return pincode.startsWith(start);
      case 'range':
        final end = (rule.endValue ?? start).trim();
        return pincode.compareTo(start) >= 0 && pincode.compareTo(end) <= 0;
      case 'exact':
        return pincode == start;
      default:
        return false;
    }
  }

  /// Builds a Drift SQL Expression to filter subscribers whose `postalCode`
  /// matches the given postal office rules at the database level.
  Expression<bool> subscriberMatchesOffice(
    Expression<String> postalCodeColumn,
    List<PostalOfficeRule> rules,
  ) {
    final includeRules = rules.where((r) => r.operation == 'include').toList();
    final excludeRules = rules.where((r) => r.operation == 'exclude').toList();

    if (includeRules.isEmpty) {
      return const Constant(false);
    }

    final includeExprs = includeRules.map((rule) => _buildRuleExpression(postalCodeColumn, rule));
    final combinedInclude = includeExprs.reduce((a, b) => a | b);

    if (excludeRules.isEmpty) {
      return postalCodeColumn.isNotNull() & combinedInclude;
    }

    final excludeExprs = excludeRules.map((rule) => _buildRuleExpression(postalCodeColumn, rule));
    final combinedExclude = excludeExprs.reduce((a, b) => a | b);

    return postalCodeColumn.isNotNull() & combinedInclude & combinedExclude.not();
  }

  Expression<bool> _buildRuleExpression(
    Expression<String> postalCodeColumn,
    PostalOfficeRule rule,
  ) {
    final start = rule.startValue.trim();
    switch (rule.matchMethod) {
      case 'prefix':
        return postalCodeColumn.like('$start%');
      case 'range':
        final end = (rule.endValue ?? start).trim();
        return postalCodeColumn.isBiggerOrEqualValue(start) &
            postalCodeColumn.isSmallerOrEqualValue(end);
      case 'exact':
        return postalCodeColumn.equals(start);
      default:
        return const Constant(false);
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Certificate Pinning Service for Enhanced Security
///
/// Usage:
/// ```dart
/// final pinning = CertificatePinning();
/// await pinning.initialize();
/// final isValid = await pinning.validateCertificate(host, certificate);
/// ```
class CertificatePinning {
  static final CertificatePinning _instance = CertificatePinning._internal();
  factory CertificatePinning() => _instance;
  CertificatePinning._internal();

  final Map<String, List<String>> _pinnedCertificates = {};
  final Map<String, List<String>> _pinnedPublicKeys = {};
  // final Map<String, List<String>> _pinnedHashes = {}; // Not used

  /// Initialize certificate pinning
  Future<Result<void>> initialize() async {
    try {
      await _loadPinnedCertificates();
      TalkerConfig.logInfo('Certificate pinning initialized');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to initialize certificate pinning', e);
      return Error(Failure('Failed to initialize certificate pinning: $e'));
    }
  }

  /// Add pinned certificate for a host
  Future<Result<void>> addPinnedCertificate(
    String host,
    String certificateHash, {
    CertificateType type = CertificateType.sha256,
  }) async {
    try {
      _pinnedCertificates[host] ??= [];
      _pinnedCertificates[host]!.add(certificateHash);

      TalkerConfig.logInfo('Certificate pinned for host: $host');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to add pinned certificate', e);
      return Error(Failure('Failed to add pinned certificate: $e'));
    }
  }

  /// Add pinned public key for a host
  Future<Result<void>> addPinnedPublicKey(
    String host,
    String publicKeyHash, {
    CertificateType type = CertificateType.sha256,
  }) async {
    try {
      _pinnedPublicKeys[host] ??= [];
      _pinnedPublicKeys[host]!.add(publicKeyHash);

      TalkerConfig.logInfo('Public key pinned for host: $host');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to add pinned public key', e);
      return Error(Failure('Failed to add pinned public key: $e'));
    }
  }

  /// Validate certificate for a host
  Future<Result<bool>> validateCertificate(
    String host,
    X509Certificate certificate,
  ) async {
    try {
      // Check certificate pinning
      if (_pinnedCertificates.containsKey(host)) {
        final certificateHash = _getCertificateHash(certificate);
        final pinnedHashes = _pinnedCertificates[host]!;

        if (!pinnedHashes.contains(certificateHash)) {
          TalkerConfig.logWarning('Certificate pinning failed for host: $host');
          return const Success(false);
        }
      }

      // Check public key pinning
      if (_pinnedPublicKeys.containsKey(host)) {
        final publicKeyHash = _getPublicKeyHash(certificate);
        final pinnedKeys = _pinnedPublicKeys[host]!;

        if (!pinnedKeys.contains(publicKeyHash)) {
          TalkerConfig.logWarning('Public key pinning failed for host: $host');
          return const Success(false);
        }
      }

      // Check certificate validity
      if (!_isCertificateValid(certificate)) {
        TalkerConfig.logWarning('Certificate is not valid for host: $host');
        return const Success(false);
      }

      TalkerConfig.logInfo('Certificate validation successful for host: $host');
      return const Success(true);
    } catch (e) {
      TalkerConfig.logError('Failed to validate certificate', e);
      return Error(Failure('Failed to validate certificate: $e'));
    }
  }

  /// Validate certificate chain
  Future<Result<bool>> validateCertificateChain(
    String host,
    List<X509Certificate> certificateChain,
  ) async {
    try {
      for (final certificate in certificateChain) {
        final result = await validateCertificate(host, certificate);
        if (result.isFailure || !result.data) {
          return const Success(false);
        }
      }

      TalkerConfig.logInfo(
        'Certificate chain validation successful for host: $host',
      );
      return const Success(true);
    } catch (e) {
      TalkerConfig.logError('Failed to validate certificate chain', e);
      return Error(Failure('Failed to validate certificate chain: $e'));
    }
  }

  /// Get certificate information
  Future<Result<CertificateInfo>> getCertificateInfo(
    X509Certificate certificate,
  ) async {
    try {
      final info = CertificateInfo(
        subject: certificate.subject,
        issuer: certificate.issuer,
        serialNumber: '', // X509Certificate doesn't have serialNumber property
        startValidity: certificate.startValidity,
        endValidity: certificate.endValidity,
        sha1Hash: _getCertificateHash(certificate, CertificateType.sha1),
        sha256Hash: _getCertificateHash(certificate, CertificateType.sha256),
        publicKeyHash: _getPublicKeyHash(certificate),
        isValid: _isCertificateValid(certificate),
        isExpired: _isCertificateExpired(certificate),
        isSelfSigned: _isSelfSigned(certificate),
      );

      return Success(info);
    } catch (e) {
      TalkerConfig.logError('Failed to get certificate info', e);
      return Error(Failure('Failed to get certificate info: $e'));
    }
  }

  /// Update pinned certificates
  Future<Result<void>> updatePinnedCertificates(
    String host,
    List<String> newHashes,
  ) async {
    try {
      _pinnedCertificates[host] = newHashes;
      TalkerConfig.logInfo('Pinned certificates updated for host: $host');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to update pinned certificates', e);
      return Error(Failure('Failed to update pinned certificates: $e'));
    }
  }

  /// Remove pinned certificates for a host
  Future<Result<void>> removePinnedCertificates(String host) async {
    try {
      _pinnedCertificates.remove(host);
      _pinnedPublicKeys.remove(host);
      TalkerConfig.logInfo('Pinned certificates removed for host: $host');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to remove pinned certificates', e);
      return Error(Failure('Failed to remove pinned certificates: $e'));
    }
  }

  /// Get all pinned certificates
  Map<String, List<String>> getAllPinnedCertificates() {
    return Map.from(_pinnedCertificates);
  }

  /// Get all pinned public keys
  Map<String, List<String>> getAllPinnedPublicKeys() {
    return Map.from(_pinnedPublicKeys);
  }

  /// Check if host has pinned certificates
  bool hasPinnedCertificates(String host) {
    return _pinnedCertificates.containsKey(host) ||
        _pinnedPublicKeys.containsKey(host);
  }

  /// Export certificate pinning configuration
  Future<Result<String>> exportConfiguration() async {
    try {
      final config = {
        'certificates': _pinnedCertificates,
        'publicKeys': _pinnedPublicKeys,
        'exportedAt': DateTime.now().toIso8601String(),
      };

      final json = jsonEncode(config);
      return Success(json);
    } catch (e) {
      TalkerConfig.logError('Failed to export configuration', e);
      return Error(Failure('Failed to export configuration: $e'));
    }
  }

  /// Import certificate pinning configuration
  Future<Result<void>> importConfiguration(String jsonConfig) async {
    try {
      final config = jsonDecode(jsonConfig) as Map<String, dynamic>;

      _pinnedCertificates.clear();
      _pinnedPublicKeys.clear();

      if (config['certificates'] != null) {
        final certificates = config['certificates'] as Map<String, dynamic>;
        for (final entry in certificates.entries) {
          _pinnedCertificates[entry.key] = List<String>.from(entry.value);
        }
      }

      if (config['publicKeys'] != null) {
        final publicKeys = config['publicKeys'] as Map<String, dynamic>;
        for (final entry in publicKeys.entries) {
          _pinnedPublicKeys[entry.key] = List<String>.from(entry.value);
        }
      }

      TalkerConfig.logInfo('Certificate pinning configuration imported');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to import configuration', e);
      return Error(Failure('Failed to import configuration: $e'));
    }
  }

  // Private methods
  Future<void> _loadPinnedCertificates() async {
    // Load default pinned certificates
    _pinnedCertificates['api.example.com'] = [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    ];

    _pinnedCertificates['secure.example.com'] = [
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    ];
  }

  String _getCertificateHash(
    X509Certificate certificate, [
    CertificateType type = CertificateType.sha256,
  ]) {
    final bytes = certificate.der;

    switch (type) {
      case CertificateType.sha1:
        final digest = sha1.convert(bytes);
        return 'sha1/${base64Encode(digest.bytes)}';
      case CertificateType.sha256:
        final digest = sha256.convert(bytes);
        return 'sha256/${base64Encode(digest.bytes)}';
    }
  }

  String _getPublicKeyHash(X509Certificate certificate) {
    // Extract public key from certificate and hash it
    final publicKeyBytes = _extractPublicKey(certificate);
    final digest = sha256.convert(publicKeyBytes);
    return 'sha256/${base64Encode(digest.bytes)}';
  }

  Uint8List _extractPublicKey(X509Certificate certificate) {
    // This is a simplified implementation
    // In a real implementation, you would extract the public key from the certificate
    return certificate.der;
  }

  bool _isCertificateValid(X509Certificate certificate) {
    final now = DateTime.now();
    return now.isAfter(certificate.startValidity) &&
        now.isBefore(certificate.endValidity);
  }

  bool _isCertificateExpired(X509Certificate certificate) {
    return DateTime.now().isAfter(certificate.endValidity);
  }

  bool _isSelfSigned(X509Certificate certificate) {
    return certificate.subject == certificate.issuer;
  }
}

/// Certificate Type enum
enum CertificateType { sha1, sha256 }

/// Certificate Info class
class CertificateInfo {
  final String subject;
  final String issuer;
  final String serialNumber;
  final DateTime startValidity;
  final DateTime endValidity;
  final String sha1Hash;
  final String sha256Hash;
  final String publicKeyHash;
  final bool isValid;
  final bool isExpired;
  final bool isSelfSigned;

  const CertificateInfo({
    required this.subject,
    required this.issuer,
    required this.serialNumber,
    required this.startValidity,
    required this.endValidity,
    required this.sha1Hash,
    required this.sha256Hash,
    required this.publicKeyHash,
    required this.isValid,
    required this.isExpired,
    required this.isSelfSigned,
  });
}

/// Certificate Pinning Configuration
class CertificatePinningConfig {
  final Map<String, List<String>> certificates;
  final Map<String, List<String>> publicKeys;
  final bool enforcePinning;
  final bool allowSelfSigned;
  final Duration timeout;

  const CertificatePinningConfig({
    required this.certificates,
    required this.publicKeys,
    this.enforcePinning = true,
    this.allowSelfSigned = false,
    this.timeout = const Duration(seconds: 30),
  });
}

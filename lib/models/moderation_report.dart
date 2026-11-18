import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Opciones de motivo de denuncia contextualizadas para la comunidad de Yago.
class ModerationReasonOption {
  final String code; // Código persistido en Firestore ('fake', 'scam', 'spam', 'offensive', 'duplicate', 'other')
  final String title;
  final String description;
  final IconData icon;

  const ModerationReasonOption({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });

  /// Lista oficial de motivos de denuncia adaptados a las dinámicas de mascotas de Yago
  static const List<ModerationReasonOption> defaultOptions = [
    ModerationReasonOption(
      code: 'fake',
      title: 'Información falsa o broma',
      description: 'La mascota no existe, la foto es de internet o es un reporte ficticio.',
      icon: Icons.warning_amber_rounded,
    ),
    ModerationReasonOption(
      code: 'scam',
      title: 'Estafa o extorsión con recompensa',
      description: 'Exigen transferencias, pagos por adelantado o chantaje para devolver al animal.',
      icon: Icons.monetization_on_outlined,
    ),
    ModerationReasonOption(
      code: 'spam',
      title: 'Venta de animales o publicidad (Spam)',
      description: 'Comercialización lucrativa de cachorros, cruzas pagadas o avisos comerciales.',
      icon: Icons.storefront_outlined,
    ),
    ModerationReasonOption(
      code: 'offensive',
      title: 'Maltrato animal o contenido violento',
      description: 'Muestra crueldad, sufrimiento, heridas explícitas o situaciones de peligro.',
      icon: Icons.healing_outlined,
    ),
    ModerationReasonOption(
      code: 'offensive',
      title: 'Acoso o agresiones en la comunidad',
      description: 'Lenguaje descalificador, insultos, intimidación o faltas de respeto.',
      icon: Icons.shield_outlined,
    ),
    ModerationReasonOption(
      code: 'duplicate',
      title: 'Caso ya resuelto o reporte repetido',
      description: 'El animal ya fue recuperado/adoptado o la publicación está duplicada.',
      icon: Icons.content_copy_rounded,
    ),
    ModerationReasonOption(
      code: 'other',
      title: 'Otro motivo',
      description: 'Cualquier otra irregularidad que requiera la intervención del equipo de moderación.',
      icon: Icons.more_horiz_rounded,
    ),
  ];
}

/// Modelo de datos para las denuncias comunitarias de la plataforma Yago (HU-S5-01 / Sprint 5)
class ModerationReport {
  final String id;
  final String reporterId;
  final String? reporterName;
  final String? reporterEmail;
  final String targetType; // 'pet' | 'feed_post' | 'chat_message' | 'user'
  final String targetId;
  final String? targetTitle;
  final String? targetAuthorId;
  final String? targetAuthorName;
  final String reason; // 'fake' | 'scam' | 'spam' | 'offensive' | 'duplicate' | 'other'
  final String reasonTitle;
  final String? description;
  final String status; // 'pending' | 'reviewed' | 'dismissed' | 'action_taken'
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ModerationReport({
    required this.id,
    required this.reporterId,
    this.reporterName,
    this.reporterEmail,
    required this.targetType,
    required this.targetId,
    this.targetTitle,
    this.targetAuthorId,
    this.targetAuthorName,
    required this.reason,
    required this.reasonTitle,
    this.description,
    this.status = 'pending',
    this.reviewedBy,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      if (reporterName != null && reporterName!.isNotEmpty) 'reporterName': reporterName,
      if (reporterEmail != null && reporterEmail!.isNotEmpty) 'reporterEmail': reporterEmail,
      'targetType': targetType,
      'targetId': targetId,
      if (targetTitle != null && targetTitle!.isNotEmpty) 'targetTitle': targetTitle,
      if (targetAuthorId != null && targetAuthorId!.isNotEmpty) 'targetAuthorId': targetAuthorId,
      if (targetAuthorName != null && targetAuthorName!.isNotEmpty) 'targetAuthorName': targetAuthorName,
      'reason': reason,
      'reasonTitle': reasonTitle,
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'status': status,
      if (reviewedBy != null && reviewedBy!.isNotEmpty) 'reviewedBy': reviewedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (resolvedAt != null) 'resolvedAt': Timestamp.fromDate(resolvedAt!),
    };
  }

  factory ModerationReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ModerationReport.fromMap(data, id: doc.id);
  }

  factory ModerationReport.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ModerationReport(
      id: id ?? (data['id'] as String? ?? ''),
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String?,
      reporterEmail: data['reporterEmail'] as String?,
      targetType: data['targetType'] as String? ?? 'pet',
      targetId: data['targetId'] as String? ?? '',
      targetTitle: data['targetTitle'] as String?,
      targetAuthorId: data['targetAuthorId'] as String?,
      targetAuthorName: data['targetAuthorName'] as String?,
      reason: data['reason'] as String? ?? 'other',
      reasonTitle: data['reasonTitle'] as String? ?? 'Otro motivo',
      description: data['description'] as String?,
      status: data['status'] as String? ?? 'pending',
      reviewedBy: data['reviewedBy'] as String?,
      createdAt: data['createdAt'] != null ? parseDate(data['createdAt']) : DateTime.now(),
      resolvedAt: data['resolvedAt'] != null ? parseDate(data['resolvedAt']) : null,
    );
  }
}

import 'package:flutter/material.dart';
import '../screens/verify_screen.dart';

class VerificationResult extends StatelessWidget {
  final VerificationStatus status;
  final Map<String, dynamic>? data;

  const VerificationResult({
    super.key,
    required this.status,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(height: 16),
            Text(
              _getStatusTitle(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusMessage(),
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (status == VerificationStatus.valid && data != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDataRow('Nama', data!['name'] ?? '-'),
              _buildDataRow('Program', data!['program'] ?? '-'),
              _buildDataRow('No. Sijil', data!['certificate_number'] ?? '-'),
              if (data!['date'] != null)
                _buildDataRow('Tarikh', data!['date']),
              if (data!['ic'] != null)
                _buildDataRow('No. KP', data!['ic']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    Color bgColor;

    switch (status) {
      case VerificationStatus.valid:
        icon = Icons.check_circle;
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case VerificationStatus.invalid:
        icon = Icons.cancel;
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      case VerificationStatus.notFound:
        icon = Icons.search_off;
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case VerificationStatus.error:
        icon = Icons.error;
        color = Colors.grey;
        bgColor = Colors.grey.shade100;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 48, color: color),
    );
  }

  String _getStatusTitle() {
    switch (status) {
      case VerificationStatus.valid:
        return 'Sijil Sah';
      case VerificationStatus.invalid:
        return 'Sijil Tidak Sah';
      case VerificationStatus.notFound:
        return 'Sijil Tidak Dijumpai';
      case VerificationStatus.error:
        return 'Ralat';
    }
  }

  String _getStatusMessage() {
    switch (status) {
      case VerificationStatus.valid:
        return 'Sijil ini adalah sah dan tulen.';
      case VerificationStatus.invalid:
        return 'Tandatangan digital tidak sepadan. Sijil mungkin telah diubah suai.';
      case VerificationStatus.notFound:
        return 'Tiada rekod sijil dengan kod ini dalam sistem.';
      case VerificationStatus.error:
        return 'Ralat semasa mengesahkan sijil. Sila cuba lagi.';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case VerificationStatus.valid:
        return Colors.green;
      case VerificationStatus.invalid:
        return Colors.red;
      case VerificationStatus.notFound:
        return Colors.orange;
      case VerificationStatus.error:
        return Colors.grey;
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

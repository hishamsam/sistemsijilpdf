import 'package:flutter/material.dart';
import '../../../data/models/participant.dart';

class ParticipantListTile extends StatelessWidget {
  final Participant participant;
  final VoidCallback onGenerateCertificate;
  final VoidCallback onDelete;

  const ParticipantListTile({
    super.key,
    required this.participant,
    required this.onGenerateCertificate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: participant.hasCertificate
              ? Colors.green[100]
              : Colors.grey[200],
          child: Icon(
            participant.hasCertificate ? Icons.check : Icons.person,
            color: participant.hasCertificate ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          participant.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'KP: ${_formatIc(participant.icNumber)}${participant.email != null ? ' | ${participant.email}' : ''}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (participant.hasCertificate)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sijil Ada',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                participant.hasCertificate ? Icons.visibility : Icons.picture_as_pdf,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: onGenerateCertificate,
              tooltip: participant.hasCertificate ? 'Lihat Sijil' : 'Jana Sijil',
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: onDelete,
              tooltip: 'Padam',
            ),
          ],
        ),
      ),
    );
  }

  String _formatIc(String ic) {
    if (ic.length == 12) {
      return '${ic.substring(0, 6)}-${ic.substring(6, 8)}-${ic.substring(8)}';
    }
    return ic;
  }
}

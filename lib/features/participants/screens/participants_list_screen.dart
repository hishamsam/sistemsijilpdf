import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/localization/app_strings.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_input.dart';
import '../../../data/models/program.dart';
import '../../../data/models/participant.dart';
import '../../../data/repositories/participant_repository.dart';
import '../../programs/providers/program_provider.dart';
import '../../programs/screens/program_detail_screen.dart';

class ParticipantsListScreen extends StatefulWidget {
  const ParticipantsListScreen({super.key});

  @override
  State<ParticipantsListScreen> createState() => _ParticipantsListScreenState();
}

class _ParticipantsListScreenState extends State<ParticipantsListScreen> {
  final ParticipantRepository _participantRepo = ParticipantRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allParticipants = [];
  List<Map<String, dynamic>> _filteredParticipants = [];
  Program? _selectedProgram;
  bool _isLoading = true;
  String _sortBy = 'name'; // name, program, date
  bool _sortAsc = true;

  @override
  void initState() {
    super.initState();
    _loadAllParticipants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllParticipants() async {
    setState(() => _isLoading = true);
    
    final programs = context.read<ProgramProvider>().programs;
    final List<Map<String, dynamic>> allData = [];
    
    for (final program in programs) {
      final participants = await _participantRepo.getByProgramId(program.id!);
      for (final participant in participants) {
        allData.add({
          'participant': participant,
          'program': program,
        });
      }
    }
    
    setState(() {
      _allParticipants = allData;
      _filteredParticipants = allData;
      _isLoading = false;
    });
    
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allParticipants);
    
    // Filter by program
    if (_selectedProgram != null) {
      filtered = filtered.where((item) {
        final program = item['program'] as Program;
        return program.id == _selectedProgram!.id;
      }).toList();
    }
    
    // Filter by search
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        final participant = item['participant'] as Participant;
        final program = item['program'] as Program;
        return participant.fullName.toLowerCase().contains(query) ||
               participant.icNumber.toLowerCase().contains(query) ||
               (participant.email?.toLowerCase().contains(query) ?? false) ||
               program.programName.toLowerCase().contains(query);
      }).toList();
    }
    
    // Sort
    filtered.sort((a, b) {
      final pA = a['participant'] as Participant;
      final pB = b['participant'] as Participant;
      final progA = a['program'] as Program;
      final progB = b['program'] as Program;
      
      int result;
      switch (_sortBy) {
        case 'program':
          result = progA.programName.compareTo(progB.programName);
          break;
        case 'date':
          result = (pB.createdAt ?? DateTime.now()).compareTo(pA.createdAt ?? DateTime.now());
          break;
        case 'name':
        default:
          result = pA.fullName.compareTo(pB.fullName);
      }
      return _sortAsc ? result : -result;
    });
    
    setState(() => _filteredParticipants = filtered);
  }

  @override
  Widget build(BuildContext context) {
    final programs = context.watch<ProgramProvider>().programs;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(context, 'participants'),
                      style: AppStyles.heading2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Senarai semua peserta dari semua program',
                      style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Stats
              _buildStatChip(
                Icons.people_rounded,
                '${_filteredParticipants.length}',
                'Peserta',
                AppColors.primary,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                Icons.folder_rounded,
                '${programs.length}',
                'Program',
                AppColors.accent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filters
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search
                Expanded(
                  flex: 2,
                  child: AppInput(
                    controller: _searchController,
                    hint: 'Cari nama, IC, email atau program...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Program filter
                Expanded(
                  child: DropdownButtonFormField<Program?>(
                    value: _selectedProgram,
                    decoration: InputDecoration(
                      labelText: 'Program',
                      prefixIcon: const Icon(Icons.folder_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Program'),
                      ),
                      ...programs.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.programName, overflow: TextOverflow.ellipsis),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedProgram = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // Sort
                PopupMenuButton<String>(
                  tooltip: 'Susun',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(_getSortLabel()),
                        const SizedBox(width: 4),
                        Icon(
                          _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    _buildSortMenuItem('name', 'Nama'),
                    _buildSortMenuItem('program', 'Program'),
                    _buildSortMenuItem('date', 'Tarikh Daftar'),
                  ],
                  onSelected: (value) {
                    setState(() {
                      if (_sortBy == value) {
                        _sortAsc = !_sortAsc;
                      } else {
                        _sortBy = value;
                        _sortAsc = true;
                      }
                    });
                    _applyFilters();
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Refresh
                IconButton(
                  onPressed: _loadAllParticipants,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Muat Semula',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Table
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredParticipants.isEmpty
                      ? _buildEmptyState()
                      : _buildParticipantsTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppStyles.heading4.copyWith(color: color),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'program':
        return 'Program';
      case 'date':
        return 'Tarikh';
      default:
        return 'Nama';
    }
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sortBy == value)
            Icon(
              _sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: AppColors.primary,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Tiada peserta dijumpai',
            style: AppStyles.heading4.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedProgram != null
                ? 'Cuba ubah carian atau filter'
                : 'Tambah peserta melalui halaman program',
            style: AppStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTable() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 40), // Checkbox space
              Expanded(flex: 2, child: Text('NAMA PESERTA', style: _headerStyle())),
              Expanded(flex: 2, child: Text('NO. KAD PENGENALAN', style: _headerStyle())),
              Expanded(flex: 2, child: Text('PROGRAM', style: _headerStyle())),
              Expanded(flex: 2, child: Text('EMAIL', style: _headerStyle())),
              const SizedBox(width: 100, child: Text('TINDAKAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
            ],
          ),
        ),
        
        // Rows
        Expanded(
          child: ListView.builder(
            itemCount: _filteredParticipants.length,
            itemBuilder: (context, index) {
              final item = _filteredParticipants[index];
              final participant = item['participant'] as Participant;
              final program = item['program'] as Program;
              
              return _buildParticipantRow(participant, program, index);
            },
          ),
        ),
      ],
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    );
  }

  Widget _buildParticipantRow(Participant participant, Program program, int index) {
    return InkWell(
      onTap: () => _goToProgram(program),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: index.isEven ? Colors.transparent : AppColors.background.withOpacity(0.5),
          border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  participant.fullName.isNotEmpty ? participant.fullName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Name
            Expanded(
              flex: 2,
              child: Text(
                participant.fullName,
                style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // IC
            Expanded(
              flex: 2,
              child: Text(
                participant.icNumber,
                style: AppStyles.bodySmall,
              ),
            ),
            
            // Program
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _goToProgram(program),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    program.programName,
                    style: AppStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            
            // Email
            Expanded(
              flex: 2,
              child: Text(
                participant.email ?? '-',
                style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Actions
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    tooltip: 'Lihat Program',
                    onPressed: () => _goToProgram(program),
                    color: AppColors.textSecondary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    tooltip: 'Buka Program',
                    onPressed: () => _goToProgram(program),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToProgram(Program program) {
    context.read<ProgramProvider>().selectProgram(program.id!);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramDetailScreen(programId: program.id!),
      ),
    );
  }
}

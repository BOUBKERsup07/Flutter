import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../models/competition.dart';
import '../../models/team.dart';
import '../../widgets/team_item.dart';
import 'team_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CompetitionDetailsScreen extends StatefulWidget {
  final int competitionId;

  const CompetitionDetailsScreen({
    Key? key,
    required this.competitionId,
  }) : super(key: key);

  @override
  State<CompetitionDetailsScreen> createState() => _CompetitionDetailsScreenState();
}

class _CompetitionDetailsScreenState extends State<CompetitionDetailsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Competition? _competition;
  List<Team> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadCompetitionDetails();
  }

  Future<void> _loadCompetitionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      
      // Load competition details
      _competition = await searchProvider.getCompetitionDetails(widget.competitionId);
      
      // Load teams in this competition
      _teams = await searchProvider.getTeamsByCompetition(widget.competitionId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load competition details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_competition?.name ?? 'Competition Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildCompetitionDetails(),
    );
  }

  Widget _buildCompetitionDetails() {
    if (_competition == null) {
      return const Center(child: Text('No competition data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Competition header
          _buildCompetitionHeader(),
          
          const Divider(),
          
          // Competition info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Code', _competition!.code),
                _buildInfoRow('Type', _competition!.type),
                if (_competition!.area != null)
                  _buildInfoRow('Area', _competition!.area!),
                if (_competition!.currentSeason != null)
                  _buildInfoRow('Current Season', _competition!.currentSeason!),
                if (_competition!.numberOfAvailableSeasons != null)
                  _buildInfoRow('Available Seasons', _competition!.numberOfAvailableSeasons.toString()),
              ],
            ),
          ),
          
          const Divider(),
          
          // Teams in this competition
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Teams',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _teams.isEmpty
                    ? const Text('No teams available')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          return TeamItem(
                            team: _teams[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamDetailsScreen(
                                    teamId: _teams[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Competition emblem
          if (_competition!.emblem.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _competition!.emblem,
                height: 120,
                width: 120,
                fit: BoxFit.contain,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.sports_soccer, size: 80),
              ),
            ),
          const SizedBox(height: 16),
          
          // Competition name
          Text(
            _competition!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

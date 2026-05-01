import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:echosee/data/models/transcript_model.dart';
import 'package:echosee/data/repositories/transcript_repository.dart';

class SupabaseTranscriptRepository implements TranscriptRepository {
  SupabaseClient get _client => Supabase.instance.client;
  static const int _maxFreeTranscripts = 5;

  Future<bool> _isUserPremium() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final response = await _client
        .from('users')
        .select('is_premium')
        .eq('id', user.id)
        .single();
    
    return response['is_premium'] ?? false;
  }

  @override
  Future<List<Transcript>> getTranscripts({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
    String? filter,
    String? sortBy,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    bool isPremium = await _isUserPremium();
    
    // If free user, strictly enforce a limit of 5 for history visibility
    int effectiveLimit = isPremium ? limit : _maxFreeTranscripts;
    
    var query = _client
        .from('transcripts')
        .select()
        .eq('user_id', user.id);

    // Filter logic
    if (filter == 'starred') {
      query = query.eq('is_starred', true);
    } else if (filter == 'today') {
      final startOfDay = DateTime.now().toUtc().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
      query = query.gte('date', startOfDay.toIso8601String());
    }

    // Search logic
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('title.ilike.%$searchQuery%,content.ilike.%$searchQuery%');
    }

    // Sorting logic
    String orderCol = 'date';
    bool ascending = false;
    if (sortBy == 'name') orderCol = 'title';
    if (sortBy == 'duration') orderCol = 'duration';
    
    final response = await query
        .order(orderCol, ascending: ascending)
        .limit(effectiveLimit)
        .range(offset, offset + effectiveLimit - 1);

    return (response as List).map((t) => Transcript.fromSupabase(t)).toList();
  }

  @override
  Future<Transcript> getTranscript(String id) async {
    final response = await _client
        .from('transcripts')
        .select()
        .eq('id', id)
        .single();
    return Transcript.fromSupabase(response);
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    bool isPremium = await _isUserPremium();

    if (!isPremium) {
      // Check count and delete oldest if limit reached
      final countResponse = await _client
          .from('transcripts')
          .select('id')
          .eq('user_id', user.id);
      
      final count = (countResponse as List).length;

      if (count >= _maxFreeTranscripts) {
        // Find the oldest transcript
        final oldest = await _client
            .from('transcripts')
            .select('id')
            .eq('user_id', user.id)
            .order('date', ascending: true)
            .limit(1)
            .single();
        
        await deleteTranscript(oldest['id']);
      }
    }

    final data = transcript.toSupabase();
    data['user_id'] = user.id;
    if (transcript.id.isNotEmpty && transcript.id != 'new') {
      data['id'] = transcript.id;
    }

    final response = await _client
        .from('transcripts')
        .upsert(data)
        .select()
        .single();

    return Transcript.fromSupabase(response);
  }

  @override
  Future<void> updateTranscript(Transcript transcript) async {
    await _client
        .from('transcripts')
        .update(transcript.toSupabase())
        .eq('id', transcript.id);
  }

  @override
  Future<void> deleteTranscript(String id) async {
    await _client.from('transcripts').delete().eq('id', id);
  }

  @override
  Future<void> deleteAllTranscripts() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('transcripts').delete().eq('user_id', user.id);
  }

  @override
  Future<List<Transcript>> searchTranscripts(String query) async {
    return getTranscripts(searchQuery: query);
  }

  @override
  Future<int> getTranscriptCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;

    final response = await _client
        .from('transcripts')
        .select('id')
        .eq('user_id', user.id);
    
    return (response as List).length;
  }

  @override
  Future<double> getStorageUsed() async {
    // Basic estimation based on character count of content
    final user = _client.auth.currentUser;
    if (user == null) return 0.0;

    final response = await _client
        .from('transcripts')
        .select('content')
        .eq('user_id', user.id);

    double totalChars = 0;
    for (var row in response) {
      totalChars += (row['content'] as String).length;
    }

    // Estimate: 1 char = 1 byte. Convert to MB.
    return totalChars / (1024 * 1024);
  }

  @override
  Future<void> exportTranscripts(String format) async {
    // Implementation for exporting (e.g. generating CSV/PDF) would go here
    // For now, it's a placeholder as per interface
    print('Exporting transcripts as $format');
  }

  @override
  Future<void> starTranscript(String id, bool starred) async {
    await _client
        .from('transcripts')
        .update({'is_starred': starred})
        .eq('id', id);
  }

  @override
  Future<List<Transcript>> getStarredTranscripts() async {
    return getTranscripts(filter: 'starred');
  }
}

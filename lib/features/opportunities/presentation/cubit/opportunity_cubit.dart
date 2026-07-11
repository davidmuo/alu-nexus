import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/repositories/opportunity_repository.dart';

part 'opportunity_state.dart';

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository _repo;
  StreamSubscription<List<OpportunityModel>>? _sub;
  String _searchQuery = '';
  String _typeFilter = '';
  String _commitmentFilter = '';
  bool? _paidFilter;

  OpportunityCubit(this._repo) : super(const OpportunityInitial());

  void loadOpportunities() {
    _sub?.cancel();
    emit(const OpportunityLoading());
    _sub = _repo
        .getActiveOpportunities(
          type: _typeFilter.isEmpty ? null : _typeFilter,
          commitment: _commitmentFilter.isEmpty ? null : _commitmentFilter,
          searchQuery: _searchQuery,
          isPaid: _paidFilter,
        )
        .listen(
          (list) => emit(OpportunityLoaded(list)),
          onError: (e) => emit(OpportunityError(e.toString())),
        );
  }

  void search(String query) {
    _searchQuery = query;
    loadOpportunities();
  }

  void filterByType(String type) {
    _typeFilter = type;
    loadOpportunities();
  }

  void filterByCommitment(String commitment) {
    _commitmentFilter = commitment;
    loadOpportunities();
  }

  void filterByPaid(bool? isPaid) {
    _paidFilter = isPaid;
    loadOpportunities();
  }

  void clearFilters() {
    _searchQuery = '';
    _typeFilter = '';
    _commitmentFilter = '';
    _paidFilter = null;
    loadOpportunities();
  }

  Future<void> createOpportunity(OpportunityModel opp) async {
    try {
      await _repo.createOpportunity(opp);
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }

  Future<void> closeOpportunity(String id) async {
    try {
      await _repo.closeOpportunity(id);
    } catch (e) {
      emit(OpportunityError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

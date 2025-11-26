import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

enum SearchStep { where, when, who }

@immutable
class SearchState {
  final SearchStep currentStep;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final int adults;
  final int children;
  final int infants;
  final int pets;

  const SearchState({
    this.currentStep = SearchStep.where,
    this.location,
    this.startDate,
    this.endDate,
    this.adults = 0,
    this.children = 0,
    this.infants = 0,
    this.pets = 0,
  });

  SearchState copyWith({
    SearchStep? currentStep,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
    int? infants,
    int? pets,
  }) {
    return SearchState(
      currentStep: currentStep ?? this.currentStep,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      pets: pets ?? this.pets,
    );
  }

  int get totalGuests => adults + children;
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchState build() {
    return const SearchState();
  }

  void setStep(SearchStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void setDates(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void updateGuestCount({
    int? adults,
    int? children,
    int? infants,
    int? pets,
  }) {
    state = state.copyWith(
      adults: adults,
      children: children,
      infants: infants,
      pets: pets,
    );
  }

  void reset() {
    state = const SearchState();
  }
}

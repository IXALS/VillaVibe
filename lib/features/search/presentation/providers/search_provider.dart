import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

enum SearchStep { where, when, who }

enum SearchDateTab { dates, months, flexible }

@immutable
class SearchState {
  final SearchStep currentStep;
  final String? location;
  final SearchDateTab activeDateTab;
  
  // Specific Dates Tab
  final DateTime? specificStartDate;
  final DateTime? specificEndDate;
  
  // Months Tab
  final DateTime? monthsStartDate;
  final int monthsCount;
  
  // Flexible Tab
  final String flexibleDuration; // 'Weekend', 'Week', 'Month'
  final List<DateTime> flexibleMonths;

  final int adults;
  final int children;
  final int infants;
  final int pets;

  // Location Search
  final GeoPoint? userLocation;
  final bool isSearchingNearby;

  const SearchState({
    this.currentStep = SearchStep.where,
    this.location,
    this.activeDateTab = SearchDateTab.dates,
    this.specificStartDate,
    this.specificEndDate,
    this.monthsStartDate,
    this.monthsCount = 1,
    this.flexibleDuration = 'Weekend',
    this.flexibleMonths = const [],
    this.adults = 0,
    this.children = 0,
    this.infants = 0,
    this.pets = 0,
    this.userLocation,
    this.isSearchingNearby = false,
  });

  // Computed properties for the actual search query
  DateTime? get startDate {
    switch (activeDateTab) {
      case SearchDateTab.dates:
        return specificStartDate;
      case SearchDateTab.months:
        return monthsStartDate;
      case SearchDateTab.flexible:
        // Placeholder logic for flexible dates
        // For now, return null or implement specific logic if needed
        return null; 
    }
  }

  DateTime? get endDate {
    switch (activeDateTab) {
      case SearchDateTab.dates:
        return specificEndDate;
      case SearchDateTab.months:
        if (monthsStartDate == null) return null;
        return DateTime(monthsStartDate!.year, monthsStartDate!.month + monthsCount, monthsStartDate!.day);
      case SearchDateTab.flexible:
        return null;
    }
  }

  SearchState copyWith({
    SearchStep? currentStep,
    String? location,
    SearchDateTab? activeDateTab,
    DateTime? specificStartDate,
    DateTime? specificEndDate,
    DateTime? monthsStartDate,
    int? monthsCount,
    String? flexibleDuration,
    List<DateTime>? flexibleMonths,
    int? adults,
    int? children,
    int? infants,
    int? pets,
    GeoPoint? userLocation,
    bool? isSearchingNearby,
  }) {
    return SearchState(
      currentStep: currentStep ?? this.currentStep,
      location: location ?? this.location,
      activeDateTab: activeDateTab ?? this.activeDateTab,
      specificStartDate: specificStartDate ?? this.specificStartDate,
      specificEndDate: specificEndDate ?? this.specificEndDate,
      monthsStartDate: monthsStartDate ?? this.monthsStartDate,
      monthsCount: monthsCount ?? this.monthsCount,
      flexibleDuration: flexibleDuration ?? this.flexibleDuration,
      flexibleMonths: flexibleMonths ?? this.flexibleMonths,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      pets: pets ?? this.pets,
      userLocation: userLocation ?? this.userLocation,
      isSearchingNearby: isSearchingNearby ?? this.isSearchingNearby,
    );
  }

  int get totalGuests => adults + children;
}

@Riverpod(keepAlive: true)
class SearchNotifier extends _$SearchNotifier {
  @override
  SearchState build() {
    return const SearchState();
  }

  void setStep(SearchStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setLocation(String location) {
    // If setting a text location, disable nearby search unless explicitly set
    state = state.copyWith(
      location: location,
      isSearchingNearby: false,
      userLocation: null,
    );
  }

  void setNearbySearch(GeoPoint location) {
    state = state.copyWith(
      location: 'Current Location',
      userLocation: location,
      isSearchingNearby: true,
    );
  }

  void setActiveDateTab(SearchDateTab tab) {
    state = state.copyWith(activeDateTab: tab);
  }

  void setSpecificDates(DateTime? start, DateTime? end) {
    state = state.copyWith(
      specificStartDate: start,
      specificEndDate: end,
      activeDateTab: SearchDateTab.dates,
    );
  }

  void setMonthsConfig(DateTime start, int months) {
    state = state.copyWith(
      monthsStartDate: start,
      monthsCount: months,
      activeDateTab: SearchDateTab.months,
    );
  }

  void setFlexibleConfig(String duration, List<DateTime> months) {
    state = state.copyWith(
      flexibleDuration: duration,
      flexibleMonths: months,
      activeDateTab: SearchDateTab.flexible,
    );
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

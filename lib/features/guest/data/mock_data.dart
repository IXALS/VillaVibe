import 'package:villavibe/features/properties/domain/models/property.dart';

final List<Property> mockProperties = [
  Property(
    id: '1',
    name: 'Condo in Kecamatan Menteng',
    description: 'A beautiful condo in the heart of Menteng.',
    pricePerNight: 1455146,
    rating: 5.0,
    images: [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=1000&auto=format&fit=crop',
    ],
    city: 'Menteng',
    address: 'Kecamatan Menteng, Jakarta',
    amenities: ['Wifi', 'Pool', 'Kitchen'],
    hostId: 'host1',
    hostName: 'SARE.Suites',
    hostAvatar:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
    hostYearsHosting: 2,
    reviewsCount: 149,
    hostWork: 'creative director',
    hostDescription:
        'SA/RE suites is a short-term rental accommodation that offers home for travelers. Our time has strived to make these properties to be good and comfort for you as home.',
    hostResponseRate: '100%',
    hostResponseTime: 'within an hour',
    cancellationPolicy:
        'Cancel before check-in on November 21 for a partial refund. After that, this reservation is non-refundable.',
    houseRules: [
      '2 guests maximum',
      'No pets',
      'No commercial photography',
    ],
    safetyItems: [
      'Exterior security cameras on property',
      'Carbon monoxide alarm',
      'Smoke alarm',
    ],
    reviews: [
      Review(
        id: 'r1',
        authorName: 'Idelia',
        authorAvatar:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop',
        rating: 5.0,
        content:
            'Clean, not smelly, good location, responsive host. But if you hv your own transportation & solo traveler it a bit difficult to drop key when checking out. Ti...',
        date: DateTime(2025, 7, 15),
      ),
      Review(
        id: 'r2',
        authorName: 'John',
        authorAvatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
        rating: 4.8,
        content: 'Great place to stay!',
        date: DateTime(2025, 6, 20),
      ),
      Review(
        id: 'r3',
        authorName: 'Jane',
        authorAvatar:
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop',
        rating: 5.0,
        content: 'Highly recommended.',
        date: DateTime(2025, 5, 10),
      ),
    ],
    specs: PropertySpecs(
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
    ),
  ),
  Property(
    id: '2',
    name: 'Apartment in Menteng',
    description: 'Cozy apartment with city views.',
    pricePerNight: 901530,
    rating: 4.95,
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1000&auto=format&fit=crop',
    ],
    city: 'Menteng',
    address: 'Menteng, Jakarta',
    amenities: ['Wifi', 'AC', 'Workspace'],
    hostId: 'host2',
    hostName: 'David',
    hostAvatar:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
    hostYearsHosting: 3,
    reviewsCount: 85,
    hostWork: 'software engineer',
    hostDescription:
        'I love hosting travelers and sharing my city with them. My apartment is perfect for business travelers and digital nomads.',
    hostResponseRate: '95%',
    hostResponseTime: 'within a few hours',
    cancellationPolicy:
        'Free cancellation before 48 hours of check-in. After that, 50% refund.',
    houseRules: [
      '2 guests maximum',
      'No smoking',
      'Quiet hours after 10 PM',
    ],
    safetyItems: [
      'Smoke alarm',
      'Fire extinguisher',
    ],
    reviews: [
      Review(
        id: 'r4',
        authorName: 'Sarah',
        authorAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
        rating: 5.0,
        content: 'Perfect location and very clean!',
        date: DateTime(2025, 8, 1),
      ),
    ],
    specs: PropertySpecs(
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
    ),
  ),
  Property(
    id: '3',
    name: 'Cottage in Yogyakarta',
    description: 'Traditional wooden cottage surrounded by nature.',
    pricePerNight: 976494,
    rating: 4.85,
    images: [
      'https://images.unsplash.com/photo-1585543805890-6051f7829f98?q=80&w=1000&auto=format&fit=crop',
    ],
    city: 'Yogyakarta',
    address: 'Yogyakarta, Indonesia',
    amenities: ['Garden', 'Wifi', 'Breakfast'],
    hostId: 'host3',
    hostName: 'Budi',
    hostAvatar:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop',
    hostYearsHosting: 7,
    reviewsCount: 210,
    specs: PropertySpecs(
      maxGuests: 3,
      bedrooms: 1,
      bathrooms: 1,
    ),
  ),
  Property(
    id: '4',
    name: 'Apartment in Ngaglik',
    description: 'Modern apartment with stylish interior.',
    pricePerNight: 1067011,
    rating: 4.92,
    images: [
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000&auto=format&fit=crop',
    ],
    city: 'Ngaglik',
    address: 'Ngaglik, Yogyakarta',
    amenities: ['Pool', 'Gym', 'Wifi'],
    hostId: 'host4',
    hostName: 'Lisa',
    hostAvatar:
        'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=200&auto=format&fit=crop',
    hostYearsHosting: 2,
    reviewsCount: 45,
    specs: PropertySpecs(
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
    ),
  ),
  Property(
    id: '5',
    name: 'Apartment in Kalibata',
    description: 'Affordable apartment near the station.',
    pricePerNight: 350000,
    rating: 4.7,
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1000&auto=format&fit=crop',
    ],
    city: 'Kalibata',
    address: 'Kalibata, Jakarta',
    amenities: ['Wifi', 'Kitchen'],
    hostId: 'host5',
    hostName: 'Agus',
    hostAvatar:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
    hostYearsHosting: 4,
    reviewsCount: 98,
    specs: PropertySpecs(
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
    ),
  ),
];

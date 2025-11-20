import 'package:villavibe/features/properties/domain/models/property.dart';

final List<Property> mockProperties = [
  Property(
    id: '1',
    name: 'Condo in Kecamatan Menteng',
    description: 'A beautiful condo in the heart of Menteng.',
    pricePerNight: 1455146,
    rating: 5.0,
    images: [
      'https://a0.muscache.com/im/pictures/miso/Hosting-53286881/original/5e89b216-74f6-442b-814f-2628f8569344.jpeg?im_w=720',
    ],
    city: 'Menteng',
    address: 'Kecamatan Menteng, Jakarta',
    amenities: ['Wifi', 'Pool', 'Kitchen'],
    hostId: 'host1',
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
      'https://a0.muscache.com/im/pictures/miso/Hosting-881806366296962794/original/54459920-6841-4038-87a4-63685648777a.jpeg?im_w=720',
    ],
    city: 'Menteng',
    address: 'Menteng, Jakarta',
    amenities: ['Wifi', 'AC', 'Workspace'],
    hostId: 'host2',
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
      'https://a0.muscache.com/im/pictures/miso/Hosting-47431639/original/3267536a-1667-4061-b426-22e078398504.jpeg?im_w=720',
    ],
    city: 'Yogyakarta',
    address: 'Yogyakarta, Indonesia',
    amenities: ['Garden', 'Wifi', 'Breakfast'],
    hostId: 'host3',
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
    specs: PropertySpecs(
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
    ),
  ),
];

import 'package:homebazaar/model/filters.dart';
import 'package:homebazaar/model/property.dart';

const propTypes = [
  (label: 'All', type: null),
  (label: 'House', type: PropertyType.house),
  (label: 'Apartment', type: PropertyType.apartment),
  (label: 'Villa', type: PropertyType.villa),
  (label: 'Land', type: PropertyType.land),
  (label: 'Office', type: PropertyType.office),
];

const sortOptions = [
  (label: 'Newest', sort: SortOrder.newest),
  (label: 'Price ↑', sort: SortOrder.priceAsc),
  (label: 'Price ↓', sort: SortOrder.priceDesc),
  (label: 'Popular', sort: SortOrder.popular),
];

const priceRanges = [
  (label: 'Any Price', min: null, max: null),
  (label: 'Under ₹1Cr', min: null, max: 10000000.0),
  (label: '₹1–5 Cr', min: 10000000.0, max: 50000000.0),
  (label: '₹5Cr+', min: 50000000.0, max: null),
];

const bedOptions = [
  (label: 'Any BHK', beds: null),
  (label: '2 BHK', beds: '2'),
  (label: '3 BHK', beds: '3'),
  (label: '4+ BHK', beds: '4'),
];
